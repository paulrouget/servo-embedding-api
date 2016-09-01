// FIXME: See Webview.webidl


[Constructor(optional unrestricted double x = 0, optional unrestricted double y = 0,
             optional unrestricted double width = 0, optional unrestricted double height = 0),
 Exposed=(Window,Worker)]
interface Rect {
  attribute unrestricted double x;
  attribute unrestricted double y;
  attribute unrestricted double width;
  attribute unrestricted double height;
};

dictionary InputEvent {
  // FIXME. Do we also want mouse events
  // chrome:
  // String type; // (required) - The type of the event, can be mouseDown, mouseUp, mouseEnter, mouseLeave, contextMenu, mouseWheel, mouseMove, keyDown, keyUp, char.
  // String[] modifiers; // - An array of modifiers of the event, can include shift, control, alt, meta, isKeypad, isAutoRepeat, leftButtonDown, middleButtonDown, rightButtonDown, capsLock, numLock, left, right.
}

enum ViewportEventType { "visibilitychanged", "firstpaint" };

dictionary ViewportEvent{
  attribute readonly ViewportEventType type;
};

interface Viewport {
  readonly attribute Rect frame;
  attribute Rect boundsAtRest;
  void animateBounds(Rect bounds, long duration, String transitionTimingFunction);
  attribute boolean visible; // Can this fail? If so, getter/setter
  attribute boolean updateBoundsOnScroll; // snapping?
  attribute boolean overscrollEnabled;
  onvisibylitychanged;
  onfirstpaint;

  /* FIXME:
      focus
      forwardKeys;
      forwardMouseEvents;
      scroll
      think embeeding in a game
      gpucrash
      cursorchanged // FIXME: is this the right place?
  */

  Promise<boolean /* prevent default */> sendInputEvent(InputEvent);
}

interface HeadlessViewport {
  // FIXME?
}
