// A page is part of a Browser which is part of a Session.
// 
// A session is:
// - SessionData (all info shared across tabs). Session's SessionData are (de)serializable.
// - A list of list of list of LoadData (multiple history entries, for multiple tabs, for multiple windows). LoadData are (de)serializable.
// - The state of the app (which window is active, which tab is foreground, …). Up to the embedder to save and restore that state.
// Storing and restoring a session require saving these 3 states are regular intervals,
// and recover them on launch. All up to the embedder.
// Embedder should save the session on:
// - SessionHandler::invalidated
// - BrowserHandler::current_entry_index_changed
// - BrowserHandler::history_entry_changed


enum StorageType {
  All,
  AppCache,
  Cookies,
  FileSystem,
  Indexedb,
  LocalStorage,
  ServiceWorkers,
}

#[derive(Deserialize, Serialize)]
pub struct SessionData {
    private: bool,
    content_blockers: Vec<SessionContentBlocker>,
    http_cache_directory: String,
    storage_data_directory: String,
    // FIXME: any persistent data
}

pub trait Session {
    fn new(handler: &SessionHandler, data: Option<SessionData>) -> Session;
    fn get_session_data(&self) -> SessionData;
    fn clear_http_cache(&self, origin: String); // "*" will clear data for all origins
    fn clear_storage_data(&self, origin: String, type_: StorageType);
}

pub trait SessionHandler {
    // This will probably be throttled by the engine.
    // Might be a good time to save the session data.
    fn invalidated(&self);

    // In the cahse of http cache and storage data, we probably
    // want to let Servo do the IO.
    fn get_http_cache_directory(&self);
    fn get_storage_data_directory(&self);
}
