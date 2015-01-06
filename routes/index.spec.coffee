chai = require('chai')
chai.should()
sinon = require('sinon')
request = require('supertest')
express = require('express')
{loadExtensions} = require('../lib/extensions')
Q = require('q')
temp = require('temp').track()
config = require('config')

describe "index route", ->

  routes = require('./index')

  app = null
  mkdirTmp = Q.denodeify temp.mkdir
  
  beforeEach ->
    app = express()
    app.use "/", routes

  beforeEach (done) ->
    mkdirTmp('route-test').then (dir) ->
      app.set 'extensionTempDir', dir
      loadExtensions('test/fixtures/exts', dir, config.extensions.privateKey)
    .then (metadata) ->
      app.set 'extensions', metadata
      done()

  describe "/install/:name", ->

    it "should serve the right extension", (done) ->
      request(app)
        .get('/install/Test1-name')
        .expect('Content-Type', 'application/x-chrome-extension')
        .expect('Content-Disposition', 'attachment; filename="Test1-name.crx"')
        .expect(200, done)

    it "should return HTTP 404 for a non-existing extension", (done) ->
      request(app)
        .get('/install/iamnothere')
        .expect(404, done)

  describe "/extension/:name/*", ->

    it "should serve the extension resource", (done) ->
      request(app)
        .get('/extension/Test1-name/background.js')
        .expect(200, done)

    it "should return HTTP 404 if the extension resource does not exist", (done) ->
      request(app)
        .get('/extension/Test1-name/invalidFile.js')
        .expect(404, done)

    it "should return HTTP 404 if the extension does not exist", (done) ->
      request(app)
        .get('/extension/idontexist/background.js')
        .expect(404, done)

      
