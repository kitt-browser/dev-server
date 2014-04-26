chai = require('chai')
chai.should()
sinon = require('sinon')
express = require('express')
touch = require('touch')
temp = require('temp').track()
Q = require('q')
path = require('path')
config = require('config')

extensions = require('./extensions')


describe "watcher", ->

  watcher = require('./watcher')
  app = null
  tmpDir = null

  describe ".init()", ->

    it "shoud be a function", ->
      watcher.init.should.be.a.function

    beforeEach ->
      app = express()
      return Q.ninvoke(temp, 'mkdir', 'kitt-extensions-test').then (dir) ->
        tmpDir = dir

    it "should repack the affected extension on fs event", (done) ->
      app.set 'extensions', []
      app.set 'extensionTempDir', tmpDir
      sinon.spy extensions, 'loadExtension'

      watcher.init 'test/fixtures/exts', app, ->
        extensions.loadExtension.should.have.been.calledWith('test/fixtures/exts/test1',
          tmpDir,
          path.resolve(config.extensions.privateKey)
        )
        done()

      # Give the watcher a little time to start watching.
      setTimeout ->
        touch.sync('test/fixtures/exts/test1/background.js', {nocreate: true})
      , 150

