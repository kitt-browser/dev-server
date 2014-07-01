path = require('path')

module.exports = {
  extensions:
    root: process.env.EXTENSION_DIR_ROOT or path.join(__dirname, '..', 'test/fixtures/exts')
    privateKey: path.join(__dirname, '..', 'test', 'fixtures', 'key.pem')
}
