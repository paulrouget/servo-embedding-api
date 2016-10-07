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

pub trait PipelineProxy {

    // FIXME:
    // Promise<Sequence<ContentBlocker>> getContentBlockers(ContentBlockerType type);
    // Printable asPrintable();
    // Editable asEditable();
    // Findable asFindable();
    // MultimediaManager asMultimediaManager();
    // HTTPObserverManager asHTTPObserverManager();

    // Happens during redirects for example.
    //  FIXME: should that be finalURL ? How often would that change?
    fn get_url(pipeline: PipelineId) -> String;
    fn get_title(pipeline: PipelineId) -> String;
    fn get_http_response(pipeline: PipelineId) -> HTTPResponse;

    // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
    // Use performance for time stamps.
    fn get_pipeline_state(pipeline: PipelineId) -> PipelineState;

    // See Performance.webidl and PerformanceTiming.webidl
    // Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
    fn get_performance(pipeline: PipelineId) -> Performance;

    fn get_icons(pipeline: PipelineId) -> Iterator<Icon>;
    fn get_metas(pipeline: PipelineId) -> Iterator<MetaTag>;

    fn stop_loading(pipeline: PipelineId);

    fn set_visible(pipeline: PipelineId, visible: bool);

    // Will destroy that pipeline and create a new one
    fn reload(pipeline: PipelineId);
    fn clear_cache_and_reload(pipeline: PipelineId);

    fn insertCSS(pipeline: PipelineId, code: String);

    fn evaluateScript(pipeline: PipelineId, code: String, only_for_frame_script: bool) -> Future<JSObject>;


}

// Pipeline methods that only work for top level pipelines
pub trait TopLevelPipelineProxy {

    fn get_hovered_link(pipeline: TopLevelPipelineId) -> Option<String>;
    fn get_connection_security(pipeline: TopLevelPipelineId) -> ConnectionSecurity;

    // We want to be able to render frozen pipeline, so we need
    // a way to save the rendering.
    // FIXME: do we really want to let the client handle that?
    fn set_save_rendering_strategy(pipeline: TopLevelPipelineId, strategy: SaveRenderingStrategy);

    fn capture_page(pipeline: TopLevelPipelineId, source: Rect, destination: Rect) -> Future<Blob>;
    fn save_page(pipeline: TopLevelPipelineId, save_type: SaveType) -> Future<Blob>;
    fn download_url(pipeline: TopLevelPipelineId, url: String) -> Future<Blob>;
}


pub trait PipelineHandler {

    fn url_changed(pipeline: PipelineId);
    fn title_changed(pipeline: PipelineId);
    fn icons_changed(pipeline: PipelineId);
    fn metas_changed(pipeline: PipelineId);
    fn state_changed(pipeline: PipelineId);
    fn hovered_link_changed(pipeline: PipelineId);
    fn connection_security_changed(pipeline: PipelineId);

    // Up to the embedder to update the corresponding viewport
    fn resize(pipeline: PipelineId, Size2D<f32>);
    fn move(pipeline: PipelineId, Point2D<f32>);

    // Up to the embedder to destroy or not the Browser
    fn close(pipeline: PipelineId);

    fn new_window(pipeline: PipelineId, disposition: WindowDisposition, load_data: LoadData, frame_name: String);
    fn context_menu(pipeline: PipelineId, option: ContextMenuDetails);
    fn fullscreen(pipeline: PipelineId);
    fn exit_fullscreen(pipeline: PipelineId);
    fn console_message(pipeline: PipelineId, message: ConsoleMessageDetails);
    // It's possible to cancel navigation. For example, pin
    // tabs might want to open links from different domain
    // into a different tab.
    // true: navigation not canceled.
    fn will_navigate(pipeline: PipelineId, load_data: LoadData) -> bool;

    // FIXME: anyway to not use IpcSender but Future?
    fn alert(pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<()>);
    fn confirm(pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<bool>);
    fn prompt(pipeline: PipelineId, title: String, message: String, resp_chan: IpcSender<String>);
    // Send Ok(username,password) or Err() if cancelled.
    fn username_and_password(pipeline: PipelineId, resp_chan: IpcSender<Result<(String,String),()>>);
    // Send back true if servo should ignore the certificate error
    fn ignore_certificate_error(pipeline: PipelineId, error: String, certificate: CertificateInfo, resp_chan: IpcSender<bool>);

}
