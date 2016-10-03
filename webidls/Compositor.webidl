dictionary CompositorEvent { }

dictionary MouseEvent : CompositorEvent { /*FIXME*/ }
dictionary TouchEvent : CompositorEvent { /*FIXME*/ }
dictionary KeyEvent : CompositorEvent { /*FIXME*/ }
dictionary ScrollEvent : CompositorEvent { /*FIXME*/ }
dictionary TouchpadPressureEvent : CompositorEvent { /*FIXME*/ }

dictionary PageOverscrollOptions {
  OverscrollOptions top;
  OverscrollOptions right;
  OverscrollOptions bottom;
  OverscrollOptions left;
}

dictionary OverscrollOptions {
  boolean enabled;
  float minPanDistanceRatio;
  float springFiction;
  float springStiffness;
  float stopDistanceThreshold;
  float stopVelocityThreshold;
}

[Constructor(…)]
interface Compositor { // From Servo
  Promise<void> setHandler(CompositorHandler);
  readonly attribute Size size; // This will clip viewports
  // FIXME: remove those setters…
  Promise<void> setSize(Size);

  Viewport getFocusedViewport();
  Viewport getViewportFromPoint(Point);

  void attachViewport(Viewport);
  void detachViewport(Viewport);

  void attachPipelinePreview(PipelinePreview);
  void detachPipelinePreview(PipelinePreview);

}

[Constructor(Rect frame)]
interface PipelinePreview {
  // Works for frozen pipelines too.
  // Equivalent of a viewport, but no events are ever send to the
  // pipeline. The content frame comes from the pipeline's browser's viewport.
  readonly attribute Rect frame;
  void setFrame(Rect); // Where to clip
  // FIXME: should be an ID? different thread
  Promise<void> attachPipeline(Pipeline);
  void detachPipeline();
}

[Constructor(Rect frame)]
interface Viewport {

  // Note: up to the embedder to know which viewport is focused,
  // and forward key events to the right viewport

  // events are forwarded to pipelines.
  // Point-related events are sent to the pipeline under the cursor/touch events.
  // Keyboard events are sent to the focused pipeline.
  // return true if a pipeline is found.
  // Once the pipeline has consumed the event, BrowserHandler::onCompositorEvent is called
  boolean sendEvent(CompositorEvent);

  readonly attribute Rect frame;
  void setFrame(Rect); // Where to clip

  // zoom, bounds
  readonly attribute OverscrollOptions overscrollOptions;
  void setOverscrollOptions(PageOverscrollOptions options);


  // Pan and zoom.
  // Content frame is the inner window size, relative to viewport's frame.
  // sendResizeAndScrollEventsToScript should be called once the panAndZoom
  // operation is done (or at regular intervals).
  // Anything between frame and contentFrame should still be rendered.
  void panAndZoom(Rect contentFrame, pixelRatio);
  void sendResizeAndScrollEventsToScript();
  readonly attribute Rect contentFrame;

  // FIXME: should be an ID? different thread
  Promise<void> attachBrowser(Browser);
  void detachBrowser();
}


interface CompositorHandler {
  /// Sets the cursor to be used in the window.
  void setCursor(Compositor, cursor: Cursor);
  /// Presents the window to the screen (perhaps by page flipping).
  void present(Compositor);

  /// Returns the scale factor of the system (device pixels / screen pixels).
  f32 getNativeScaleFactor();
  /// Gets the OS native graphics display
  NativeDisplay getNativeDisplay();
  /// Requests that the window system prepare a composite. Typically this will involve making
  /// some type of platform-specific graphics context current. Returns true if the composite may
  /// proceed and false if it should not.
  bool prepareForComposite(width: usize, height: usize);
  /// Returns the size of the viewport in density-independent "px" units.


  // FIXME: Viewport, Compositor or CompositorHandler
  TypedSize2D<f32, ScreenPx> getSize();
  /// Return the size of the OS window with head and borders and position of the window values
  (Size2D<u32>, Point2D<i32>) getClientWindow();
  /// Set the size inside of borders and head
  void setInnerSize(size: Size2D<u32>);
  /// Set the window position
  void setPosition(point: Point2D<i32>);

}
