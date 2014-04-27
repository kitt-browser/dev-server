express = require('express')
config = require('config')
path = require('path')
router = express.Router()
qfs = require('q-io/fs')
_ = require('underscore')
debug = require('debug')('kitt-com:routes')


# GET home page.
router.get '/', (req, res) ->
  res.render 'list', { title: 'Express', host: req.headers.host }


router.get '/extensions/:name/download', (req, res, next) ->
  name = req.params.name
  res.set 'Content-Type', 'application/x-chrome-extension'
  res.set('Content-Disposition', "attachment; filename=\"#{name}.crx\"")
  res.download path.join(req.app.get('extensionTempDir'), "#{name}.crx")


router.get '/extensions/:name/icon', (req, res, next) ->
  metadata = _.findWhere req.app.get('extensions'), name: req.params.name
  return res.send(404, "Unknown extension") unless metadata
  res.download metadata.icon


module.exports = router
