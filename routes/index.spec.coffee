chai = require('chai')
chai.should()
sinon = require('sinon')
request = require('supertest')
express = require('express')

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

    it "should return HTTP for a non-existing extension", (done) ->
      request(app)
        .get('/extensions/iamnothere/download')
        .expect(404, done)
