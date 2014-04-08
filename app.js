/**
 * Kitt addon development server
 */

var express = require('express')
  , http = require('http')
  , path = require('path')
  , fetcher = require('./fetcher')
  , util = require('util')
  , url = require('url');

var app = express();
var EXTS_FOLDER = './exts';
var _exts = [];
var argsActual = process.argv.splice(2);
var portSelf = argsActual[0] || 80;

app.configure(function(){
  app.use(express.favicon(path.join(__dirname, 'favicon.ico')));
  app.set('views', path.join(__dirname,'/views'));
  app.set('view engine', 'jade');
  app.use(express.bodyParser()); // for POST
  app.use(app.router);
  app.locals({
    base_url: '/'
  });
});

app.get('/', function(req, res) {
  res.render('index', {
    title : 'Kitt',
    count : _exts.length,
    client_version: req.client_version
  });
});

app.get('/list', function(req, res) {
  res.render('list', {
    title : 'Kitt',
    installbase : 'kitt://' + req.headers.host + '/install/',
    downloadbase : 'http://' + req.headers.host + '/install/',
    extlist : _exts
  });
});

app.get('/icon/:id', function(req, res) {
  sendFile(req.params.id, res,  fetcher.fileFromIcon);
});

app.get('/install/:id', function(req, res) {
  sendFile(req.params.id, res, fetcher.fileFromCRX);
});

app.post('/logger', function(req, res) {
  util.log(req.body.addon+'|'+req.body.origin+'|'+req.body.message);
  res.send(200);
});

app.use('/extension', express.static(__dirname + '/exts'));

var sendFile = function(extid, res, fileSourceFunction) {
  fileSourceFunction(extid, function(err, result, cleanupCallback) {
    if(err) {
      util.log("Extid '"+extid+"' type '"+result.mime+"' error : "+err);
      res.send(404);
    } else {
      util.log('Sending file '+result.name+' for '+extid+' type '+result.mime);
      if(result.mime) {
        res.set('Content-Type', result.mime);
      }
      if(result.name) {
        res.set('Content-Disposition',
                'attachment; filename="'+result.name+'"');
      }
      res.send(result.data);
      if(cleanupCallback) {
        cleanupCallback();
      }
    }
  });
};

fetcher.start(
  EXTS_FOLDER,
  // callback for finished fetcher start
  function(err) {
    util.log("Fetcher finished");
    if( err ) {
      util.log("Fetcher start failed, not starting server");
    } else {
      http.createServer(app).listen(portSelf, function() {
        util.log("Express server listening on port " + portSelf);
      });
    }
  },
  // callback for changed manifest persistence
  function(manifests) {
    _exts = [];
    for(var id in manifests) {
      var manifest = manifests[id];
      // copy just the props View needs
      console.log('TEST');
      _exts.push({
        id:id,
        name: manifest.name,
        version: manifest.version,
        description: manifest.description
      });
    }
  }
);
