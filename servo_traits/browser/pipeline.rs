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
    // Document not created yet.
    // Period between the time the user clicks on a link and the time the previous document becomes inactive
    // FIXME: not sure we will ever have access to a pending pipeline
    Pending,

    // Couldn't complete HTTP connection. Servo should not redirect to an error page. This should be handled client side.
    Error(PipelineError),
    // Pipeline crashed
    Crash(PipelineError),

    // Following values are the same as document.readyState

    // The document is still loading.
    Loading,
    // The document has finished loading and the document has been parsed but sub-resources such as images, stylesheets and frames are still loading.
    Interactive,
    // The document and all sub-resources have finished loading. The state indicates that the load event has been fired.
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
pub struct PipelineError {
    final_url: String,
    // Chrome error list: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
    // FIXME: maybe an enum should be better
    code: u32,
    // Human readable
    description: String,
    // Backtrace for panics
    report: Option<String>;
}

pub enum SaveRenderingStrategy {
    Default,
    Displaylist,
    Texture,
}

pub struct Icon {
    href: String,
    sizes: Vec<Size2D<f32>>;
    rel: String;
}

pub enum PipelineProxyError {
    NoSuchPipeline,
    NotTopLevelPipeline,
    FrozenPipeline,
    ThawnPipeline,
}

pub struct ContextMenuDetails {
    point: Point2D<f32>,
    // FIXME: http://electron.atom.io/docs/api/web-contents/#event-context-menu
}

pub struct ConsoleMessageDetails {
    level: ConsoleLevel,
    message: String,
    col: u32,
    row: u32,
    source: String,
}


// It is likely that the embedder only wants to control the current and top level
// pipeline. So we could expect PipelineProxy's and TopLevelPipelineProxy's methods
// to be part of Browser. But we don't want to set that in stone. Maybe in the future
// we want to give access to inner <iframe>' pipeline, or frozen pipelines.
pub trait PipelineProxy {

    // Happens during redirects for example.
    fn get_url(pipeline: PipelineId) -> Result<String,PipelineProxyError>;
    fn get_title(pipeline: PipelineId) -> Result<Option<String>,PipelineProxyError>;
    fn get_http_response(pipeline: PipelineId) -> Result<Option<HTTPResponse>,PipelineProxyError>;

    fn exists(pipeline: PipelineId) -> bool;
    fn is_current(pipeline: PipelineId) -> Result<bool,PipelineProxyError>;

    // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
    // Use performance for time stamps.
    fn get_pipeline_state(pipeline: PipelineId) -> Result<PipelineState,PipelineProxyError>;

    // See Performance.webidl and PerformanceTiming.webidl
    // Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
    fn get_performance(pipeline: PipelineId) -> Result<Performance,PipelineProxyError>;

    fn get_icons(pipeline: PipelineId) -> Result<Iterator<Icon>,PipelineProxyError>;
    fn get_metas(pipeline: PipelineId) -> Result<Iterator<MetaTag>,PipelineProxyError>;

    fn stop_loading(pipeline: PipelineId) -> Result<(),PipelineProxyError>;

    // Will destroy that pipeline and create a new one
    fn reload(pipeline: PipelineId) -> Result<(),PipelineProxyError>;
    fn clear_cache_and_reload(pipeline: PipelineId) -> Result<(),PipelineProxyError>;

    fn insertCSS(pipeline: PipelineId, code: String) -> Result<(),PipelineProxyError>;

    fn evaluateScript(pipeline: PipelineId, code: String, only_for_frame_script: bool) -> Result<impl Future<Item = JSObject>,PipelineProxyError>;


}

// Pipeline methods that only work for top level pipelines
pub trait TopLevelPipelineProxy {

    fn get_hovered_link(pipeline: TopLevelPipelineId) -> Result<Option<String>,PipelineProxyError>;
    fn get_connection_security(pipeline: TopLevelPipelineId) -> Result<ConnectionSecurity,PipelineProxyError>;

    // We want to be able to render frozen pipeline, so we need
    // a way to save the rendering.
    // FIXME: do we really want to let the client handle that?
    fn set_save_rendering_strategy(pipeline: TopLevelPipelineId, strategy: SaveRenderingStrategy) -> Result<(),PipelineProxyError>;

    fn capture_page(pipeline: TopLevelPipelineId, source: Rect, destination: Rect) -> Result<impl Future<Item = Blob>,PipelineProxyError>;
    fn save_page(pipeline: TopLevelPipelineId, save_type: SaveType) -> Result<impl Future<Item = Blob>,PipelineProxyError>;
    fn download_url(pipeline: TopLevelPipelineId, url: String) -> Result<impl Future<Item = Blob>,PipelineProxyError>;

    fn get_blocked_content_count(pipeline: TopLevelPipelineId) -> Result<BlockedContentCount,PipelineProxyError>;
}


pub trait PipelineHandler {

    // Warning: might not be current!
    fn created(&self, pipeline: PipelineId); // Only after pending
    fn destroyed(&self, pipeline: PipelineId);

    fn frozen(&self, pipeline: PipelineId);
    fn thawn(&self, pipeline: PipelineId);

    fn url_changed(&self, pipeline: PipelineId);
    fn title_changed(&self, pipeline: PipelineId);
    fn icons_changed(&self, pipeline: PipelineId);
    fn metas_changed(&self, pipeline: PipelineId);
    fn state_changed(&self, pipeline: PipelineId);
    fn hovered_link_changed(&self, pipeline: PipelineId);
    fn connection_security_changed(&self, pipeline: PipelineId);

    // Up to the embedder to update the corresponding viewport
    fn resize(&self, pipeline: PipelineId, Size2D<f32>);
    fn move(&self, pipeline: PipelineId, Point2D<f32>);

    // Up to the embedder to destroy or not the Browser
    fn close(&self, pipeline: PipelineId);

    // Warning: Cmd/Ctrl/Click should not trigger new_window. It's up to
    // the embedder to decide what to do when a link is clicked with a keyboard
    // modifier. See will_navigate and LoadData::TransitionType::LinkClicked.
    fn new_window(&self, pipeline: PipelineId, disposition: WindowDisposition, load_data: LoadData, frame_name: String);
    fn context_menu(&self, pipeline: PipelineId, option: ContextMenuDetails);
    fn fullscreen(&self, pipeline: PipelineId);
    fn exit_fullscreen(&self, pipeline: PipelineId);
    fn console_message(&self, pipeline: PipelineId, message: ConsoleMessageDetails);
    // It's possible to cancel navigation. For example, pin
    // tabs might want to open links from different domain
    // into a different tab.
    // false: navigation canceled.
    fn will_navigate(&self, pipeline: PipelineId, load_data: LoadData) -> bool;

    // FIXME: anyway to not use IpcSender but Future?
    fn alert(&self, pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<()>);
    fn confirm(&self, pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<bool>);
    fn prompt(&self, pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<String>);
    // Send Ok(username,password) or Err() if cancelled.
    fn username_and_password(&self, pipeline: PipelineId, resp_chan: IpcSender<Result<(String,String),()>>);
    // Send back true if servo should ignore the certificate error
    fn ignore_certificate_error(&self, pipeline: PipelineId, error: String, certificate: CertificateInfo, resp_chan: IpcSender<bool>);

    // One or several content blockers have blocked content or discovered
    // blockable content.
    fn blocked_content_count_changed(&self, pipeline: PipelineId);
}
