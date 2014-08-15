Q = require('q')
_ = require('underscore')
ChromeExt = require('crx')
debug = require('debug')('kitt-dev:packer')
qfs = require('q-io/fs')
path = require('path')

cp = require('child_process');

# Packs the contents of `inputDir` into `outputFile` (using `privateKey`).
pack = (inputDir, privateKey, outputFile) ->
  crx = null

  deferred = Q.defer()

  extName = path.basename outputFile

  packer = cp.spawn('crx', ['pack', process.env.ADBLOCK_DIR, '-f', outputFile]);

  packer.on 'close', ->
    console.log 'packing done'
    deferred.resolve()

  packer.stdout.on 'data', (data) ->
    console.log('stdout: ' + data)

  packer.stderr.on 'data', (data) ->
    console.log('stderr: ' + data);

  return deferred.promise

  ###
  qfs.read(privateKey).then (key) ->
    crx = new ChromeExt {
      rootDirectory: inputDir
      privateKey: key
    }
    debug("#{extName}: packing the crx...")
    Q.ninvoke(crx, 'pack')

  .fail (err) ->
    console.log 'Failed to pack', err
    throw err
  
  .then (data) ->
    debug("#{extName}: sucessfully packed")
    qfs.write outputFile, data
  
  .finally ->
    # Cleanup the temp dir.
    debug("#{extName}: cleaning tmp dir for %s", inputDir)
    crx?.destroy()
  ###

exports.pack = pack
