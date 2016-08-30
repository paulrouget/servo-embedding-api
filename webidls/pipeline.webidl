interface PipelinePreview {
  /* how to hook pipeline preview with viewport? */
}

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

interface UnprivilegedPipeline {
  // Things that can be used by content script.
}

interface Pipeline {
  readonly attribute ConnectionSecurityState connectionSecurityState;
  readonly attribute boolean isPrivate; // Here or in browsing context?
  readonly attribute boolean isPending; // Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive
  readonly attribute boolean isActive; // Is alive. The current document of a frame.

  attribute float devicePixelRatio;

  /* Audio ? */

  readonly attribute USVString url;
  readonly attribute DOMString title;
  readonly attribute DocumentReadyState doumentReadyState; // See Document.webidl
  readonly attribute Sequence<USVString> icons;
  readonly attribute Sequence<MetaTag> metas; // only <meta name="…" content="…">
  readonly attribute String? hoveredLink;

  readonly attribute SecurityState securityState;


  void reload();
  void stopLoad();
  void clearCacheAndReload();
  void download(USVString url, optional DownloadOptions options);

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

  ontitlechanged;
  onurlchanged;
  oniconschanged;
  onmetachanged;

  /*
    is getScreenshot() necessary
    onlinkhovered
    onfrozen onthaw;
    onactive onunactive: entry or pipeline?
    onsecuritystatechange;
    oncontextmenu
    onerror
    usernameandpasswordrequired
    showmodalprompt
    selectionstatechanged

    performance:
      DOM performance timing API
      a process/manager:
        CPU/Mem
        nice
  */
  
}

Pipeline implements Searchable;
Pipeline implements HttpObserverManager;
