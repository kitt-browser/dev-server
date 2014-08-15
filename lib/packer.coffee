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


  extName = path.basename outputFile
  qfs.read(privateKey).then (key) ->
    crx = new ChromeExt {
      codebase: "http://localhost:8000/extensions.crx"
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
