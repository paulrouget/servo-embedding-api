// STATUS: ok

// A storage session stores offline data (cookies, localStorage, …). To build a
// session recovery, storage session needs to be serialized and written to
// disk, along with a list of list of list of LoadData (for tab restore). List
// of list of list because a browser is usually made of a list of windows made
// of a list of tabs made of a list of history entries.  It's up to the
// embedder to regularly saved the session.  The process of writing the storage
// session and the loaddata will require disk access, which is supposed to be
// handled by the embedder.

enum OfflineStorageType {
  "all",
  "appcache",
  "cookies",
  "fileSystem",
  "indexdb",
  "localStorage",
  "serviceworkers"
}

[Constructor(optional DOMString id)]
interface StorageSession : Serializable : WeakRef {

  // The constructor takes an optional id. If id is provided, the offline storage
  // will be recovered from disk.

  // To build a private browsing mode, all that is necessary is to create a new
  // session with no id, and never write it to disk.

  attribute readonly DOMString id;
  Promise<void> clearHTTPCache(USVString origin); // "*" will clear data for all origins
  Promise<void> clearStorageData(USVString origin, OfflineStorageType type); // "*" will clear data for all origins
}

Browser implements EventEmitter;

interface StorageSessionChangedEvent : Event {
  // This will probably be throttled by the engine. Might be a good time
  // to save the session.
  const DOMString type = "did-change";
}

interface StorageSessionDidRecoverEvent : Event {
  // The session has been restored from disk.
  const DOMString type = "did-recover";
}
