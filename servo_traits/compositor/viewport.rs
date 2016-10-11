pub trait Viewport: View {
    fn attach_browser(&self, browser: BrowserID);

    fn get_content_frame(&self) -> ContentFrame;

    // None if no content
    fn get_content_size(&self, ) -> Option<Size2D<f32>>;

    fn set_overscroll_options(&self, options: PageOverscrollOptions);

    // We want to dissociate clipping area and content boundaries.
    //
    // Content coordinate are defined by content_frame. The region between the outer
    // frame and the content frame is still painted (layers are clipped by outer
    // frame). A position:fixed;top:0; element sticks to the content frame.
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

    fn update_content_frame(&self, content_frame: ContentFrame, Option<Animation>) -> impl Future<Item = ContentFrame>;

    fn send_resize_and_scroll_events_to_browser(&self);

    // The embedder, at the compositor level, might want to move an element of the page without
    // a roundtrip to the pipeline. This will provide a reference to the stacking context linked
    // to an element that can be used via StackingContextProxy' methods.
    fn get_stacking_context_id_for(&self, pipeline: PipelineID, selector: String) -> impl Future<Item=StackingContextID,Error=()>;
}

pub struct CompositeAndTransform {
    composite: CompositeKind,
    transform: Matrix4D<f32>,
}

pub trait StackingContextProxy {
    fn set_composite_and_transform(id: StackingContextID, transform: CompositeAndTransform) -> Result<(),()>;
    fn get_composite_and_transform(id: StackingContextID) -> Result<CompositeAndTransform,()>;
    // FIXME: how to get notified it's been destroyed
    fn exists(id: StackingContextID) -> bool;
}
