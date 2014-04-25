express = require('express')
config = require('config')
path = require('path')
router = express.Router()
qfs = require('q-io/fs')

# GET home page.
router.get '/', (req, res) ->
  res.render 'list', { title: 'Express', host: req.headers.host }


router.get '/download/:name', (req, res, next) ->
  name = req.params.name
  res.set 'Content-Type', 'application/x-chrome-extension'
  res.set('Content-Disposition', "attachment; filename=\"#{name}.crx\"")
  res.download path.join(req.app.get('extensionTempDir'), "#{name}.crx")

module.exports = router
