pub struct CompositeAndTransform {
    composite: CompositeKind,
    transform: Matrix4D<f32>,
}

pub trait BrowserView: View {
    fn get_id(&self) -> BrowserViewID;

    // Not displayed if not visible.
    // Skipped by get_browserview_from_point if not visible
    fn set_visibility(&self, visible: bool);
    fn get_visibility(&self) -> bool;

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
    // resize_and_scroll_browsers is called.

    fn set_content_frame(&self, content_frame: ContentFrame, Option<Animation>) -> impl Future<Item = ContentFrame>;

    // Will reflow and send resize and scroll events to document
    fn resize_and_scroll_browsers(&self);

    // The embedder, at the compositor level, might want to move an element of the page without
    // a roundtrip to the pipeline. This will provide a reference to the stacking context linked
    // to an element.
    // This is useful for example in the scenario describe in the above comment, where a toolbar
    // can be moved at the same time as a content frame. Both in 2 different browserviews.
    // It is important for these 2 operations to be totally in sync.
    // FIXME: eventually, the stacking context will be destroyed. We should be notified of that.
    // FIXME: This is poorly designed. idealy, we could use the Houdini API.
    fn get_stacking_context_id_for(&self, document: DocumentID, selector: String) -> impl Future<Item=StackingContextID,Error=()>;
    fn set_composite_and_transform(&self, id: StackingContextID, transform: CompositeAndTransform, Option<Animation>) -> Result<(),()>;
    fn get_composite_and_transform(&self, id: StackingContextID) -> Result<CompositeAndTransform,()>;
}
