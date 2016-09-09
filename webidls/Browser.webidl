// STATUS: draft

/**
  * Browser is the equivalent of a top level Constellation::Frame.
  * Browser is a top level browsing context.
  * Browser can be seen like a tab.
  */

[Constructor(DOMString contextName, boolean isPrivateBrowsing)]
interface Browser {

  // FIXME: non linear entries. entries editing.
  // FIXME: not sure focus and visibilty should be handled here
  // FIXME: how is this attached to a viewport? For swapping, it's important to be able to attacha and detach
  // FIXME: do we actually want to give access to autopurge and maxLivePipeline?

  // Can't be changed after browsing context creation
  readonly attribute DOMString browsingContextName;
  readonly attribute boolean isPrivateBrowsing; 

  // This can be used for session restore.
  // On success, historyEntries is filled, active entry's pipeline is NOT pending.
  // If necessary, other pipelines can be restored via HistoryEntry::restorePipeline()
  // Will fail if entries already exist
  Promise<void> restoreEntries(Sequence<LoadData> data, unsigned long activeIndex);

  readonly attribute FrozenList<HistoryEntry> historyEntries;
  readonly attribute unsigned long activeEntryIndex;
  Promise<void> setActiveEntryIndex(unsigned long);

  // Purging means killing the pipeline. The entry stays intact
  readonly attribute boolean doPipelinesAutopurge;
  // Maximum number of live pipeline before and after the current entry
  Promise<void> enableAutoPurgePipelines(unsigned long before, unsigned long after);
  Promise<void> disableAutoPurgePipelines();

  // Popup blocker, tracking content blocker, mixed content blocker,
  // and safari-like content blocker. See ContentBlockers.webidl
  readonly attribute USVString customContentBlockerURL;
  Promise<void> setCustomContentBlockerURL(USVString url);
  readonly attribute Sequence<ContentBlockerType> defaultContentBlockers;
  Promise<void> setDefaultContentBlockers(Sequence<ContentBlockerType>);

  // Use to load a new URL. will create a new pipeline and navigate to the
  // pipeline once not pending
  Promise<HistoryEntry> navigate(LoadData loadData, optional Pipeline opener);

  // Will fail if Browser.isPrivateBrowsing != pipeline.isPrivateBrowsing.
  // Useful with preloading pipelines
  Promise<HistoryEntry> navigateToPipeline(Pipeline pipeline, optional Pipeline opener);

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
  const DOMString type = "destroyed";
  const boolean cancelable = false;
}

// EXPERIMENTAL AND TEMPORARY

// Below event and interface are not optimized for performance but for ease of
// implementation.
// 
// The goal it to be able to experiment with non-linear history. Entries are
// stored in an array. When a user goes back in the history and then navigates,
// the previous forward history is dropped. We want to be able to experiment
// with saving that previous forward history, moving from an array structure to
// a tree structure. This goes against the web specifications, and might
// involve intrusive changes in Servo.
//
// The following event and interface are a temporary solution that doesn't
// require much work on Servo's side, and at the same time make it possible to
// build a tree structure at the API consumer level. There are some drawbacks.
// Pipeline's are dropped, only the LoadData is saved, and the consumer has to
// keep an alternate history structure in sync.

partial interface Browser {
  Promise<void> restoreForwardEntries(Sequence<LoadData> loadData);
}

interface BrowserHistoryBranchDeletedEvent : CancelableEvent {
  // This happens on goBack + navigate, and when restoreForwardEntries is
  // called. The forward list of entries is dropped. This event comes with a
  // list of LoadData object that can be used to restore the branch if
  // necessary.
  const DOMString type = "history-branch-deleted";
  const boolean cancelable = false;
  Sequence<LoadData> droppedEntriesAsLoadData;
}
