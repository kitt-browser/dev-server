# Extensions initializer
# ======================
# Reads the extension directory (specified in config) and load all the
# extensions.
#
# Sets `extensionTempDir` (where to store the packed crx files) and
# `extensions` (list of extensions metadata) app global vars.

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
