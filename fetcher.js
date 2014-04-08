var _ = require('underscore');
var fs = require('fs');
var fs_path = require('path');
var watch = require('watch');
var util = require('util');
var async = require('async');
var Crx = require('crx');
var store = require('nstore');
store = store.extend(require('nstore/query')());

(function() {

var MANIFEST_NAME = 'manifest.json';
var EXTENSIONS_DB = "db/extensions.db";
var PK_NAME = 'exts/key.pem';
var _extsDb = null;
var privateKey = null;

// ==============================================================
// exports

exports.start = function(path, onFinished, onChanged) {
  path = path + '/';
  util.log('Extension folder is ' + path);
  async.series([
    function(callback) {
      util.log('*** Reading private key '+PK_NAME);
      fs.readFile(PK_NAME, function(err, data) {
        if(!err) {
          privateKey = data;
        }
        callback(err);
      });
    },
    function(callback) {
      util.log('*** Db load');
      initialDbLoad( function(err) {
        callback(err);
      });
    },
    function(callback) {
      util.log('*** Reading fs');
      initialFsLoad(path, function(err) {
        callback(err);
      });
    },
    function(callback) {
      util.log('*** Setting up fs watch');
      setupFileMonitor(path, onChanged, function(err) {
        callback(err);
      });
    },
    function(callback) {
      _extsDb.all( function(err, results) {
        if(err) {
          callback(err);
        } else {
          onChanged(results);
          callback();
        }
      });
    }],
    function(err, results) {
      onFinished(err);
    }
  );
};

exports.fileFromIcon = function(id, callback) {
  _extsDb.get(id, function(err, doc, key) {
    if(err) {
      callback(err);
    } else {
      // @todo proper selection of icon by size
      // now just grab the first (and only) one
      var iconName = _.values(doc.icons)[0];
      var iconPath = './exts/'+id+'/'+iconName;
      fs.readFile(iconPath, function(err, data) {
        if(err) {
          callback(err);
        } else {
          callback(err, {
            data: data,
            name: iconName,
            mime: {
              '.jpeg' : 'image/jpeg',
              '.jpg' : 'image/jpeg',
              '.png' : 'image/png'
            }[fs_path.extname(iconName)]
          });
        }
      });
    }
  });
};

exports.fileFromCRX = function(id, callback) {  
  var crxRootDir = fs_path.join(__dirname, 'exts/'+id + '/');
  var crx = new Crx({
    rootDirectory: crxRootDir,
    privateKey: privateKey
  });
  var cleanupFn = function() {
    util.log('Destroying crx object');
    crx.destroy();
  }
  crx.pack(function(err, data) {
    if(err) {
      callback('Error packing crx root "'+crxRootDir+'": '+err, nil, cleanupFn);
    } else {
      callback(err, {
        data: data,
        name: id+'.crx',
        mime: 'application/x-chrome-extension'
      }, cleanupFn);    
    }
  });
};

// ==============================================================
// db load
// check for existence of manifest file in each extension
// where not, delete the extension from db

var initialDbLoad = function(onFinished) {
  var dbDir = fs_path.dirname(EXTENSIONS_DB);
  fs.exists(dbDir, function(exists) {
    if(exists) {
      initialDbLoadExistingFolder(onFinished);
    } else {
      fs.mkdir(dbDir, function(err) {
        if( err ) {
          util.log('Cannot create db folder '+dbDir);
        } else {
          initialDbLoadExistingFolder(onFinished);
        }
      });
    }
  });
};

var initialDbLoadExistingFolder = function(onFinished) {
  // nstore.new sometimes calls back twice
  var dbCreated = false;
  _extsDb = store.new(EXTENSIONS_DB, function() {
    if( dbCreated ) {
      return;
    }
    dbCreated = true;
    // read all existing keys
    _extsDb.all( function(err, manifests) {
      if(err) {
        util.log("* Initial db load error: " + err);
        onFinished(err);
        return;
      }
      var keys = _.keys(manifests);
      if( 0 === keys.length ) {
        util.log("Db empty");
      }
      async.each(keys,
        function(id, callback) {
          var path = './exts/'+id+'/'+MANIFEST_NAME;
          fs.exists(path, function(exists) {
            if(exists) {
              util.log("* '"+id+"' has manifest, ok");
              callback();
            } else {
              util.log("* '"+id+"' manifest not found, deleting");
              _extsDb.remove(id, function(err) {
                callback(err);
              });
            }
          });
        },
        function(err, results) {
          onFinished();
        }
      );
    });
  });
};
// ==============================================================
// fetch files
// Read all subfolders in extension folder
// Update manifests which already exist in db
// Add extensions which do not exist in db

var initialFsLoad = function(path, onFinished) {
  fs.readdir(path, function(err, fs_nodes) {
    if(err) {
      util.log("* Error reading extension dir:" + err);
      onFinished(err);
    } else {
      async.each(fs_nodes,
        function(fs_node, callback) {
          // readdir cannot be restricted to certain fs node types
          // so stat() is needed to filter only folders
          fs.stat(path+fs_node, function(err, stat) {
            if(stat && stat.isDirectory()) {
              var manifest_file = path+fs_node+'/'+MANIFEST_NAME;
              fs.readFile(manifest_file, function(err, data) {
                if(err) {
                  util.log("'"+fs_node+"' can't read manifest: "+err);
                  callback(err);
                } else {
                  util.log("'"+fs_node+"' loading manifest");
                  var manifest = JSON.parse(data);
                  _extsDb.get(fs_node, function(err, doc, key) {
                    if(err || !_.isEqual(manifest, doc)) {
                      util.log("'"+fs_node+"' manifest different from db, updating");
                      _extsDb.save(fs_node, manifest, function(err, key) {
                        callback(err);
                      });
                    } else {
                      util.log("'"+fs_node+"' manifest equal to db, skipping update");
                      callback();
                    }
                  });
                }
              });
            } else {
              // not a directory or no stat (maybe having err)
              callback(err);
            }
          });
        },
        function(err, results) {
          onFinished(err);
        }
      );
    }
  });
}

// ==============================================================
// watch

var setupFileMonitor = function(path, onDbChanged, onSetupFinished) {
  watch.createMonitor(path, function(monitor) {
    // monitor callbacks give back OS-specific paths
    // so convert windows to unix-ish
    function deWindozifyPath(f) {
      f = f.replace(/\\/g,'/');
      if(f.indexOf('./')!=0) {
        f = './' + f;
      }
      return f;
    }
    monitor.on("created", function (f, stat) {
      util.log(f);
      onFileEvent(deWindozifyPath(f), "created");
    });
    monitor.on("changed", function (f, curr, prev) {
      util.log(f);
      onFileEvent(deWindozifyPath(f), "changed");
    });
    monitor.on("removed", function (f, stat) {
      util.log(f);
      onFileEvent(deWindozifyPath(f), "removed");
    });
    onSetupFinished();
  });
  
  var self = this;
  var onFileEvent = function(file, event) {
    util.log("watch: "+event+" file " + file);
    if( fs_path.basename(file) !== MANIFEST_NAME ) {
      util.log("Fs change irrelevant to database");
      return;
    }
    var pathElements = file.split('/');
    if( pathElements.length < 2 ) {
      util.log('Invalid path '+file);
      return;
    }
    var id = pathElements[pathElements.length-2];
    self['onFile_'+event](file, id);
  }
  
  this.onFile_created = function(file, id) {
    _extsDb.get(id, function(err, doc, key) {
      if(err) {
        // doesn't exist, ok
        fs.readFile(file, function(err, data) {
          if(err) {
            util.log("* Can't read created  '"+file+"' error : "+err);
            return;
          }
          var manifestFs = JSON.parse(data);
          _extsDb.save(id, manifestFs, function(err, key) {
            if( err ) {
              util.log("* Can't store in db  '"+file+"' error : "+err);
            } else {
              _extsDb.all( function(err, results) {
                if(err) {
                  util.log("* Can't read db after file created '"+file+"'");
                } else {
                  onDbChanged(results);
                }
              });
            }
          });
        });
      } else {
        util.log("* '"+id+"' ALREADY HAS MANIFEST IN DB");
      }
    });
  };
  
  this.onFile_changed = function(file, id) {
    _extsDb.get(id, function(err, manifestDb, key) {
      if(err) {
        util.log("* '"+id+"' DOES NOT HAVE A MANIFEST IN DB");
        return;
      }
      fs.readFile(file, function(err, data) {
        if(err) {
          util.log("* Can't read changed '"+file+"' error : "+err);
          return;
        }
        var manifestFs = JSON.parse(data);
        if( _.isEqual(manifestFs, manifestDb) ) {
            util.log("'"+id+"' manifest equal to db, skipping update");
        } else {
          util.log("'"+id+"' manifest different from db, updating");
          _extsDb.save(id, manifestFs, function(err, key) {
            if(err) {
              util.log("* Can't store changed '"+id+"' error : "+err);
            } else {
              _extsDb.all( function(err, results) {
                if(err) {
                  util.log("* Can't read db after file changed '"+file+"'");
                } else {
                  onDbChanged(results);
                }
              });
            }
          });
        }
      });
    });
  };
  
  this.onFile_removed = function(file, id) {
    _extsDb.get(id, function(err, doc, key) {
      if(err) {
        util.log("* '"+id+"' DOES NOT HAVE A MANIFEST IN DB");
        return;
      }
      _extsDb.remove(id, function(err) {
        if(err) {
          util.log("'"+id+"' can't remove manifest, error : " +err);
        } else {
          _extsDb.all( function(err, results) {
            if(err) {
              util.log("* Can't read db after file removed '"+file+"'");
            } else {
              onDbChanged(results);
            }
          });
        }
      });
    });
  };
};

})();
