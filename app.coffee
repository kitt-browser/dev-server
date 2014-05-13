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
sio = require('socket.io')

Q.longStackSupport = true


# Socket.io connected object (listening on the same port as server).
io = null

debug = require('debug')('kitt-dev:app')

watcher = require('./lib/watcher')
routes = require('./routes/index')


app = express()

app.set('port', process.env.PORT || 3000)

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use favicon()
# Uncomment me to see HTTP requests logs.
#app.use logger("dev")
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
process.on 'uncaughtException', (error) ->
  if error.code == 'EMFILE'
    console.warn("""\n\n
      Oops, this is embarassing but I'm going to crash now. Sorry!

      I'm crashing because it seems there's too many files in one of your \
      extension directories. I'm just a tiny process and I can't handle that.

      Maybe you forgot to add a 'kitt.yml' file with \
      'buildDir: <extension build dir>' entry?

      If you think this is not the reason please consider running \
      'ulimit -n 10000' to increase the number of available file \
      descriptors (on UNIXy systems).\n\n
      """)

  console.warn 'Uncaught exception, cowardly exiting...\n', error.stack

  process.exit(1)

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

  .then ->
    # Start watching the extensions directory.
    watcher.init config.extensions.root, app

    # Start the server.
    server = app.listen app.get('port'), ->
      debug('Express server listening on port ' + server.address().port)
    io = sio.listen(server)
    io.set 'log level', 1

  .done()


app.on 'extensions:updated', (metadata) ->
  io?.sockets.emit 'update', {metadata: metadata}


module.exports = app
