chai = require('chai')
chai.should()
sinon = require('sinon')
request = require('supertest')
express = require('express')
{loadExtensions} = require('../lib/extensions')

describe "index route", ->

  routes = require('./index')

  app = null
  
  beforeEach ->
    app = express()
    app.use "/", routes

  describe "/extensions/:name/download", ->

    beforeEach ->
      app.set 'extensionTempDir', 'test/fixtures/dummy_crx'

    it "should serve the right extension", (done) ->
      request(app)
        .get('/extensions/dummy/download')
        .expect('Content-Type', 'application/x-chrome-extension')
        .expect('Content-Disposition', 'attachment; filename="dummy.crx"')
        .expect(200, done)

    it "should return HTTP 404 for a non-existing extension", (done) ->
      request(app)
        .get('/extensions/iamnothere/download')
        .expect(404, done)

  describe "/extension/:name/*", ->

    extInitializer = require('../initializers/extensions')

    beforeEach ->
      # Make sure extensions-related app globals are set.
      extInitializer(app)

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

      
