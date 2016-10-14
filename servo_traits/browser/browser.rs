/// Browser is the equivalent of a top level Constellation::Frame.
/// Equivalent of a tab. Browser is a top level browsing context.

/// More or less equivalent to FrameState (which is very minimal so far).
pub struct HistoryEntry {
    load_data: LoadData,
    current: bool,
    // Multiple entries can refer to the same pipeline.
    // Pipeline might not exist anymore (purged).
    pipeline_id: Option<TopLevelPipelineID>,
}

pub enum PipelineAccessError {
    NoSuchPipeline,
    NotTopLevelPipeline,
    FrozenPipeline,
    ThawnPipeline,
}

enum Event {
    // FIXME: event details missing
    Mouse(),
    Touch(),
    Key(),
    Scroll(),
    TouchpadPressure(),
}

pub trait Browser {
    fn new(session: &Session,
           browsing_context_name: String
           viewport: ViewportID,
           browser_handler: &BrowserHandler,
           pipeline_handler: &PipelineHandler,
           http_handler: &HttpHandler) -> Browser;
    fn get_id(&self) -> BrowserID;
    fn get_browsing_context_name(&self) -> String;
    // Will throttle timers, and disable requestAnimationFrame
    fn set_visible(&self, visible: bool);
    // JS module resolver. Will resolve "foo" in `import v from "foo"`
    // For example, can be used to expose the Browser API or Web Extensions APIs for content
    // See: https://developer.chrome.com/extensions/content_scripts#execution-environment
    // and https://tc39.github.io/ecma262/#sec-hostresolveimportedmodule
    fn register_js_module_resolver(&self, resolver: JSModuleResolver, only_frame_script: bool);
    // Will fail if entries already exist.
    // This can be used for session restore, or to undo tab-close.
    // On success, entries are accessible, current entry's pipeline is not pending.
    // If necessary, other pipelines can be restored via restore_pipeline()
    fn restore_entries(&self, Vec<LoadData> data, current_index: u32) -> impl Future<Item=(), Error=()>;

    fn get_entries(&self) -> Vec<HistoryEntry>;
    fn get_entry_count(&self) -> u32;
    // None if no entry has been loaded yet
    fn get_current_entry(&self) -> Option<HistoryEntry>;
    fn get_current_entry_index(&self) -> Option<u32>;
    // Will fail if index is not reachable. Will cancel any pending pipeline.
    // On success, the current pipeline is restored and not pending,
    // and current entry index has been updated.
    fn set_current_entry_index(&self, index: u32) -> impl Future<Item=(), Error=()>;

    fn has_pending_pipeline(&self) -> bool;
    fn cancel_pending_pipeline(&self);
    // Up to the embedder to eventually release the pipeline from memory.
    // Will fail if pipeline is current
    fn purge_pipeline(&self, pipeline: TopLevelPipelineID) -> Result<(),()>;
    fn restore_pipeline(&self, entry_index: u32);
    // Use to load a new URL. will create a new pipeline and navigate to the
    // pipeline once not pending. Will cancel any pending pipeline.
    fn navigate(&self, data: LoadData, opener: Option<PipelineID>) -> implt Future<Item=(),Error=()>;
    // Create a prerendering pipeline.
    // See: https://bugzilla.mozilla.org/show_bug.cgi?id=730101
    // and: https://www.chromium.org/developers/design-documents/prerender
    // Used for example while the user types a URL in the urlbar. Before the user presses enter,
    // the embedder can create such a pipeline to spead up loading.
    fn build_prerendering_pipeline(&self, LoadData loadData);
    fn navigate_to_prerendering_pipeline(&self, opener: Option<PipelineID>);
    fn cancel_prerendering_pipeline(&self);
    fn has_prerendering_pipeline(&self) -> bool;
    // Viewport (owner of the browser) doesn't have the notion of focus.
    // It's up to the embedder to make sure only one browser is focused.
    fn set_focus(&self, focus: bool);
    fn is_focused(&self) -> bool;
    // Return a Future with boolean telling if the event has been
    // consumed by the content (scroll actually happened, key event
    // has been typed, preventDefault() has been called, …)
    fn handle_event(&self, event: Event) -> impl Future<Item = bool>;

    fn get_pipeline(&self, id: pipeline_id) -> Result<Pipeline,PipelineAccessError>;
    fn get_top_level_pipeline(&self, id: pipeline_id) -> Result<TopLevelPipeline,PipelineAccessError>;
    

    // Used, for example, when a right click event is not consumed by content, to show a context menu
    fn get_content_from_point(&self, point: Point2D<f32>) -> impl Future<Item=ContentDescriptionAtPoint>;
}

pub trait BrowserHandler {
    // A new document is displayed. Usually after the user
    // clicked on a link and once the new document has been
    // created (pipeline is not pending anymore). Also happens
    // when user or page goes back/forward.
    fn current_entry_index_changed(&self, browser: BrowserID, pipeline: PipelineID, index: u32);

    // When an entry change. For example after a reload or replaceState.
    fn history_entry_changed(&self, browser: BrowserID, index: u32);

    // When the user clicks on a link, the current entry doesn't change
    // right away. A pipeline is created and is only attached to the browser
    // once the HTTP metadata has been retrieved.
    fn pipeline_pending(&self, browser: BrowserID);
    fn no_pipeline_pending(&self, browser: BrowserID);

    fn pipeline_restored(&self, browser: BrowserID, pipeline: TopLevelPipelineID);
    fn pipeline_purged(&self, browser: BrowserID, pipeline: TopLevelPipelineID);
}

// EXPERIMENTAL AND TEMPORARY

// Below interfaces are not optimized for performance but for ease of
// implementation.
// 
// The goal it to be able to experiment with non-linear history. Entries are
// stored in an array. When a user goes back in the history and then navigates,
// the previous forward history is dropped. We want to be able to experiment
// with saving that previous forward history, moving from an array structure to
// a tree structure. This goes against the web specifications, and might
// involve intrusive changes in Servo.
//
// The following interfaces are a temporary solution that doesn't require much
// work on Servo's side, and at the same time make it possible to build a tree
// structure at the API consumer level. There are some drawbacks.  Pipeline's
// are dropped, only the LoadData is saved, and the consumer has to maintain an
// alternate history structure.

pub trait BrowserExperimental : Browser {
    // Will drop the back and forward entries and replace with new ones.
    // At that point, all pipelines are killed. Only the current one stays
    // alive.
    fn replace_entries_but_current(&self,
                                   back_history: Vec<LoadData>,
                                   fwd_history: Vec<LoadData>);
}

pub trait BrowserExperimentalHandler : BrowserHandler {
    // This happens on goBack + navigate, and when replaceEntriesButCurrent is
    // called. The forward list of entries is dropped. This event comes with a
    // list of LoadData object that can be used to restore the branch if
    // necessary.
    fn browser_forward_history_branch_dropped(&self,
                                              browser: BrowserID,
                                              entries: Vec<LoadData);
}
