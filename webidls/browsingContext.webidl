enum BrowsingContextEventType {
  /* duplicate what Electron does here */

  // cancelable?
  "will-close",
  "will-opentab",
  "will-openwindw",
  
  "did-close",
  "did-opentab",
  "did-openwindw",

  "new-entry",
};

[ArrayClass]
interface HistoryEntryList {
  readonly attribute unsigned long length;
  getter HistoryEntry getItem(unsigned long index);
};


interface HistoryEntry {

  // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/TransitionType
  readonly attribute TransitionType transitionType;

  readonly attribute String title;
  // URL is in loadData

  // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
  readonly attribute Time lastVisitTime;
  readonly attribute Number visitCount;
  readonly attribute Number typedCount;

  readonly attribute boolean isAlive; // equivalent of entry.pipeline != undefined
  readonly attribute Pipeline? pipeline;
  readonly attribute LoadData loadData; // Only updated when pipeline dies
  readonly attribute boolean isPrivate;

  void purge();
  void restore(); // Doesn't it make sense? Why and when will we want to do this?

  /*
    onwillpurge -> last chance to use pipeline (remove event listeners)
    onrestored -> pipeline accessible
    onactive onunactive: entry or pipeline?
  */
}


// This can be used for session restore
[Constructor(LoadData[] entries,
             unsigned long activeIndex,
             boolean restoreAll,
             boolean private) Exposed=(Window,Worker)]
interface BrowsingContext {
  readonly attribute HistoryEntryList historyEntries;
  readonly unsigned long activeEntryIndex; // 
  boolean isPrivate(); // Still don't if this should be a bcontext, entry or pipeline attribute (pipeline in servo)
  void navigate(LoadData loadData); // will create a new pipeline
  void dropEntry(HistoryEntry);
  attribute boolean autoPurgePipelines; // Default yes
  attribute Number historyToKeep;
}
