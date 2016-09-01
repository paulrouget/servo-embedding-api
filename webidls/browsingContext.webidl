typedef PreloadingPipelineID = long;

// FIXME: this feels busy and not very "clear" how entries are added, removed…
// FIXME: reload swaps pipelines

// This can be used for session restore
[Constructor(Sequence<LoadData> entries,
             unsigned long activeIndex,
             boolean restoreAll,
             boolean privateBrowsing,
             optional USVString contentBlockerURL)]
interface BrowsingContext {

  // We want to make sure attributes of browsing context and entries
  // attributes don't overlap.

  readonly attribute FrozenList<HistoryEntry> historyEntries;
  readonly unsigned long activeEntryIndex;

  readonly attribute DOMString? userAgent; // FIXME: could it be set via prefs?
  readonly attribute boolean privateBrowsing;
  readonly attribute boolean isContentBlockingActive;
  readonly attribute boolean isFocused; // Event: "focus-changed"
  
  // FIXME: should we manipulate indexes or HistoryEntry objects?
  void dropEntry(HistoryEntry);
  attribute boolean autoPurgePipelines; // Default yes
  attribute unsigned long historyToKeep; // Default 3
  void insertNewEntry(LoadData data, unsigned long index, boolean active, PipelineID opener); // Use to load a new URL. will create a new pipeline // FIXME: or maybe URL? What's the point of using LoadData if it can only be constructed from URL?

  PreloadingPipelineID preloadPipeline((LoadData or USVString) init);
  void cancelPreloadingPipeline(PreloadingPipelineID id);
  void navigateToPreloadingPipeline(PreloadingPipelineID id);

  readonly attribute boolean allowpopups;
  readonly attribute JSON prefs; // FIXME: JSON type doesn't exist. Object does.
}

BrowsingContext implements EventEmitter;

interface BrowsingContext_EntriesChanged : Event {
  // When one or sereveral entries have been added, moved or removed.
  // FIXME: this is to track the internal mutations of historyEntries.
  // Consumer will have to make a diff internally to find what is new
  // and what has been deleted and moved.
  // Maybe we want to only allow atomic operations with corresponding events:
  // "new-entry" and "entry-dropped" and "splice(…)"
  const String type = "entries-changed";
  const boolean cancelable = false;
}

interface BrowsingContext_ActiveEntryChanged: Event {
  // A new document is displayed. Usually after the user
  // clicked on a link and once the new document has been
  // created (pipeline is not pending anymore).
  // FIXME: is that actually necessary? The consumer is supposed to
  // track any new entry and track if these turns active / inactive.
  const String type = "active-entry-changed";
  const boolean cancelable = false;
}

interface BrowsingContextWillNavigateEvent : BrowsingContextEvent { // FIXME: see PipelineEvent
  const DOMString name = "will-navigate";
  const boolean cancelable = true;
  USVString url;
}

interface BrowsingContextWillCloseEvent: BrowsingContext {
  // FIXME: should that be a pipeline event?
  const DOMString name = "will-close";
  const boolean cancelable = true;
}

// FIXME: can it be destroyed? Are we missing "destroyed" event?
