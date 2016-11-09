pub struct MetaTag {
  name: String;
  content: String;
}

pub enum WindowDisposition {
  ForegroundTab,
  BackgroundTab,
  NewWindow,
}

pub enum PromptType {
  Alert,
  Confirm,
}

pub enum DocumentState {
    // Document not created yet.
    // Period between the time the user clicks on a link and the time the previous document becomes inactive
    // FIXME: not sure we will ever have access to a pending document
    Pending,

    // Couldn't complete HTTP connection. Servo should not redirect to an error page. This should be handled client side.
    Error(DocumentError),
    // Document crashed
    Crash(DocumentError),

    // Following values are the same as DOM's document.readyState

    // The document is still loading.
    Loading,
    // The document has finished loading and the document has been parsed but sub-resources such as images, stylesheets and frames are still loading.
    Interactive,
    // The document and all sub-resources have finished loading. The state indicates that the load event has been fired.
    Complete,
}

pub enum SaveType {
    // Save only the HTML of the page.
    HTMLOnly,
    // Save complete-html page.
    HTMLComplete,
    // Save complete-html page as MHTML.
    MHTML,
}

// crash reports, DNS/TCP errors, … Not HTTP error (see Document.HTTPResponse).
pub struct DocumentError {
    final_url: String,
    // Chrome error list: https://cs.chromium.org/chromium/src/net/base/net_error_list.h
    // FIXME: an enum would be better
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

pub struct ConsoleMessageDetails {
    level: ConsoleLevel,
    message: String,
    col: u32,
    row: u32,
    source: String,
}


// It is likely that the embedder only wants to control the current and top level document. So we
// could expect Document's and TopLevelDocument's methods to be part of Browser. But we don't want
// to set that in stone. Maybe in the future we want to give access to inner <iframe>' document, or
// frozen documents.
// In term of lifetime, we want to make sure an instance of Document doesn't outlive its internal's
// counter-part.

pub trait Document {
    // URL changes during redirects
    fn get_url(&self) -> String;
    fn get_title(&self) -> Option<String>;
    fn get_http_response(&self) -> Option<HTTPResponse>;

    fn is_current(&self) -> bool;

    // Used to replace mozbrowserconnected, mozbrowserloadstart, mozbrowserloadend
    // Use performance for time stamps.
    fn get_state(&self) -> DocumentState;

    // See Performance.webidl and PerformanceTiming.webidl
    // Necessary to implement https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/history/HistoryItem
    fn get_performance(&self) -> Performance;

    fn get_icons(&self) -> Iterator<Icon>;
    fn get_metas(&self) -> Iterator<MetaTag>;

    fn stop_loading(&self);

    // Will destroy that document and create a new one
    fn reload(&self);
    fn clear_cache_and_reload(&self);

    fn insertCSS(&self, code: String);

    fn evaluateScript(&self, code: String, only_for_frame_script: bool) -> impl Future<Item = JSObject>;
}

// Document methods that only work for top level documents
pub trait TopLevelDocument : Document {

    fn get_hovered_link(&self) -> Option<String>;
    fn get_connection_security(&self) -> ConnectionSecurity;

    // We want to be able to render frozen document, so we need
    // a way to save the rendering.
    // FIXME: do we really want to let the client handle that?
    fn set_save_rendering_strategy(&self, strategy: SaveRenderingStrategy);

    fn capture_page(&self, source: Rect, destination: Rect) -> impl Future<Item = Blob>;
    fn save_page(&self, save_type: SaveType) -> impl Future<Item = Blob>;
    fn download_url(&self, url: String) -> impl Future<Item = Blob>;

    fn get_blocked_content_count(&self) -> BlockedContentCount;
}


pub trait DocumentHandler {

    // Warning: might not be current!
    fn created(&self, document: DocumentID); // Only after pending
    fn destroyed(&self, document: DocumentID);

    fn frozen(&self, document: DocumentID);
    fn thawn(&self, document: DocumentID);

    fn url_changed(&self, document: DocumentID);
    fn title_changed(&self, document: DocumentID);
    fn icons_changed(&self, document: DocumentID);
    fn metas_changed(&self, document: DocumentID);
    fn state_changed(&self, document: DocumentID);
    fn hovered_link_changed(&self, document: DocumentID);
    fn connection_security_changed(&self, document: DocumentID);

    // Up to the embedder to update the corresponding browserview
    fn resize(&self, document: DocumentID, Size2D<f32>);
    fn move(&self, document: DocumentID, Point2D<f32>);

    // Up to the embedder to destroy or not the Browser
    fn close(&self, document: DocumentID);

    // Warning: Cmd/Ctrl/Click should not trigger new_window. It's up to
    // the embedder to decide what to do when a link is clicked with a keyboard
    // modifier. See will_navigate and LoadData::TransitionType::LinkClicked.
    fn new_window(&self, document: DocumentID, disposition: WindowDisposition, load_data: LoadData, frame_name: String);
    fn fullscreen(&self, document: DocumentID);
    fn exit_fullscreen(&self, document: DocumentID);
    fn console_message(&self, document: DocumentID, message: ConsoleMessageDetails);
    // It's possible to cancel navigation. For example, pin
    // tabs might want to open links from different domain
    // into a different tab.
    // false: navigation canceled.
    fn will_navigate(&self, document: DocumentID, load_data: LoadData) -> bool;

    fn alert(&self, document: DocumentID, title: String, message: String) -> impl Future<>;
    fn confirm(&self, document: DocumentID, title: String, message: String) -> impl Future<Item=bool>;
    fn prompt(&self, document: DocumentID, title: String, message: String) -> impl Future<Item=String>;
    // Send Ok(username,password) or Err() if cancelled.
    fn username_and_password(&self, document: DocumentID) -> impl Future<Item=Result<(String,String),()>>;
    // Send back true if servo should ignore the certificate error
    fn ignore_certificate_error(&self, document: DocumentID, error: String, certificate: CertificateInfo) -> impl Future<Item=bool>;

    // One or several content blockers have blocked content or discovered
    // blockable content.
    fn blocked_content_count_changed(&self, document: DocumentID);
}
