temp = require('temp').track()
Q = require('q')
qfs = require('q-io/fs')
debug = require('debug')('kitt-com:initializers:extensions')
config = require('config')

extensions = require('../lib/extensions')

module.exports = (app) ->
  # Initialize list of extensions metadata.
  app.set 'extensions', []

  qMetadata = Q.ninvoke(temp, 'mkdir', 'kitt-extensions').then (dir) ->
    debug('extension dir, %s', dir)
    app.set 'extensionTempDir', dir

    cfgExt = config.extensions
    extTempDir = app.get('extensionTempDir')

    extensions.loadExtensions(cfgExt.root, extTempDir, cfgExt.privateKey)

  return qMetadata.then (metadata) ->
    debug 'metadata loaded', metadata
    app.set 'extensions', metadata
