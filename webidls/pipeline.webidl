interface PipelinePreview {
  /* how to hook pipeline preview with viewport? */
}

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

interface UnprivilegedPipeline {
  // FIXME: Things that can be used by content script.
}

interface Pipeline : UnprivilegedPipeline {

  readonly attribute USVString url; // Event: url-changed. Happens during redirects for example.
  readonly attribute DOMString title; // Event: title-changed

  // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
  // Use performance for time stamps.
  readonly attribute DocumentReadyState? documentReadyState; // Event: readystate-changed. Undefined if isPending or connection error. See Document.webidl
  readonly attribute Performance performance; // See Performance.webidl and PerformanceTiming.webidl

  readonly attribute FrozenList<USVString> icons; // Event: icons-changed
  readonly attribute FrozenList<MetaTag> metas; // Event: metas-changed. only <meta name="…" content="…">
  readonly attribute String? hoveredLink; // Event: hovered-link-changed.
  readonly attribute ConnectionSecurity connectionSecurity; // Event: security-changed

  readonly attribute boolean isPrivate; // Won't change. FIXME: Here or in browsing context?
  readonly attribute boolean isPending; // Event: readystate-changed. Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive
  readonly attribute boolean isFrozen; // Event: freeze and thaw. Pipeline has been frozen. The user navigated away for example.

  readonly attribute unsigned float devicePixelRatio; // Event: device-pixel-ratio-changed


  Promise<unsigned float> setDevicePixelRatio(unsigned float ratio);

  void stopLoad();
  void reload(); // FIXME: will that create a new pipeline? https://github.com/servo/servo/issues/13123
  void clearCacheAndReload();

  // FIXME: what about WebContents::session?


  // FIXME: save
  // FIXME: what about WebContents::beginFrameSubscription

  // FIXME: InputEvents forwarding. How to?

  // FIXME: next: cover WebContents.webidl

  // FIXME:
  readonly attribute ConnectionError connectionError; // connection-error
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
  void executeScript(/*FIXME*/); // code or/and url
  void loadCSS(/* FIXME */);
  // FIXME: Manipulate cookies (web extensions requirement)
  // See: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/cookies
  void getScreenshot();
  void download(USVString url, optional DownloadOptions options);

  /*
    Audio ?
    oncontextmenu
    onerror
    usernameandpasswordrequired
    showmodalprompt
  */
  
}

Pipeline implements Searchable;
Pipeline implements HttpObserverManager;
Pipeline implements Editable;
Pipeline implements MultimediaManager;
