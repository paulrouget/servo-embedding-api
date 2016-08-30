enum HTTPMethod { "GET", "POST" }


// FIXME: Is LoadData actually necessary? Can it be serialized from HistoryEntry to save the session?
// Can a URL be used instead of LoadData to create a new pipeline/entry?
[Constructor, Constructor((USVString or Blob /* serialized loadata */))]
// Used to reload purged pipeline or to preload pipeline
interface LoadData {
  readonly attribute USVString url;
  readonly attribute HTTPMethod method;
  readonly attribute Headers headers; // Headers.webidl
  readonly attribute BodyInit? data; // See XMLHttpequest.webdil
  readonly attribute ReferrerPolicy? referrerPolicy; // See Request.webidl
  readonly attribute USVString? referrerUrl;
  Promise<Blob> serialize(); // Used to save to disk
}

// https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/api/history.json
enum TransitionType {
  "link", "typed", "auto_bookmark", "auto_subframe", "manual_subframe",
  "generated", "auto_toplevel", "form_submit", "reload", "keyword",
  "keyword_generated"
}

interface HistoryEntry {
  readonly attribute String? title;
  readonly attribute USVString? url;
  readonly attribute TransitionType transitionType;
  readonly attribute boolean isAlive; // equivalent of entry.pipeline != null
  readonly attribute boolean isPrivate;

  // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
  readonly attribute DOMTimeStamp lastVisitTime;
  readonly attribute unsigned long visitCount;
  readonly attribute unsigned long typedCount;

  readonly attribute Pipeline? pipeline;
  
  Promise<LoadData> getLoadData();
  Promise<void> purge();
  Promise<Pipeline> restore(); // Doesn't it make sense? Why and when will we want to do this?
}

HistoryEntry implements EventEmitter;

interface HistoryEntryEvent_PipelineWillPurge : Event {
  // last chance to use pipeline (remove event listeners)
  const String type = "pipeline-will-purge";
  const boolean cancellable = false;
}

interface HistoryEntryEvent_PipelineRestored : Event {
  // pipeline is accessible
  const String type = "pipeline-restored";
  const boolean cancellable = false;
}

interface HistoryEntryEvent_Active : Event {
  const String type = "active";
  const boolean cancellable = false;
}

interface HistoryEntryEvent_Inactive : Event {
  const String type = "inactive";
  const boolean cancellable = false;
}

interface HistoryEntryEvent_Destroyed : Event {
  const String type = "destroyed";
  const boolean cancellable = false;
}
