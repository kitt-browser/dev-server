debug = require('debug')('kitt-com:logger')
express = require('express')
colors = require('colors')
_ = require('underscore')
router = express.Router()
util = require('util')


colors = [
  'yellow'
  'cyan'
  'white'
  'magenta'
  'green'
  'red'
  'grey'
  'blue'
  'black'
  'yellowBG'
  'cyanBG'
  'greenBG'
  'redBG'
  'greyBG'
  'blueBG'
  'magentaBG'
]

colorMap = {}

# Show extension debug logs in the console.
router.post '/', (req, res) ->
  return res.send 500 unless req.body?

  name = req.body.addon

  # Choose a color.
  if not colorMap[name]
    unusedColors = _.difference(colors, _.values(colorMap))
    if unusedColors.length > 0
      colorMap[name] = unusedColors[0]
    else
      # All the colors have been taken, choose one at random. TODO: Implement
      # a better fallback than this.
      colorMap[name] = colors[Math.floor(Math.random()*colors.length)]

  line = "#{req.body.addon}|#{req.body.origin}|".bold + " #{req.body.message}"
  util.log(line[colorMap[name]])

  res.send 200


module.exports = router
