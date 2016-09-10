// STATUS: draft

/**
 *  More or less equivalent to FrameState (which is very minimal so far).
 */

interface HistoryEntry {
  readonly attribute boolean isPipelineAlive;
  readonly attribute Pipeline? pipeline; // **Important**: multiple entries can refer to a single pipeline. Will fail if pipeline purged.

  Promise<void> purgePipeline(); // Will only work if frozen
  Promise<Pipeline> restorePipeline(); // FIXME: Doesn't it make sense? Why and when will we want to do this? Wouldn't that mess up with Browser.webidl's autopurge.

  // To get up-to-date information about the document (url, title, …), use the pipeline.
  // If the pipeline is killed, use latestLoadData. It is initialized with the LoadData passed
  // at construction. It updates the pipeline dies.
  readonly attribute LoadData latestLoadData;

  // FIXME: No reason for this to live in HistoryEntry
  Promise<Blob> serializeLoadData(LoadData loadData); // Used to save to disk
}

HistoryEntry implements EventEmitter;

interface HistoryEntryPipelineWillPurgeEvent : Event {
  // last chance to use pipeline (remove event listeners)
  // This will block. Are we sure?
  const DOMString type = "pipeline-will-purge";
}

interface HistoryEntryPipelineRestoredEvent : Event {
  // pipeline is accessible
  // Either restored (if going back far in the history)
  // or swapped (in case of reload)
  // or restored via restorePipeline()
  const DOMString type = "pipeline-created";
}

interface HistoryEntryWillDestroyedEvent : Event {
  // Last chance to access entry.latestLoadData.
  const DOMString type = "will-destroy";
}
