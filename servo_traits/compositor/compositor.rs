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
    viewport: glViewport, // http://docs.gl/gl3/glViewport
    z_index: i32,
    background_color: Color,
    opacity: f32,
}

pub struct ContentFrame {
    // Content frame is screen_rect here:
    // https://github.com/servo/webrender/blob/00a8818d97aa651ac4670ad85c429729c2046e9d/webrender/src/tiling.rs#L2041
    coordinates: Rect<f32>,
    pixel_ratio: f32,
    scroll_position: Point2D<f32>,
}

pub trait View {
    // glViewport is set here:
    // https://github.com/servo/webrender/blob/00a8818d97aa651ac4670ad85c429729c2046e9d/webrender/src/device.rs#L894
    fn get_frame(&self) -> ViewFrame;
    fn set_frame(&self, frame: ViewFrame, animation: Option<Animation>);
    fn is_under_point(&self, point: Point2D<u32>) -> bool;
}

pub trait Compositor {
    // One per native window
    fn new(drawable: &Drawable) -> Compositor;
    fn get_id(&self) -> CompositorID;
    fn invalidate_frame(&self);
    fn new_browserview(&self, outer_frame: ViewFrame, content_frame: ContentFrame) -> BrowserView;
    fn get_browserviews(&self) -> Iterator<BrowserView>;
    fn get_browserviews_from_point(&self, Point2D<f32>) -> Iterator<Item = BrowserView>;
    fn new_documentview(&self, frame:  ViewFrame, document: DocumentID) -> DocumentView;
}

pub trait DocumentView : View {
    // preview any document (even frozen pipelines) and mirror
    // anything happening in that pipeline.
    // This view doesn't contrain the geometry of the pipeline in any way.
    // It's possible to render a pipeline multiple times.
    // This is usually used to preview a frozen pipeline from history.
    // 
    // No method?
}

pub trait Drawable {
    fn get_gl_context(&self) -> GlContext;
    fn get_frame(&self) -> Rect<i32>;
    fn get_hidpi_factor(&self) -> f32;
    fn set_cursor(&self, cursor: Cursor);
}
