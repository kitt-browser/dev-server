path = require('path')

module.exports = {
  extensions:
    root: path.join(__dirname, 'exts')
    privateKey: path.join(__dirname, 'exts', 'key.pem')
}
