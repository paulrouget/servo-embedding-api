// FIXME: most of this API is only usable for non-frozen pipelines
// so why don't we only give access to "current pipeline" instead of
// all different pipelines?
// FIXME: maybe list frozen-compatible methods?
// FIXME: what about WebContents::beginFrameSubscription
// FIXME: InputEvents forwarding. How to?

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

enum WindowDisposition {
  "foreground-tab",
  "background-tab",
  "new-window";
}

enum PromptType {
  "alert",
  "confirm"
}

enum PipelineState {
  "pending", // Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive // FIXME: not sure we will ever have access to a pending pipeline
  "error", // Couldn't complete HTTP connection. Servo should not redirect to an error page. This should be handled client side.
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

dictionary PipelineError { // crash reports, DNS/TCP errors, … Not HTTP error (see Pipeline.HTTPResponse).
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

interface TopPipeline : Pipeline {
  readonly attribute String? hoveredLink;
  readonly attribute ConnectionSecurity connectionSecurity;
  readonly attribute boolean isFrozen;
  readonly attribute boolean isVisible;

  // Prerendering a document. HTTP + layout, no JS. Lot of things to consider. See:
  // https://bugzilla.mozilla.org/show_bug.cgi?id=730101
  // Will be rendered once Browser.navigateToPipeline() is called.
  // Created via Browser.createPrerenderingPipeline()
  readonly attribute boolean isPrerender;
  Promise<void> cancelPrerenderAndRequestDestruction();


  // We want to be able to render frozen pipeline, so we need
  // a way to save the rendering.
  // FIXME: do we really want to let the client handle that?
  readonly attribute SaveRenderingStrategy saveRenderingStrategy;
  Promise<void> setSaveRenderingStrategy(SaveRenderingStrategy);

  Promise<Blob> capturePage(Rect source, Rect destination); // Works even for frozen pipelines

  Promise<Blob> savePage(SaveType saveType);

  Promise<Blob> downloadURL(USVString url);

  Promise<Sequence<ContentBlocker>> getContentBlockers(ContentBlockerType type);

  Printable asPrintable();
  Editable asEditable();
  Findable asFindable();
  MultimediaManager asMultimediaManager();
  HTTPObserverManager asHTTPObserverManager();
}

interface Pipeline {

  Promise<void> setPipelineHandler(PipelineHandler handler);

  readonly attribute USVString url; // Happens during redirects for example. FIXME: should that be finalURL ? How often would that change?
  readonly attribute DOMString title;
  readonly attribute unsigned short HTTPResponse;

  // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
  // Use performance for time stamps.
  readonly attribute PipelineState? pipelineState;
  readonly attribute Performance performance; // See Performance.webidl and PerformanceTiming.webidl // FIXME: should probably be getPerformance(). Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
  readonly attribute PipelineError pipelineError; // pipeline-state-changed -> pipelineState == "error" || "crash". // FIXME: is "crash" necessary? // FIXME: so generic…

  readonly attribute FrozenArray<USVString> icons;
  readonly attribute FrozenArray<MetaTag> metas;

  void stopLoading();

  // Will destroy that pipeline and create a new one
  void reload();
  void clearCacheAndReload();

  Promise<void> insertCSS(DOMString code);

  Promise<Object> evaluateScript(DOMString script, boolean onlyForFrameScript);
  Promise<Object> evaluateScriptFromURL(USVString url, boolean onlyForFrameScript);

}


dictionary ContextMenuDetails {
  long x;
  long y;
  // FIXME: http://electron.atom.io/docs/api/web-contents/#event-context-menu
}

dictionary ConsoleMessageDetails {
  unsigned short level;
  DOMString message;
  unsigned long line;
  DOMString sourceId;
}

interface PipelineHandler {
  Cancelable onNewWindow(WindowDisposition disposition, LoadData loadData, DOMString frameName);
  Cancelable onContextMenu(ContextMenuDetails options);
  void onURLChanged();
  void onTitleChanged();
  void onPipelineStateChanged();
  void onCrash(PipelineError error);
  void onIconsChanged();
  void onMetasChanged();
  void onHoveredLinkChanged();
  void onConnectionSecurity();
  void onFreeze();
  void onThaw();
  void onVisibleChanged();
  void onDevicePixelRatioChanged();
  Cancelable onFullscreenRequested();
  Cancelable onExitFullscreenRequest();
  void onConsoleMessage(ConsoleMessageDetails message);
  // It's possible to cancel navigation. For example, pin
  // tabs might want to open links from different domain
  // into a different tab.
  Cancelable onWillNavigate(LoadData loadData);

  // FIXME: More things!
  // FIXME: See BrowserElementPromptService.jsm:confirmEx implementation
  Cancelable onUsernameAndPasswordRequired(
    Callback authenticate /*(user, pw)*/,
    Callback cancel);

  Cancelable onShowModalPrompt(
    PromptType type,
    DOMString title,
    DOMString message,
    Callback done /*(returnValue)*/);

  Cancelable onCertificateError(
    DOMString error,
    CertificateInfo certificate,
    Callback accept,
    Callback reject);

  void onDestroy(LoadData loadData);
};
