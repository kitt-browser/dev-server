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

  describe ".startWatching()", ->

    emitter = null

    it "shoud be a function", ->
      watcher.startWatching.should.be.a.function

    it "should emit a 'extensions:updated' event on a fs event", sinon.test (done) ->
      emitter = watcher.startWatching 'test/fixtures/exts'
      emitter.on 'extensions:updated', ->
        done()
      # Give the watcher a little time to start watching.
      setTimeout ->
        touch.sync('test/fixtures/exts/test1/background.js', {nocreate: true})
      , 150
