path = require('path')

module.exports = {
  extensions:
    root: path.join(__dirname, '..', 'test/fixtures/exts')
    privateKey: path.join(__dirname, '..', 'test', 'fixtures', 'key.pem')
}
