typedef USVString URL;

interface PipelineInitData {
  readonly attribute boolean isPrivate;
  readonly attribute ViewPortDimension viewportDimension;
  readonly attribute BrowsingContext browsingContext;
  readonly attribute LoadData loadData;
}

interface PipelinePreview {
  /* how to hook pipeline preview with viewport? */
}

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

interface UnprivilegedPipeline {
}

interface Pipeline {

  readonly attribute ConnectionSecurityState connectionSecurityState;

  attribute float devicePixelRatio;

  readonly attribute DOMString id;
  readonly attribute DOMString BrowsingContextId;

  readonly attribute boolean isPrivate; // Here or in browsing context?

  /* Audio ? */

  readonly attribute boolean isPending;
  readonly attribute boolean isFrozen;
  readonly attribute boolean isActive; // A preloading pipeline can be non frozen and non visible

  readonly attribute URL url;
  readonly attribute DOMString title;
  readonly attribute DocumentReadyState doumentReadyState;
  readonly attribute URL[] icons;
  readonly attribute MetaTag[] metas; // only <meta name="…">
  readonly attribute String? hoveredLnk;

  readonly attribute SecurityState securityState;


  void reload();
  void stopLoad();
  void clearCacheAndReload();
  void download(URL url, optional DownloadOptions options);

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
