// A storage session stores offline data (cookies, localStorage, …). To build a
// session recovery, storage session needs to be serialized and written to
// disk, along with a list of list of list of LoadData (for tab restore). List
// of list of list because a browser is usually made of a list of windows made

// To build a private browsing mode, all that is necessary is to create a new
// session with no id, and never write it to disk. // FIXME: Is that enough?

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
