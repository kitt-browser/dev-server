Kitt Development Server
=======================

**Consult Kitt online documentation of Chrome functionality subset. It does not support full manifest format neither `chrome.*` APIs, but we are adding new features frequently.**

[https://github.com/kitt-browser/dev-docs](https://github.com/kitt-browser/dev-docs) 

-----------

1. `git checkout https://github.com/kitt-browser/dev-server.git`
2. `cd dev-server`
3. `npm install`
4. `node app [port]` (default 80)

**Then in `exts` subfolder**:

1. Make a subfolder for your addon. The addon bundle (download) will be named
   as the folder, so be reasonable about the name. No spaces and wild chars.

2. Start creating your addon in the folder as you would a Chrome extension.
   
3. server will observe your folder and adjust the internal database whenever
   you change the manifest file. Changes in other files are ignored and files
   are effectively used only when you ask for installation

4. server gives you two links:
     Install: use in Kitt browser
     Download: get the CRX file generated on the fly
   
**PROVIDED KEY.PEM IS ONLY FOR INITIAL TESTING!**

**REPLACE WITH YOUR OWN PRIVATE KEY!**
