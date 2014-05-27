Q = require('q')
qfs = require('q-io/fs')
path = require('path')
glob = Q.denodeify require('glob').glob
packer = require('./packer')
debug = require('debug')('kitt-dev:extensions')
yaml = require('js-yaml')
_ = require('underscore')


defaultExtensionConfig = require('./extConfigDefaults')


# Load all extensions in `dir`, turn them into `.crx` files, store in `crxDir`
# and return the metadata.
loadExtensions = (dir, crxDir, privateKey) ->
  debug 'loading extensions from', dir

  # We assume each subdirectory equals one extension.
  qExtensionsMetadata = _getSubdirs(dir).then (subdirs) ->
    # Return a promise for an array of extension metadata.
    Q.allSettled subdirs.map (extDir) ->
      debug('Loading extension dir', extDir)
      loadExtension(extDir, crxDir, privateKey)
        .fail (err) ->
          # Just print an error and ignore the extension.
          debug("Failed to process extension #{extDir}", err)
          return Q.reject(err)
  qExtensionsMetadata = qExtensionsMetadata.then (items) ->
    return (item.value for item in items when item.state == 'fulfilled')

  return qExtensionsMetadata
    

# Packes the extension in `extRootDir` into crx in  `crxDir`.
# Returns extension metadata object.
loadExtension = (extRootDir, crxDir, privateKey) ->
  extBuildDir = null
  crxFile = null
  manifest = null

  qCfg = _getExtensionConfig(extRootDir)
    
  # Load `manifest.json` to get extension metadata.
  qManifest = qCfg.then (cfg) ->
    debug('config loaded for %s', extRootDir)
    extBuildDir = path.join(extRootDir, cfg.buildDir)
    # TODO: Run minification, JSHint etc.
    _readManifest(extBuildDir)

  # Create the `crx` file.
  qPackingDone = qManifest.then (_manifest) ->
    debug('manifest loaded for %s', extRootDir, crxDir)
    manifest = _manifest
    crxFile = path.join(crxDir, "#{manifest.name}.crx")
    packer.pack(extBuildDir, privateKey, crxFile)

  # Compile the extension metadata.
  qMetadata = qPackingDone.then ->
    icon = _.values(manifest.icons)[0]
    if not icon
      iconUrl = null
    else
      iconUrl = path.resolve(path.join(extBuildDir, icon))
    return {
      name: manifest.name
      author: manifest.author or null
      version: manifest.version
      icon: iconUrl
      description: manifest.description
      sourcePath: path.resolve(extBuildDir)
      crx: crxFile
    }

  # Log failures.
  qMetadata.fail (err) ->
    debug("Error loading extension from #{extRootDir}", err)
    Q.reject err

  return qMetadata


# Returns promise for an array of all (nonhidden) direct subdirs of `dir`.
_getSubdirs = (dir) ->
  subdirs = []
  promise = qfs.listTree dir, (path, stat) ->
    if path == dir
      # Recurse into `dir` (i.e., the directory we're traversing). Stupid? Yes
      # but that's how `q-io/fs` works.
      return true
    if (stat.isDirectory() && path[0] != '.')
      subdirs.push path
    # Return `null` => Do not recurse into subdirectories.
    return null
  return promise.then -> subdirs


# Returns promise for JS object read from `manifest.json` in `dir`.
_readManifest = (dir) ->
  manifest = path.join(dir, 'manifest.json')
  qfs.read(manifest).then JSON.parse


# Returns promise for extension specific configuration (`kitt.yml`
# merged with defaults).
_getExtensionConfig = (extDir) ->
  cfgFile = path.join(extDir, 'kitt.yml')
  qfs.exists(cfgFile)
    # Load `kitt.yml` or `{}` if there's none.
    .then (exists) ->
      if exists then qfs.read(cfgFile).then(yaml.safeLoad) else {}
    # Set undef values to defaults.
    .then (cfg) ->
      _.defaults(cfg, defaultExtensionConfig)


exports.loadExtensions = loadExtensions
