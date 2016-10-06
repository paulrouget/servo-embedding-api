struct MetaTag {
  name: String;
  content: String;
}

enum WindowDisposition {
  ForegroundTab,
  BackgroundTab,
  NewWindow,
}

enum PromptType {
  Alert,
  Confirm,
}

enum PipelineState {
    // Document not created yet. Period between the time the user clicks on a link and the time the previous document becomes inactive // FIXME: not sure we will ever have access to a pending pipeline
    Pending,

    // Couldn't complete HTTP connection. Servo should not redirect to an error page. This should be handled client side.
    Error(PipelineError),
    // Pipeline crashed
    Crash(PipelineError),

    // Following values are the same as document.readyState

    // The document is still loading. (same as document.readyState)
    Loading,
    // The document has finished loading and the document has been parsed but sub-resources such as images, stylesheets and frames are still loading. (same as document.readyState)
    Interactive,
    // The document and all sub-resources have finished loading. The state indicates that the load event has been fired. (same as document.readyState)
    Complete,
}

enum SaveType {
    // Save only the HTML of the page.
    HTMLOnly,
    // Save complete-html page.
    HTMLComplete,
    // Save complete-html page as MHTML.
    MHTML,
}

// crash reports, DNS/TCP errors, … Not HTTP error (see Pipeline.HTTPResponse).
struct PipelineError {
    final_url: String,
    // Chrome error list: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
    code: u32,
    // Human readable
    description: String,
    // Backtrace for panics
    report: Option<String>;
}

enum SaveRenderingStrategy {
    Default,
    Displaylist,
    Texture,
}

struct Icon {
    href: String,
    sizes: Vec<Size2D<f32>>;
    rel: String;
}

// Any call will be redirected to the current pipeline
pub trait TopLevelPipelineProxy {

    fn get_pipeline_id(&self) -> TopLevelPipelineID;

    fn get_hovered_link(&self) -> Option<String>;
    fn get_connection_security(&self) -> ConnectionSecurity;

    // We want to be able to render frozen pipeline, so we need
    // a way to save the rendering.
    // FIXME: do we really want to let the client handle that?
    fn set_save_rendering_strategy(&self, strategy: SaveRenderingStrategy);

    fn capture_page(&self, source: Rect, destination: Rect) -> Future<Blob>;
    fn save_page(&self, save_type: SaveType) -> Future<Blob>;
    fn download_url(&self, url: String) -> Future<Blob>;

    // FIXME:
    // Promise<Sequence<ContentBlocker>> getContentBlockers(ContentBlockerType type);
    // Printable asPrintable();
    // Editable asEditable();
    // Findable asFindable();
    // MultimediaManager asMultimediaManager();
    // HTTPObserverManager asHTTPObserverManager();

    // Happens during redirects for example.
    //  FIXME: should that be finalURL ? How often would that change?
    fn get_url(&self) -> String;
    fn get_title(&self) -> String;
    fn get_http_response(&self) -> HTTPResponse;

    // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
    // Use performance for time stamps.
    fn get_pipeline_state(&self) -> PipelineState;

    // See Performance.webidl and PerformanceTiming.webidl
    // Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
    fn get_performance(&self) -> Performance;

    fn get_icons(&self) -> Iterator<Icon>;
    fn get_metas(&self) -> Iterator<MetaTag>;

    fn stop_loading(&self);

    fn set_visible(&self, visible: bool);

    // Will destroy that pipeline and create a new one
    fn reload(&self);
    fn clear_cache_and_reload(&self);

    fn insertCSS(&self, code: String);

    fn evaluateScript(&self, code: String, only_for_frame_script: bool) -> Future<JSObject>;


}

pub trait PipelineHandler {

    fn url_changed(&self);
    fn title_changed(&self);
    fn icons_changed(&self);
    fn metas_changed(&self);
    fn state_changed(&self);
    fn hovered_link_changed(&self);
    fn connection_security_changed(&self);

    // Up to the embedder to update the corresponding viewport
    fn resize(&self, Size2D<f32>);
    fn move(&self, Point2D<f32>);

    fn close(&self);
    fn new_window(&self, disposition: WindowDisposition, load_data: LoadData, frame_name: String);
    fn context_menu(&self, option: ContextMenuDetails);
    fn fullscreen(&self);
    fn exit_fullscreen(&self);
    fn console_message(&self, message: ConsoleMessageDetails);
    // It's possible to cancel navigation. For example, pin
    // tabs might want to open links from different domain
    // into a different tab.
    // true: navigation not canceled.
    fn will_navigate(&self, load_data: LoadData) -> bool;

    // FIXME: anyway to not use IpcSender but Future?
    fn alert(&self, title: String, message: String, resp_chan: IpcSender<()>);
    fn confirm(&self, title: String, message: String, resp_chan: IpcSender<bool>);
    fn prompt(&self, title: String, message: String, resp_chan: IpcSender<String>);
    // Send Ok(username,password) or Err() if cancelled.
    fn username_and_password(&self, resp_chan: IpcSender<Result<(String,String),()>>);
    // Send back true if servo should ignore the certificate error
    fn ignore_certificate_error(&self, error: String, certificate: CertificateInfo, resp_chan: IpcSender<bool>);

}
