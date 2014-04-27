qfs = require('q-io/fs')
Q = require('q')
path = require('path')

ALLOWED_EXTS = ['.js', '.coffee']

# Run all the initializers in this directory.
module.exports = (app) ->
  qAllInitalized = qfs.list(__dirname).then (files) ->
    qInitalizersDone = files.map (file) ->
      return unless path.extname(file) in ALLOWED_EXTS
      if ~file.split('.').indexOf('spec') or file == 'index.coffee'
        return
      require("./#{file}")(app)
    Q.all qInitalizersDone
  return qAllInitalized
