chokidar = require('chokidar')
debug = require('debug')('kitt-com:watcher')
path = require('path')
extensions = require('./extensions')
config = require('config')
_ = require('underscore')
Q = require('q')


# Do not watch those (would be too many files...).
IGNORED = [
  '.git'
  'node_modules'
]


# Starts listening for any FS events on `rootDir`. On event, find the affected
# extension directory, repack the cxr and update the extension metadata list. 
# And call `callback` with the updated extension metadata object (used mainly by
# the tests).
init = (rootDir, app, callback = ->) ->
  debug('Watching %s', rootDir)

  # Do not watch those files.
  ignore = (path) ->
    IGNORED.some (string) -> ~path.indexOf(string)

  watcher = chokidar.watch rootDir, {
    persistent: false, ignored: ignore, ignoreInitial: true}

  watcher.on 'all', (event, _path) ->
    debug("Detected event %s in %s", event, _path)

    # Figure out the affected extension directory.
    pathFromRootDir = _path.replace(rootDir, '')
    trimmedExtDir = pathFromRootDir
    if pathFromRootDir[0] == path.sep
      trimmedExtDir = pathFromRootDir[1..]
    extDirAbs = path.join rootDir, trimmedExtDir.split(path.sep)[0]

    tmpDir = app.get('extensionTempDir')
    key = config.extensions.privateKey

    # Let's upsert the extensions metadata list with the new (or updated) extension.
    extensions.loadExtension(extDirAbs, tmpDir, key)

      .then (metadata) ->
        exts = app.get 'extensions'
        upsertedExtension = _.findWhere(exts, name: metadata.name)
        newExts = _.without(exts, upsertedExtension)
        newExts.push metadata

        app.set 'extensions', newExts
        debug "Extension metadata list updated."

        app.emit('extensions:updated', metadata)

      .fail (err) ->
        debug("Error: Failed to pack extension", err)
        app.emit('extensions:error', err)

      .done()


exports.init = init
