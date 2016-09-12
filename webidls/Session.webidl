// This is where access to disk happens

enum OfflineStorageType {
  "all",
  "appcache",
  "cookies",
  "fileSystem",
  "indexdb",
  "localStorage",
  "serviceworkers"
}

[Constructor(option DOMString id)] // Can be imported from disk
interface Session {
  // FIXME: more stuff here: https://github.com/electron/electron/blob/master/docs/api/session.md
  DOMString id;

  Promise<void> clearHTTPCache(USVString origin);
  Promise<void> clearStorageData(USVString origin, OfflineStorageType type);

  Promise<void> flushStorageData();

  Promise<void> storeLoadData(Sequence<LoadData> loadData); // FIXME: That won't work with multiple windows
  Promise<Sequence<LoadData>> recoverLoadData();
}
