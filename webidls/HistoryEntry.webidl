// https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/api/history.json
enum TransitionType {
  "link", "typed", "auto_bookmark", "auto_subframe", "manual_subframe",
  "generated", "auto_toplevel", "form_submit", "reload", "keyword",
  "keyword_generated"
}

interface HistoryEntry {
  readonly attribute String? title;
  readonly attribute USVString? url; // Get updated with redirections

  readonly attribute TransitionType transitionType;
  readonly attribute boolean isPipelineAlive; // equivalent of entry.pipeline != null

  readonly attribute DOMString userEntry; // What ever lead the user to load this entry.

  // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
  readonly attribute DOMTimeStamp lastVisitTime;
  readonly attribute unsigned long visitCount;
  readonly attribute unsigned long typedCount;

  readonly attribute Pipeline? pipeline; // **Important**: multiple entries can refer to a single pipeline
  
  Promise<LoadData> getLoadData(); // Not a copy of the initial load data. Compiled from live pipeline.
  Promise<void> purgePipeline(); // Will only work if frozen
  Promise<Pipeline> restorePipeline(); // Doesn't it make sense? Why and when will we want to do this?

  Promise<Blob> serializeLoadData(); // Used to save to disk
}

HistoryEntry implements EventEmitter;

interface HistoryEntryEvent_PipelineWillPurge : Event {
  // last chance to use pipeline (remove event listeners)
  // This is blocking. Are we sure?
  const String type = "pipeline-will-purge";
  const boolean cancelable = false;
}

interface HistoryEntryEvent_PipelineRestored : Event {
  // pipeline is accessible
  // Either restored (if going far back in the history)
  // or swapped (in case of reload)
  // or resetore via pipeline.restore()
  const String type = "pipeline-created";
  const boolean cancelable = false;
}

interface HistoryEntryEvent_Active : Event {
  const String type = "active";
  const boolean cancelable = false;
}

interface HistoryEntryEvent_Inactive : Event {
  const String type = "inactive";
  const boolean cancelable = false;
}

interface HistoryEntryEvent_Destroyed : Event {
  const String type = "destroyed";
  const boolean cancelable = false;
  LoadData loadData; // useful to have if restore is needed for later
  // FIXME: is this loadData sufficient for a book keeping of history as a graph?
}
