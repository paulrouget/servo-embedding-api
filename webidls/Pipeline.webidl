// STATUS: almost draft

interface PipelinePreview {
  /* how to hook pipeline preview with viewport? */
}

// FIXME: Pipeline should implement all or part of LoadData

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

enum DocumentState {
  "pending", // Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive
  // FIXME: there will be a redirect, so these will never happen
  "error", // Couldn't complete connection. 
  "crash", // Pipeline crashed
  // Following values are the same as document.readyState
  "loading", // The document is still loading. (same as document.readyState)
  "interactive", // The document has finished loading and the document has been parsed but sub-resources such as images, stylesheets and frames are still loading. (same as document.readyState)
  "complete", // The document and all sub-resources have finished loading. The state indicates that the load event has been fired. (same as document.readyState)
}

enum SaveType {
  "HTMLOnly", // Save only the HTML of the page.
  "HTMLComplete", // Save complete-html page.
  "MHTML", // Save complete-html page as MHTML.
}

dictionary LoadError { // Also used for crash reports
  USVString finalURL;
  // Chrome error list: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
  unsigned short code;
  DOMString description; // Human readable
  optional DOMString report; // Backtrace for panics
}

enum SaveRenderingStrategy {
  "default",
  "displaylist",
  "texture",
}

// Using the constructor will create an orphan pipeline
// FIXME: describe how different a preloading pipeline is
// FIXME: explain orphan
[Constructor(LoadData loadData, boolean isPrivateBrowsing, boolean isPreload)]
interface Pipeline {

  readonly attribute boolean isMixedContentAllowed; // Default set via LoadData
  readonly attribute boolean isTrackingContentAllowed; // Default set via LoadData

  readonly attribute boolean isOrphan;

  readonly attribute boolean isPreload;
  Promise<void> cancelPreloadAndRequestDestruction();

  // FIXME: related events:
  Promise<void> setMixedContentAllowed(boolean allowed);
  Promise<void> setTrackingContentAllowed(boolean allowed);

  readonly attribute USVString url; // Event: url-changed. Happens during redirects for example. FIXME: should that be finalURL ? How often would that change?
  readonly attribute DOMString title; // Event: title-changed
  readonly attribute unsigned short HTTPResponse;

  // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
  // Use performance for time stamps.
  readonly attribute DocumentState? documentState; // Event: document-state-changed. Undefined if isPending or connection error. See Document.webidl
  readonly attribute Performance performance; // See Performance.webidl and PerformanceTiming.webidl // FIXME: should probably be getPerformance(). Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem

  readonly attribute FrozenList<USVString> icons; // Event: icons-changed
  readonly attribute FrozenList<MetaTag> metas; // Event: metas-changed. only <meta name="…" content="…">
  readonly attribute String? hoveredLink; // Event: hovered-link-changed.
  readonly attribute ConnectionSecurity connectionSecurity; // Event: security-changed

  readonly attribute boolean isFrozen; // Event: freeze and thaw. Pipeline has been frozen. The user navigated away for example.

  readonly attribute boolean isVisible; // Event: "visibility". Set from Browser

  readonly attribute unsigned float devicePixelRatio; // Event: device-pixel-ratio-changed


  Promise<unsigned float> setDevicePixelRatio(unsigned float ratio); // Will fail for non-top level pipelines

  readonly attribute SaveRenderingStrategy saveRenderingStrategy; // FIXME: how is that set?
  Promise<void> setSaveRenderingStrategy(SaveRenderingStrategy);

  void stop();
  void reload(); // Will destroy that pipeline and create a new one
  void clearCacheAndReload();

  Promise<Blob> downloadURL(USVString url); // FIXME: HTTPObserver

  Promise<void> insertCSS(DOMString code);

  Promise<Blob> capturePage(Rect source, Rect destination); // Works even for frozen pipelines

  Promise<void> savePage(DOMString fullPath, SaveType saveType);

  Promise<ContentBlocker> getContentBlocker(ContentBlockerType type);

  Promise<LoadData> buildLoadData();

  Promise<Browser> getBrowser(); // Access to iframes. FIXME: Do we really want that?

  // FIXME: what about WebContents::session?


  // FIXME: save
  // FIXME: what about WebContents::beginFrameSubscription

  // FIXME: InputEvents forwarding. How to?

  // FIXME: next: cover WebContents.webidl

  // FIXME:
  readonly attribute Error error; // document-state-changed -> documentState == "error" || "crash". // FIXME: is "crash" necessary? // FIXME: so generic…
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
  // FIXME: … and what about any other offline storage?
  // See: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/cookies
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
      // not cancelable
      Number level;
      String message;
      Number line;
      String sourceId;
    }


  */

}

Pipline implements EventEmitter;

enum WindowDisposition {
  "foreground-tab",
  "background-tab",
  "new-window";
}

interface PipelineNewWindowEvent : CancelableEvent {
  const DOMString name = "new-window";
  const boolean cancelable = true;

  WindowDisposition disposition;
  LoadData loadData;
  // FIXME: here we should have a LoadData, not referrer & co
  DOMString frameName;
}

interface PipelineCrashEvent : CancelableEvent {
  // FIXME: is it necessary as documentState changed to "crash"?
  const DOMString name = "crash";
  const boolean cancelable = false;
  // See pipeline.loadError
};

interface PipelineAttachedEvent : CancelableEvent {
  // When attached to Browser
  const DOMString name = "attached";
  const boolean cancelable = false;
}:

interface PipelineContextMenuEvent : CancelableEvent {
  const DOMString name = "context-menu";
  const boolean cancelable = false;

  // FIXME: overlap with editable

  long x; // x coordinate
  long y; // - y coordinate
  USVString linkURL; // - URL of the link that encloses the node the context menu was invoked on.
  USVString linkText; // - Text associated with the link. May be an empty string if the contents of the link are an image.
  USVString frameURL; // - URL of the subframe that the context menu was invoked on.
  USVString srcURL; // - Source URL for the element that the context menu was invoked on. Elements with source URLs are images, audio and video.
  DOMString mediaType; // - Type of the node the context menu was invoked on. Can be none, image, audio, video, canvas, file or plugin.
  boolean hasImageContents; // - Whether the context menu was invoked on an image which has non-empty contents.
  boolean isEditable; // - Whether the context is editable.
  DOMString selectionText; // - Text of the selection that the context menu was invoked on. // FIXME: is that necessary? As pipeline implement Editable, this information is accessible. But what about iframes…
  DOMString titleText; // - Title or alt text of the selection that the context was invoked on.
  DOMString misspelledWord; // - The misspelled word under the cursor, if any. // FIXME: editable again
  DOMString frameCharset; // - The character encoding of the frame on which the menu was invoked.
  DOMString inputFieldType; // - If the context menu was invoked on an input field, the type of that field. Possible values are none, plainText, password, other.
  DOMString menuSourceType; // - Input source that invoked the context menu. Can be none, mouse, keyboard, touch, touchMenu.
  MediaFlags mediaFlags; // - The flags for the media element the context menu was invoked on. See more about this below.
  EditFlags editFlags; // - These flags indicate whether the renderer believes it is able to perform the corresponding action. See more about this below.
};


Pipeline implements FindInPage;
Pipeline implements HTTPObserverManager;
Pipeline implements Editable;
Pipeline implements MultimediaManager;
