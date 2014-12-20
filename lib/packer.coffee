Q = require('q')
_ = require('underscore')
ChromeExt = require('crx')
debug = require('debug')('kitt-dev:packer')
qfs = require('q-io/fs')
path = require('path')

cp = require('child_process')

# Packs the contents of `inputDir` into `outputFile` (using `privateKey`).
pack = (inputDir, privateKey, outputFile) ->
  crx = null

  ###
  deferred = Q.defer()

  extName = path.basename outputFile

  debug("packing adblock: ", process.env.ADBLOCK_DIR, "to", outputFile)

  packer = cp.spawn('crx', ['pack', process.env.ADBLOCK_DIR, '-o', outputFile])

  packer.on 'close', ->
    debug 'packing done'
    deferred.resolve()

  packer.stdout.on 'data', (data) ->
    console.log('stdout: ' + data)

  packer.stderr.on 'data', (data) ->
    console.log('stderr: ' + data)

  return deferred.promise

  ###
  extName = path.basename outputFile
  qfs.read(privateKey).then (key) ->
    crx = new ChromeExt {
      codebase: "http://localhost:8000/myFirstExtension.crx"
      #rootDirectory: inputDir
      privateKey: key
    }
    debug("#{extName}: packing the crx...", inputDir)
    crx
      .load(inputDir)
      .then ->
        debug("packing started")
        crx.pack().then (crxBuffer)->
            debug("#{extName}: sucessfully packed to", outputFile)
            qfs.write outputFile, crxBuffer

  .fail (err) ->
    console.log 'Failed to pack', err
    throw err
  
  .finally ->
    # Cleanup the temp dir.
    debug("#{extName}: cleaning tmp dir for %s", inputDir)
    crx?.destroy()

exports.pack = pack
