// A global struct for storage session and global session states.

// A Session stores offline data (cookies, localStorage, …)
// and the content blocker configuration (for now). To build a session recovery,
// session needs to be serialized and written to disk, along with a list of list of list of
// LoadData (for tab restore). List of list of list because a browser is usually made of a list of
// windows made of a list of tabs made of a list of history entries. It's up to the embedder to
// regularly saved the session. The process of writing the session and the loaddata will
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

pub trait Session {
    fn get_id(&self) -> String;
    fn get_content_blockers(&self) -> Iterator<SessionContentBlocker>;
    fn clear_http_cache(&self, origin: String); // "*" will clear data for all origins
    fn clear_storage_data(&self, origin: String, type_: StorageType);
}

pub trait SessionHandler {
    // This will probably be throttled by the engine.
    // Might be a good time to save the session.
    // No disk IO is done in Servo.
    // Up to the embedder to save and restore data from disk.
    fn invalidated(&self);
}
