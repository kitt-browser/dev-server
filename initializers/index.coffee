qfs = require('q-io/fs')
Q = require('q')

module.exports = (app) ->
  qAllInitalized = qfs.list(__dirname).then (files) ->
    qInitalizersDone = files.map (file) ->
      if ~file.split('.').indexOf('spec') or file == 'index.coffee'
        return
      require("./#{file}")(app)
    Q.all qInitalizersDone
  return qAllInitalized
