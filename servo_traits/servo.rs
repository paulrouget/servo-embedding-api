trait Servo {
    // One per native window
    fn new_compositor(drawable: &Drawable) -> Compositor;

    fn new_browser(handler: &BrowserHandler, browsing_context_name: String) -> Browser;

    // Will recover session from disk if id.is_some(), otherwise, creates new storage.
    // Will resolve once session has been recovered.
    fn get_session_storage(handler: SessionStorageHandler, id: Option<String>) -> Future<Item = SessionStorage>;
}

