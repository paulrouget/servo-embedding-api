interface PipelinePreview {
  /* how to hook pipeline preview with viewport? */
}

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

enum DocumentState {
  "pending", // Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive
  "error", // Couldn't complete connection. 
  // Following values are the same as document.readyState
  "loading", // The document is still loading. (same as document.readyState)
  "interactive", // The document has finished loading and the document has been parsed but sub-resources such as images, stylesheets and frames are still loading. (same as document.readyState)
  "complete", // The document and all sub-resources have finished loading. The state indicates that the load event has been fired. (same as document.readyState)
}

dictionary LoadError {
  USVString finalURL;
  // Chrome error list: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
  unsigned short errorCode;
  // should include crash as well
  DOMString errorDescription;
}

enum SaveRenderingStrategy {
  "none",
  "displaylist",
  "texture",
}

interface Pipeline {

  readonly attribute USVString url; // Event: url-changed. Happens during redirects for example. FIXME: should that be finalURL ? How often would that change?
  readonly attribute DOMString title; // Event: title-changed
  readonly attribute unsigned short HTTPResponse;

  // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
  // Use performance for time stamps.
  readonly attribute DocumentState? documentState; // Event: document-state-changed. Undefined if isPending or connection error. See Document.webidl
  readonly attribute Performance performance; // See Performance.webidl and PerformanceTiming.webidl

  readonly attribute FrozenList<USVString> icons; // Event: icons-changed
  readonly attribute FrozenList<MetaTag> metas; // Event: metas-changed. only <meta name="…" content="…">
  readonly attribute String? hoveredLink; // Event: hovered-link-changed.
  readonly attribute ConnectionSecurity connectionSecurity; // Event: security-changed

  readonly attribute boolean isFrozen; // Event: freeze and thaw. Pipeline has been frozen. The user navigated away for example.

  readonly attribute unsigned float devicePixelRatio; // Event: device-pixel-ratio-changed


  Promise<unsigned float> setDevicePixelRatio(unsigned float ratio);

  readonly attribute SaveRenderingStrategy saveRenderingStrategy;
  Promise<void> setSaveRenderingStrategy(SaveRenderingStrategy);

  void stopLoad();
  void reload(); // FIXME: will that create a new pipeline? https://github.com/servo/servo/issues/13123
  void clearCacheAndReload();

  Promise<void> insertCSS(DOMString code);

  // FIXME: what about WebContents::session?


  // FIXME: save
  // FIXME: what about WebContents::beginFrameSubscription

  // FIXME: InputEvents forwarding. How to?

  // FIXME: next: cover WebContents.webidl

  // FIXME:
  readonly attribute LoadError loadError; // document-state-changed -> documentState == "error".
  // pipeline health: crash or not
  // connection health: connection to http server success?
  // http health: status code

  // FIXME: content script and CSS strategy:
  // - how to communicate back?
  // - special privileges?
  // - postMessage?
  // See https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Anatomy_of_a_WebExtension#Content_scripts
  // Also: how to publish webaccessibleResources? https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Anatomy_of_a_WebExtension#Web_accessible_resources
  // Also see https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/Tabs/executeScript
  // Electron says:
  //
  //   Evaluates code in page. If userGesture is set, it will create the user
  //   gesture context in the page. HTML APIs like requestFullScreen, which
  //   require user action, can take advantage of this option for automation.
  //   void executeJavaScript(DOMString code,
  //                          boolean userGesture /* pretend user-triggered action */,
  //                          Function callback);

  void executeScript(/*FIXME*/); // code or/and url
  void loadCSS(/* FIXME */);
  // FIXME: Manipulate cookies (web extensions requirement)
  // See: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/cookies
  void getScreenshot();
  void download(USVString url, optional DownloadOptions options);

  /*
    oncontextmenu
    usernameandpasswordrequired
    showmodalprompt
    requestFullScreen 
    leaveFullScreen

    will-destroy
    focus-changed


    // Fired when the guest window logs a console message.
    dictionary ConsoleMessageEventDetail {
      // type: ‘console-message’
      // not in webContents
      // not cancellable
      Number level;
      String message;
      Number line;
      String sourceId;
    }


  */
  
}

Pipeline implements Searchable;
Pipeline implements HttpObserverManager;
Pipeline implements Editable;
Pipeline implements MultimediaManager;
