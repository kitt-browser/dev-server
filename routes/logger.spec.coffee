chai = require('chai')
chai.should()
sinon = require('sinon')
request = require('supertest')
express = require('express')
bodyParser = require('body-parser')
util = require('util')


describe "/logger", ->

  logger = require('./logger')

  app = null
  beforeEach ->
    app = express()
    app.use bodyParser()
    app.use "/", logger

  describe "when POST request is recieved", ->

    it "should return HTTP 200 (OK)", (done) ->
      request(app)
        .post('/')
        .expect(200, done)

    it "should `util.log` a debug line", ->
      sinon.stub(util, 'log')
      request(app)
        .post('/')
        .send({addon: 'test addon', origin: 'CNT', message: 'pineapple'})
        .expect 200, (err) ->
          util.log.should.have.been.called
          util.log.firstCall.args[0].should.include('test addon')
          util.log.firstCall.args[0].should.include('CNT')
          util.log.firstCall.args[0].should.include('pineapple')
