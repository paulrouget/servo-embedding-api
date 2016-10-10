/// Not sure how to deal with threads.
/// Compositor runs in Servo's compositor thread.
/// Browser runs in the constellation thread

trait Servo {
    // One per native window
    fn new_compositor(drawable: &Drawable) -> Compositor;

    fn new_browser(
        browser_handler: &BrowserHandler,
        pipeline_handler: &PipelineHandler,
        http_handler: &HttpHandler,
        browsing_context_name: String) -> Browser;

    // Will recover session from disk if id.is_some(), otherwise, creates new storage.
    // Will resolve once session has been recovered.
    fn get_session(
        handler: SessionHandler,
        id: Option<SessionID>) -> Future<Item = Session>;
}
