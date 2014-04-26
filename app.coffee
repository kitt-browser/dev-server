express = require("express")
path = require("path")
favicon = require("static-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
config = require('config')
temp = require('temp')
Q = require('q')
qfs = require('q-io/fs')

debug = require('debug')('kitt-dev:app')

watcher = require('./lib/watcher')
routes = require('./routes/index')


app = express()

app.set('port', process.env.PORT || 3000)

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use favicon()
app.use logger("dev")
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()
app.use express.static(path.join(__dirname, "public"))
app.use "/", routes

# catch 404 and forwarding to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err

# ## Error handlers.

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}


# Initialize everything.
require('./initializers')(app)

  # Start the server.
  .then ->
    server = app.listen app.get('port'), ->
      debug('Express server listening on port ' + server.address().port)

  .then ->
    # Start watching the extensions directory.
    watcher.init(config.extensions.root, app)

  .done()


module.exports = app
