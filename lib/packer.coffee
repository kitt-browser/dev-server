Q = require('q')
_ = require('underscore')
ChromeExt = require('crx')
debug = require('debug')('kitt-dev:packer')
qfs = require('q-io/fs')
path = require('path')

# Packs the contents of `inputDir` into `outputFile` (using `privateKey`).
pack = (inputDir, privateKey, outputFile) ->
  crx = null

  extName = path.basename outputFile

  debug("#{extName}: reading private key...")

  qfs.read(privateKey).then (key) ->
    crx = new ChromeExt {
      rootDirectory: inputDir
      privateKey: key
    }
    debug("#{extName}: packing the crx...")
    Q.ninvoke(crx, 'pack')
  
  .then (data) ->
    debug("#{extName}: sucessfully packed")
    qfs.write outputFile, data
  
  .finally ->
    # Cleanup the temp dir.
    debug("#{extName}: cleaning tmp dir for %s", inputDir)
    crx?.destroy()

exports.pack = pack
