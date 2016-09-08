// STATUS: draft

/**
  * Browser is the equivalent of a top level Constellation::Frame.
  * Browser is a top level browsing context.
  * Browser can be seen like a tab.
  */

typedef PreloadingPipelineID = unsigned long;

[Constructor(DOMString contextName, boolean isPrivateBrowsing)]
interface Browser {

  // FIXME: non linear entries. entries editing.
  // FIXME: not sure focus and visibilty should handled here
  // FIXME: how is this attached to a viewport?
  // FIXME: do we actually want to give access to autopurge and maxLivePipeline?

  // Can't be changed after browsing context creation
  readonly attribute DOMString browsingContextName = "";
  readonly attribute boolean isPrivateBrowsing; 

  // This can be used for session restore
  // On success, historyEntries is filled, active entry's pipeline is pending.
  // If necessary, other pipelines can be restored via HistoryEntry::restorePipeline()
  // Will fail entries already exist
  Promise<void> restoreEntries(Sequence<LoadData> data, unsigned long activeIndex);

  readonly attribute FrozenList<HistoryEntry> historyEntries;
  readonly attribute unsigned long activeEntryIndex;

  // FIXME: Is that a thing we want to give control over?
  readonly attribute boolean autoPurgePipelines;
  Promise<void> setAutoPurgePipelines(boolean auto);
  readonly attribute unsigned long maxLivePipelines;
  Promise<void> setMaxLivePipelines(unsigned long max);

  // Popup blocker, tracking content blocker, mixed content blocker,
  // and safari-like content blocker. See ContentBlockers.webidl
  readonly attribute USVString customContentBlockerURL;
  Promise<void> setCustomContentBlockerURL(USVString url);
  readonly attribute Sequence<ContentBlockerType> defaultContentBlockers;
  Promise<void> setDefaultContentBlockers(Sequence<ContentBlockerType>);

  // Use to load a new URL. will create a new pipeline and navigate to the
  // pipeline once not pending
  Promise<HistoryEntry> navigate(LoadData loadData, optional Pipeline opener);

  // Will fail if Browser.isPrivateBrowsing != pipeline.isPrivateBrowsing
  Promise<HistoryEntry> navigateToPipeline(Pipeline pipeline, optional Pipeline opener);

  Promise<PreloadingPipelineID> preloadPipeline(LoadData loadData);
  Promise<void> cancelPreloadingPipeline(PreloadingPipelineID id);
  Promise<HistoryEntry> navigateToPreloadingPipeline(PreloadingPipelineID id);

  readonly attribute boolean isFocused;

  // Only used to slow down timers and not call rAF. Think background tabs.
  readonly attribute boolean isVisible;
  Promise<void> setVisible(boolean visible);

  readonly attribute Object prefs;
  Promise<void> setPrefs(Object prefs); // use to set user-agent for example
}

Browser implements EventEmitter;

interface BrowserActiveEntryChangedEvent : CancelableEvent {
  // A new document is displayed. Usually after the user
  // clicked on a link and once the new document has been
  // created (pipeline is not pending anymore).
  const DOMString type = "active-entry-changed";
  const boolean cancelable = false;
}

interface BrowserWillNavigateEvent : CancelableEvent {
  const DOMString name = "will-navigate";
  const boolean cancelable = true;
  USVString url;
}

interface BrowserWillCloseEvent: CancelableEvent {
  // When window.close() is called
  const DOMString name = "will-destroy";
  const boolean cancelable = true;
}

interface BrowserVisibilityChanged : CancelableEvent {
  const DOMString name = "visible-changed";
  const boolean cancelable = false;
}

interface BrowserFocusChanged : CancelableEvent {
  const DOMString name = "focus-changed";
  const boolean cancelable = false;
}

interface BrowserDestroyedEvent : CancelableEvent {
  const String type = "destroyed";
  const boolean cancelable = false;
}
