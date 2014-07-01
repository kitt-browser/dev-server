config = require('config')
temp = require('temp').track()
extensions = require('./lib/extensions')
watcher = require('./lib/watcher')
Q = require('q')
sio = require('socket.io')
debug = require('debug')('kitt-dev:main')



exports.init = (app) ->
  makeTmpDir = Q.denodeify(temp.mkdir)

  # This function:
  # 1. Reloads all the extensions from the disk (and packs them into `crx` files).
  # 2. Sets the app global `metadata` var (containing information about the
  #    extensions).
  # 3. Sends `update` to clients connected via websockets.
  refreshExtensions = (dir) ->
    extensions.loadExtensions(config.extensions.root, dir, config.extensions.privateKey)
      .then (metadata) ->
        app.set 'extensions', metadata
        app.get('io')?.sockets.emit 'update', {metadata: metadata}

  qRunning = makeTmpDir('kitt-extensions')

    # Load the extensions.
    .then (crxRoot) ->
      app.set 'extensionTempDir', crxRoot
      refreshExtensions(crxRoot)

    # Start the server and websockets and whatnot.
    .then ->
      debug('starting server...')
      # Start the server.
      server = app.listen app.get('port'), ->
        debug('Express server listening on port ' + server.address().port)

      debug('Initializing websockets...')
      io = sio.listen(server)
      io.set 'log level', 1
      app.set 'io', io

      watchEmitter = watcher.startWatching(config.extensions.root, {debounce: 500})

      watchEmitter.on 'extensions:updated', ->
        refreshExtensions(app.get('extensionTempDir'))
      debug('all done')

  return qRunning
