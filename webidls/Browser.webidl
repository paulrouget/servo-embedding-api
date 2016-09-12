// STATUS: draft

/**
  * Browser is the equivalent of a top level Constellation::Frame.
  * Browser is a top level browsing context.
  * Browser can be seen like a tab.
  */

[Constructor(DOMString contextName, Session session)]
interface Browser : WeakRef {

  // FIXME: not sure focus should be handled here
  // FIXME: how is this attached to a viewport? For swapping, it's important to be able to attacha and detach
  // FIXME: do we want to give access to autopurge and maxLivePipeline?

  // Can't change after browser creation
  readonly attribute DOMString browsingContextName; // FIXME
  readonly attribute Session session;

  // This can be used for session restore, or to undo tab-close.
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
  // FIXME: not cool. We can't have multiple custom blockers.
  readonly attribute USVString customContentBlockerURL;
  Promise<void> setCustomContentBlockerURL(USVString url);
  readonly attribute Sequence<ContentBlockerType> defaultContentBlockers;
  Promise<void> setDefaultContentBlockers(Sequence<ContentBlockerType>);

  // Use to load a new URL. will create a new pipeline and navigate to the
  // pipeline once not pending
  Promise<HistoryEntry> navigate(LoadData loadData, optional Pipeline opener);

  // Will fail if Browser.session != pipeline.session.
  // Useful with preloading pipelines
  Promise<HistoryEntry> navigateToPipeline(Pipeline pipeline, optional Pipeline opener);

  readonly attribute boolean isFocused;

  // FIXME: can we do without prefs?
  readonly attribute Object prefs;
  Promise<void> setPrefs(Object prefs); // use to set user-agent for example
}

Browser implements EventEmitter;

interface BrowserActiveEntryDiDChangeEvent : CancelableEvent {
  // A new document is displayed. Usually after the user
  // clicked on a link and once the new document has been
  // created (pipeline is not pending anymore). Also happens
  // when user or page goes back/forward.
  const DOMString type = "active-entry-did-change";
  const boolean cancelable = false;
}

interface BrowserWillNavigateEvent : CancelableEvent {
  // It's possible to cancel navigation. For example, pin
  // tabs might want to open links from different domain
  // into a different tab.
  // FIXME: shouldn't that be at the pipeline level?
  const DOMString name = "will-navigate";
  const boolean cancelable = true;
  LoadData loadData;
}

interface BrowserWillCloseEvent: CancelableEvent {
  // When window.close() is called
  const DOMString name = "will-destroy";
  const boolean cancelable = true;
}

interface BrowserFocusDidChange : CancelableEvent {
  const DOMString name = "focus-did-change";
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
// maintain an alternate history structure.

partial interface Browser {
  // Will drop the back and forward entries and replace with new ones.
  // At that point, all pipelines are killed. Only the current one stays
  // alive.
  Promise<void> replaceEntriesButCurrent(Sequence<LoadData> pastLoadData, Sequence<LoadData> futureLoadData);
}

interface BrowserForwardHistoryBranchDidDropEvent : CancelableEvent {
  // This happens on goBack + navigate, and when replaceEntriesButCurrent is
  // called. The forward list of entries is dropped. This event comes with a
  // list of LoadData object that can be used to restore the branch if
  // necessary.
  const DOMString type = "forward-history-branch-did-drop";
  const boolean cancelable = false;
  Sequence<LoadData> droppedEntriesAsLoadData;
}
