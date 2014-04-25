temp = require('temp')
Q = require('q')
qfs = require('q-io/fs')
debug = require('debug')('kitt-com:initializers:extensions')
config = require('config')

extensions = require('../lib/extensions')

module.exports = (app) ->

  # Initialize list of extensions metadata.
  app.set 'extensions', []

  Q.ninvoke(temp, 'mkdir', 'kitt-extensions').then (dir) ->
    debug('extension dir, %s', dir)
    app.set 'extensionTempDir', dir

    cfgExt = config.extensions
    extTempDir = app.get('extensionTempDir')

    extensions.loadExtensions(cfgExt.root, extTempDir, cfgExt.privateKey)

      .then (metadata) ->
        debug 'metadata loaded', metadata
        app.set 'extensions', metadata

  .done()


  cleanup = (exit) ->
    debug('cleaning up...')
    qfs.removeTree(app.get('extensionTempDir')).finally ->
      if exit then process.exit()


  debug('Setting cleanup hooks...')
  process.on 'exit', -> cleanup false
  process.on 'SIGINT', -> cleanup true
  process.on 'SIGTERM', -> cleanup true
  process.on 'SIGUSR2', -> cleanup true
