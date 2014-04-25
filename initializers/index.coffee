qfs = require('q-io/fs')

module.exports = (app) ->
  qfs.list(__dirname).then (files) ->
    files.forEach (file) ->
      if ~file.split('.').indexOf('spec') or file == 'index.coffee'
        return
      require("./#{file}")(app)
