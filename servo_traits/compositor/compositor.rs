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

pub trait View {
    fn get_frame(&self) -> ViewFrame;
    fn set_frame(&self, frame: ViewFrame, animation: Option<Animation>);
    fn is_under_point(&self, point: Point2D<u32>) -> bool;
}

trait Compositor {
    // One per native window
    fn new(drawable: &Drawable) -> Compositor;
    fn invalidate_frame(&self);
    fn new_viewport(&self, outer_frame: ViewFrame, content_frame: ContentFrame, overscroll_options: PageOverscrollOptions) -> Viewport;
    fn get_viewports(&self) -> Iterator<Viewport>;
    fn get_viewports_from_point(&self, Point2D<f32>) -> Iterator<Item = Viewport>;
    fn new_pipeline_view(&self, frame:  ViewFrame, pipeline: PipelineID) -> View;
}

trait PipelineView : View {
    // preview any pipeline (even frozen ones) and mirror
    // anything happening in that pipeline.
    // This view doesn't contrain the geometry of the pipeline in any way.
    // It's possible to render a pipeline multiple times.
    // This is usually used to preview a frozen pipeline from history.
    fn attach_pipeline(&self, pipeline: PipelineID);
}

pub trait Drawable {
    fn get_gl_context(&self) -> GlContext;
    fn get_frame(&self) -> Rect<i32>;
    fn get_hidpi_factor(&self) -> f32;
    fn set_cursor(&self, cursor: Cursor);
}