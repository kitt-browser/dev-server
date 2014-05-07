sinon = require('sinon')
chai = require('chai')
chai.use require('chai-as-promised')
chai.use require('sinon-chai')
chai.should()
Q = require('q')
packer = require('./packer')
path = require('path')

describe "extensions", ->

  extensions = require('./extensions')

  describe ".loadExtensions()", ->

    beforeEach ->
      sinon.stub(packer, 'pack').returns(Q())

    afterEach ->
      packer.pack.restore()

    it "should be a function", ->
      extensions.loadExtensions.should.be.a.function

    it "should pack all extension in the dir folder", ->
      extDir = path.resolve('test/fixtures/exts')
      extensions.loadExtensions(
        extDir, '/tmp/ephemeral/', 'test/fixtures/key.pem'
      ).then (res) ->
        res.should.eql([
          crx: "/tmp/ephemeral/Test1-name.crx"
          description: "Test1 description"
          name: "Test1-name"
          icon: null
          author: null
          sourcePath: path.resolve("test/fixtures/exts/test1")
          version: "0.9"
        ,
          crx: "/tmp/ephemeral/Test2-name.crx"
          description: "Test2 description"
          name: "Test2-name"
          icon: null
          author: null
          sourcePath: path.resolve("test/fixtures/exts/test2")
          version: "1.0.1"
        ])
        packer.pack.should.have.been.calledTwice
        packer.pack.should.have.been.calledWith(
          path.join(extDir, 'test1'),
          'test/fixtures/key.pem',
          '/tmp/ephemeral/Test1-name.crx')
        packer.pack.should.have.been.calledWith(
          path.join(extDir, 'test2'),
          'test/fixtures/key.pem',
          '/tmp/ephemeral/Test2-name.crx')


    it "should respect the extensions-specific config", ->
      extDir = path.resolve('test/fixtures/exts-with-config')
      extensions.loadExtensions(
        extDir,
        '/tmp/ephemeral/',
        'test/fixtures/key.pem'
      ).then (res) ->
        res.should.eql([
          crx: "/tmp/ephemeral/test-with-config.crx"
          description: "Test1 description"
          name: "test-with-config"
          icon: null
          author: null
          sourcePath: path.join(extDir, "test1", "build")
          version: "0.9"
        ])
        packer.pack.should.have.been.calledOnce
        packer.pack.should.have.been.calledWith(
          path.join(extDir, "test1", "build"),
          'test/fixtures/key.pem',
          '/tmp/ephemeral/test-with-config.crx')
