Q = require('q')
_ = require('underscore')
crx = require('crx')
debug = require('debug')('kitt-dev:packer')
fs = require('fs')

pack = (inputDir, privateKey, outputFile) ->
  _crx = new crx {
    rootDirectory: inputDir
    privateKey: privateKey
  }

  return Q.ninvoke(_crx, 'pack')
    .then (data) ->
      Q.ninvoke fs, 'writeFile', outputFile, data
    .finally ->
      _crx.destroy()

exports.pack = pack
