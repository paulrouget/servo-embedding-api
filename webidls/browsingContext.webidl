typedef PreloadingPipelineID = long;

// FIXME: this feels busy and not very "clear" how entries are added, removed…

// This can be used for session restore
[Constructor(Sequence<LoadData> entries, unsigned long activeIndex, boolean restoreAll, boolean private)]
interface BrowsingContext {
  readonly attribute FrozenList<HistoryEntry> historyEntries;
  readonly unsigned long activeEntryIndex;
  boolean isPrivate(); // FIXME: Still don't know if this should be a bcontext, entry or pipeline attribute (part of pipeline in servo)
  void dropEntry(HistoryEntry);
  attribute boolean autoPurgePipelines; // Default yes
  attribute unsigned long historyToKeep; // Default 3
  void insertNewEntry(LoadData data, unsigned long index, boolean active); // Use to load a new URL. will create a new pipeline // FIXME: or maybe URL? What's the point of using LoadData if it can only be constructed from URL?

  PreloadingPipelineID preloadPipeline((LoadData or USVString) init);
  void cancelPreloadingPipeline(PreloadingPipelineID id);
  void navigateToPreloadingPipeline(PreloadingPipelineID id);
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
  const boolean cancellable = false;
}

interface BrowsingContext_ActiveEntryChanged: Event {
  // A new document is displayed. Usually after the user
  // clicked on a link and once the new document has been
  // created (pipeline is not pending anymore).
  // FIXME: is that actually necessary? The consumer is supposed to
  // track any new entry and track if these turns active / inactive.
  const String type = "active-entry-changed";
  const boolean cancellable = false;
}

// FIXME: can it be destroyed? Are we missing "destroyed" event?
