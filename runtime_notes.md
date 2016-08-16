- Runtime: https://github.com/servo/servo/issues/7379
- Secu model: https://wiki.mozilla.org/FirefoxOS/New_security_model
- packaging for the web: https://w3ctag.github.io/packaging-on-the-web/
- https://github.com/servo/servo/issues/7379
- http://electron.atom.io/docs/tutorial/security/
- asar://  https://github.com/electron/electron/blob/master/docs/tutorial/application-packaging.md
- embedding Strategy on mobile?
- talk to Positron people


Sandbox, security, webview, nodeintegration and Electron
Sandbox doc: https://www.chromium.org/developers/design-documents/sandbox/Sandbox-FAQ and https://www.chromium.org/developers/design-documents/sandbox. Sandbox is per process. Sandboxed process communicates with privileged (not sandboxed) process via pipes.

Electron doesn’t use sandbox because of “node integration”. Also, it was possible to force node integration (security issue). Explanation here: http://blog.scottlogic.com/2016/03/09/As-It-Stands-Electron-Security.html update here: http://blog.scottlogic.com/2016/06/01/An-update-on-Electron-Security.html

Brave managed to enable sandboxing for regular tabs (renderer processes, no node integration). Nodeless renderer processes use content scripts as a replacement for the preload script. No <webview> available I guess.

Electron can’t have Webview without nodeIntegration. NodeIntegration is their “chrome” mode, which is also used to allow creating `<webview>`.


People suggest using a specific protocol scheme (myapp://…) to communicate with privileged code

2 privileged APIs: Desktop, webview. Do we want to be able to use one without the other?


Maybe protocol:// + CSP for security model


adblock, download helper
How to download manager
Session restore
Proxy settings.
devtools
