temp = require('temp')
path = require('path')
fs = require('fs')
Q = require('q')
crx = require('crx')

sinon = require('sinon')
chai = require('chai')
chai.use require('chai-as-promised')
chai.use require('sinon-chai')
chai.should()

describe "packer", ->

  packer = require './packer'

  describe ".pack()", ->

    outFile = null
    stat = Q.denodeify fs.stat
    mkdirTmp = Q.denodeify temp.mkdir

    beforeEach ->
      sinon.stub(crx.prototype, 'pack').yields(null, 'foobar')
      sinon.stub(crx.prototype, 'destroy')
      return mkdirTmp('packer').then (outdir) ->
        outFile = path.join(outdir, 'packer.crx')

    afterEach ->
      crx.prototype.pack.restore()
      crx.prototype.destroy.restore()

    it "should be a method", ->
      packer.pack.should.be.a.function

    it "should create a `crx` file", ->
      packer.pack('test/fixtures/packer', 'test/fixtures/key.pem', outFile)
        .then ->
          stat(outFile)
        .then (stats) ->
          stats.isFile().should.be.true
          crx.prototype.destroy.should.have.been.called
