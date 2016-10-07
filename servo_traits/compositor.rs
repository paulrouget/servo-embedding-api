// FIXME: define events
// FIXME: how to translate/scale/rotate/opacity of an "layer" (is it a layer?) of a viewport

pub struct PageOverscrollOptions {
    top: OverscrollOptions,
    right: OverscrollOptions,
    bottom: OverscrollOptions,
    left: OverscrollOptions,
}

pub enum OverscrollOptions {
    Enabled(OverscrollDetails),
    Disabled,
}

pub struct OverscrollDetails {
  minPanDistanceRatio: f32,
  springFiction: f32,
  springStiffness: f32,
  stopDistanceThreshold: f32,
  stopVelocityThreshold: f32,
}

pub struct Animation {
    duration: Time,
    timing_function: TransitionTimingFunction,
}

pub struct ViewFrame {
    coordinates: Rect<i32>,
    z_index: i32,
    background_color: Color,
    opacity: f32,
}

pub struct ContentFrame {
    coordinates: Rect<f32>,
    pixel_ratio: f32,
    scroll_position: Point2D<f32>,
}

trait View {
    fn get_frame(&self, ) -> ViewFrame;
    fn set_frame(&self, frame: ViewFrame, Option<Animation>);
}

pub trait Viewport: View {
    fn attach_to_browser(&self, browser: BrowserID);

    fn get_content_frame(&self, ) -> ContentFrame;

    // None if no content
    fn get_content_size(&self, ) -> Option<Size2D<f32>>;

    fn set_overscroll_options(&self, options: PageOverscrollOptions);

    // We want to dissociate clipping area and content boundaries. A viewport object
    // defines the boundaries geometry.
    // Content coordinate are defined by content_frame. The region between the outer
    // frame and the content frame is still painted (layers are clipped by outer
    // frame). A position:fixed;top:0; element would stick to the content frame.
    // 
    // Use cases:
    // - pinch to zoom. content_frame keeps the same ratio. pixel_ratio changes.
    // - having a half transparent toolbar in the chrome.
    //   outer_frame height: 600px, toolbar height: 100px, content_frame height: 500px
    //   content_frame vertical position: 100px.
    //   The toolbar covers the outer frame. Page's background are visible through the
    //   the toolbar.
    //   When the user scrolls up 10px, the outer_frame doesn't change, the toolbar
    //   height is set to 90px, the content_frame is height is set to 510px, vertical
    //   position set to 90px. Any position:fixed;bottom:0; elements still stick to
    //   the bottom of the content frame.
    //
    // When the content frame is move or resized, the top left corner of the page sticks
    // to the top left corner of the content frame. It's possible to compensate the translation
    // of the content with scroll_offset, making it so the content appears to not move
    // relatively to the native display.
    //
    // The content will be resized and/or scrolled. DOM events are sent only once
    // send_resize_and_scroll_events_to_browser is called.

    fn update_content_frame(
        &self, 
        content_frame: ContentFrame,
        Option<Animation>) -> Future<Item = ContentFrame>;

    fn send_resize_and_scroll_events_to_browser(&self);

    fn set_visible(&self, visible: bool);

}

trait PipelineView : View {
    fn attach_to_pipeline(&self, pipeline: PipelineID);
}

trait Compositor {
    fn invalidate_frame(&self);
    fn new_viewport(
        &self,
        outer_frame: ViewFrame,
        content_frame: ContentFrame,
        overscroll_options: PageOverscrollOptions) -> Viewport;
    fn get_viewports_from_point(&self, Point2D<f32>) -> Iterator<Item = Viewport>;

    /// This will preview any pipeline (even frozen ones) and mirror
    /// anything happening in that pipeline. It's possible to render
    /// a pipeline multiple times.
    /// This view doesn't contrains the geometry of the pipeline. The
    /// only thing it does is to rendering with the view's frame.
    /// This is usually used to preview a pipeline from history.
    fn new_pipeline_view(&self, frame:  ViewFrame, pipeline: PipelineID) -> View;
}

pub trait Drawable {
    fn get_gl_context(&self) -> GlContext;
    fn get_frame(&self) -> Rect<i32>;
    fn get_hidpi_factor(&self) -> f32;
    fn set_cursor(&self, cursor: Cursor);
}
