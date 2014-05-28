Kitt Development Server
=======================

**Consult Kitt online documentation of Chrome functionality subset. It does not support full manifest format neither `chrome.*` APIs, but we are adding new features frequently.**

[https://github.com/kitt-browser/dev-docs](https://github.com/kitt-browser/dev-docs) 

-----------

1. `git checkout https://github.com/kitt-browser/dev-server.git`
2. `cd dev-server`
3. `npm install`
4. `npm start` (default port is 3000, you can change it by setting `PORT` env
   var)

**Then in `exts` subfolder**:

1. Make a subfolder for your addon. Please don't use whitespaces in the folder
   name. You can use a symlink too.

2. Start creating your addon in the folder as you would a Chrome extension.
   
3. Server will observe your folder and re-pack the extension everytime you make a
   change (please note that changes in `.git` and `node_modules` directories
   are ignored in order to prevent too many files from being watched).

4. Server gives you two links:
     * Install: use in Kitt browser
     * Download: get the CRX file generated on the fly

5. The website is updated automatically whenever anything changes so there's no
   need to reload.

### Setting `EXTENSION_DIR_ROOT`
If you don't want to use `exts/` subfolder to develop your extensions, you can
set the `EXTENSION_DIR_ROOT` environmental variable and point it to the absloute
of a folder where your extensions subfolders are stored.

## IMPORTANT!

**PROVIDED KEY.PEM IS ONLY FOR INITIAL TESTING!**

**REPLACE WITH YOUR OWN PRIVATE KEY!**


## Optional per-extension configuration
If you wish to override the default configuration for your extension (for
example because you want to preprocess your source code and build into .e.g.
`build/` directory) you can add a `kitt.yml` file into your extension
directory (it has to be in your extension directory root).

Available options:

 * `buildDir`: subdirectory of your extension directory which should be watched
   for changes instead of root. The CRX packer will pack the contents of this
   directory when change is detected.
   
