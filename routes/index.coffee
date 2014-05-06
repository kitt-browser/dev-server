express = require('express')
config = require('config')
path = require('path')
router = express.Router()
qfs = require('q-io/fs')
_ = require('underscore')
debug = require('debug')('kitt-com:routes')
util = require('util')


# GET home page.
router.get '/', (req, res) ->
  res.redirect '/list'


# Show list of extensions.
router.get '/list', (req, res) ->
  res.render 'list', { title: 'Kitt Dev Server', host: req.headers.host }


# Show extension debug logs in the console.
router.post '/logger', (req, res) ->
  return res.send 500 unless req.body?
  util.log "#{req.body.addon}|#{req.body.origin}|#{req.body.message}"
  res.send 200


router.get '/extensions/:name/download', (req, res, next) ->
  name = req.params.name
  res.set 'Content-Type', 'application/x-chrome-extension'
  res.set 'Content-Disposition', "attachment; filename=\"#{name}.crx\""
  # Note: If the file doesn't exist, the 404 error handler will take
  # care of it.
  res.download path.join(req.app.get('extensionTempDir'), "#{name}.crx")


router.get '/extensions/:name/icon', (req, res, next) ->
  metadata = _.findWhere req.app.get('extensions'), name: req.params.name
  return res.send(404, "Unknown extension") unless metadata
  res.download metadata.icon


module.exports = router
