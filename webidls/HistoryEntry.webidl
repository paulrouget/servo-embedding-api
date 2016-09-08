// STATUS: draft

/**
 *  More or less equivalent to FrameState (which is very minimal so far).
 */

interface HistoryEntry {
  readonly attribute DOMString? title;
  readonly attribute USVString? url; // Get updated with redirections
  readonly attribute boolean isPipelineAlive;
  readonly attribute DOMTimeStamp visitTime; // Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem

  Promise <Pipeline> getPipeline(); // **Important**: multiple entries can refer to a single pipeline. Will fail if pipeline purged.
  Promise<LoadData> getLoadData(); // Not a copy of the initial load data. Updated after redirects.
  Promise<void> purgePipeline(); // Will only work if frozen
  Promise<Pipeline> restorePipeline(); // FIXME: Doesn't it make sense? Why and when will we want to do this?

  Promise<Blob> serializeLoadData(); // Used to save to disk
}

HistoryEntry implements EventEmitter;

interface HistoryEntryPipelineWillPurgeEvent: CancelableEvent {
  // last chance to use pipeline (remove event listeners)
  // This will block. Are we sure?
  const String type = "pipeline-will-purge";
  const boolean cancelable = false;
}

interface HistoryEntryPipelineRestoredEvent : CancelableEvent {
  // pipeline is accessible
  // Either restored (if going back far in the history)
  // or swapped (in case of reload)
  // or restored via restorePipeline()
  const String type = "pipeline-created";
  const boolean cancelable = false;
}

interface HistoryEntryDestroyedEvent : CancelableEvent {
  const String type = "destroyed";
  const boolean cancelable = false;
  LoadData loadData; // useful to have if restore is needed for later
}
