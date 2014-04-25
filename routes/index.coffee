express = require('express')
config = require('config')
path = require('path')
router = express.Router()
qfs = require('q-io/fs')

# GET home page.
router.get '/', (req, res) ->
  console.log req.app.locals.settings
  res.render 'list', { title: 'Express', host: req.headers.host }


router.get '/download/:name', (req, res, next) ->
  name = req.params.name
  res.set 'Content-Type', 'application/x-chrome-extension'
  res.set('Content-Disposition', "attachment; filename=\"#{name}.crx\"")
  qfs.read(path.join(req.app.get('extensionTempDir'), "#{name}.crx")).then (data) ->
    console.log 'sending', res
    res.send data

module.exports = router
