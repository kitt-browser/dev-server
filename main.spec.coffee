sinon = require('sinon')
chai = require('chai')
chai.use require('chai-as-promised')
chai.use require('sinon-chai')
chai.should()
 

describe "main", ->

  temp = require('temp').track()
  sio = require('socket.io')
  express = require('express')
  extensions = require('./lib/extensions')
  watcher = require('./lib/watcher')
  {EventEmitter} = require('events')
  config = require('config')
  main = require('./main')

  app = null
  sandbox = null
  
  beforeEach ->
    sandbox = sinon.sandbox.create()
    app = express()

    sandbox.spy(temp, 'mkdir')
    sandbox.spy(extensions, 'loadExtensions')
    sandbox.stub(watcher, 'startWatching').returns new EventEmitter()

    sandbox.stub(app, 'listen')
    sandbox.stub(sio, 'listen').returns {set: ->}

  afterEach ->
    sandbox.restore()

  describe.only "init", ->

    it "should create a temp dir for storing generated crx files", ->
      main.init(app).then ->
        temp.mkdir.should.have.been.calledWith('kitt-extensions')

    it "should load all extensions", ->
      main.init(app).then ->
        extensions.loadExtensions.should.have.been.calledWith(
          config.extensions.root, sinon.match.string, config.extensions.privateKey)
