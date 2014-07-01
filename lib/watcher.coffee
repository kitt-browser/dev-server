chokidar = require('chokidar')
debug = require('debug')('kitt-com:watcher')
path = require('path')
_ = require('underscore')
{EventEmitter} = require('events')


emitter = new EventEmitter()


# Do not watch those (would be too many files...).
#
# Note: chokidar doesn't like it when grunt-crx removes its tmp dir (https://github.com/paulmillr/chokidar/issues/133). So we're adding `tmp` to the ignored directories until that's resolved.
IGNORED = [
  '.git'
  'node_modules'
  'tmp/crx-'
]


# Starts listening for any FS events on `rootDir`. On event, find the affected
# extension directory, repack the cxr and update the extension metadata list. 
# And call `callback` with the updated extension metadata object (used mainly by
# the tests).
startWatching = (rootDir, options = {}) ->
  debug('Watching %s', rootDir)

  # Do not watch those files.
  ignore = (path) ->
    IGNORED.some (string) -> ~path.indexOf(string)

  watcher = chokidar.watch rootDir, {
    persistent: false, ignored: ignore, ignoreInitial: true}

  onChange = _.debounce (event, _path) ->
    debug("Detected event %s in %s", event, _path)
    emitter.emit('extensions:updated')
  , (options.debounce or 0)

  watcher.on 'all', onChange

  return emitter
  

exports.startWatching = startWatching
