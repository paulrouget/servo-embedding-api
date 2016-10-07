// Holds offline data: appcache, cookies, fileSystem, indexdb, localStorage, serviceworkers. Has
// methods to clear data. Is serializable to write to disk.

// No disk IO is done in Servo.

// Up to the embedder to save and restore data from disk.

// A storage session stores offline data (cookies, localStorage, …). To build a session recovery,
// storage session needs to be serialized and written to disk, along with a list of list of list of
// LoadData (for tab restore). List of list of list because a browser is usually made of a list of
// windows made of a list of tabs made of a list of history entries. It's up to the embedder to
// regularly saved the session. The process of writing the storage session and the loaddata will
// require disk access, which is supposed to be handled by the embedder.

// To build a private browsing mode, all that is necessary is to create a new session with no id,
// and never write it to disk. // FIXME: Is that enough?

enum StorageType {
  All,
  AppCache,
  Cookies,
  FileSystem,
  Indexedb,
  LocalStorage,
  ServiceWorkers,
}

pub trait SessionStorage {
    fn get_id(&self) -> String;
    fn clear_http_cache(&self, origin: String); // "*" will clear data for all origins
    fn clear_storage_data(&self, origin: String, type_: StorageType);
}

pub trait SessionStorageHandler {
    // This will probably be throttled by the engine. Might be a good time to save the session.
    fn has_changed(&self);
}
