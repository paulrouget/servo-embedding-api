// STATUS: draft

/* The creation of a viewport is not defined here. It's implementation specific.
 * This interface defines what's needed from the consumer point of view.
 * Servo internals will need more info.
 */

// We want to dissociate clipping area and content boundaries.
// 
// A typical scenario is a mobile browser, where a toolbar is half transparent,
// while content is drawn below the toolbar. The clipping area is larger than
// the content size.
//
// Another scenario is being able to animate the opening of a half transparent
// sidebar on the right of the screen that would cover part of the content
// while still pushing the position:right elements of the page, and see part of
// the page through the sidebar.
// 
// Pages are painted on the whole surface of the viewport. That surface
// coordinate and size is accessible view viewport.frameSize.  Bounds define an
// area within the viewport that is used as coordinate references for the
// content layout. If the current vertical bounds of the viewport are: { start: 5px,
// end: 5px} a position:fixed;bottom:0; element in the
// page will be drawn 5px above the bottom of the viewport and a
// position:fixed;top:0; will be drawn 5px below the top of the viewport.
// 
// It's possible to switch bounds. Such a switch can be animated.  On the
// content side, switching bounds might trigger scroll event, resize event and layout.
// These should happen only once the animation is done (we want the
// animation to fully happen in the GPU). During the animation, we expect the
// on screen position of position:fixed elements to be updated.
//
// Overscroll does *not* update intermediate bounds.
//
// Switching bounds programatically also requires translation values.
// For example, if vertical bounds A is
// start:0;end:0 and bounds B is start:10px;end:0, switch from A to B will
// resize the content, and won't scroll the content, so the on-screen position
// of a position:static element will translate down. Which is ok. But if we want to keep the
// on-screen position of static elements, translating the content by y:10px is
// necessary. At the end of the animation, this translation will trigger a
// scroll event.
//
// Switching bounds can be done programatically. But we also want this to be
// doable on scroll.
// FIXME: maybe the scrolling part should be done in a CompositorWorker!
// If panning can be translated into a translation toward
// the next set of reachable bounds, bounds should be animated as so. If the
// panning is released close enough to the bounds (snapDistance), bounds switch happens.
// If not, bounds is reset to initial value and scroll events are triggered
// as expected.

// Note: DOM level API
//
// A viewport object will come from a <viewport> element. Its frameSize will
// come from its layout in the host document. We also want to be able to
// transform sibling (as in, same document) elements depending on the bounds of
// the viewport. Example: Bounds A leave enough space above the content to draw
// a half transparent 100px tall toolbar. Bounds B leave 20px, and we want then
// the toolbar to be fully opaque.  if A, toolbar {opacity:0.5;height:100px} if
// B, toolbar {opacity:1;transform:scaleY(0.2)}. If bounds are in an
// intermediate step between A and B (because user is scrolling or because
// bounds are switched and animated programatically), we want the toolbar
// properties to change according.  This needs to be done in at the compositor
// level. We will rely on Houdini worklets, introducing bounds-specific properties.
// In the CompositorWorker, viewport exposes:
//   boundsSwitchDirection (vertical or horizontal) currentBoundsIndex,
//   targetBoundsIndex (-1 if none), boundsTransitionProgress (0..1).
// Using these values, it's possible to animate the accelerated properties of the toolbar.

// FIXME: it would be easier not have the vertical/horizontal split, but it makes
// it easier to understand how bounds chain when switching is driven by scroll.

dictionary ViewportBounds {
  unsigned long start; // pixels from top/left frame border
  unsigned long end; // pixels from right/bottom frame border
  boolean isReachableViaScrolling;
  long snapDistance;
}

enum BoundsSwitchDirection {
  "vertical",
  "horizontal",
}

interface Viewport {

  readonly attribute boolean isHeadless; // Set at construction
  readonly attribute boolean isGPUCrashed;
  readonly attribute boolean isOverscrollEnabled; // Set set construction

  readonly attribute DOMRect frameRect; // See DOMRect.webidl.

  // just a hint to tell the engine that the document is not on screen, timers
  // can slow down and requestAnimationFrame doesn't need to be called.

  // Bounds: 
  readonly attribute FrozenList<ViewportBounds> horizontalBoundsList;
  readonly attribute FrozenList<ViewportBounds> verticalBoundsList;
  readonly attribute unsigned long horizontalBoundsIndex;
  readonly attribute unsigned long verticalBoundsIndex;

  // See also https://drafts.csswg.org/css-transitions-1/#single-transition-timing-function
  Promise<void> switchBounds(unsigned long verticalBoundsIndex, unsigned long horizontalBoundsIndex,
                             DOMPoint translateContent, long duration, String transitionTimingFunction);


  Promise<boolean /* default prevented */> sendInputEvent(InputEvent); // FIXME: only key events?


  // FIXME: I dont' think we should ever care about visibility.
  // A viewport is rendering a pipeline or not. Maybe the equivalent
  // of setVisible(false) is to detach the Browser or the Pipeline
  // If this makes it to the final document, don't forget to add an event.
  // 
  // Only used to slow down timers and not call rAF. Think background tabs.
  // readonly attribute boolean isVisible;
  // Promise<void> setVisible(boolean visible);

}

interface ViewportCompositorProxy {
  readonly attribute boolean canScrollLeft;
  readonly attribute boolean canScrollRight;
  readonly attribute boolean canScrollTop;
  readonly attribute boolean canScrollBottom;

  // FIXME:
  // Events on scroll / bounds changes
  // we need to be edit bounds here as well
  // Support gestures
  
}

interface PreviewViewport {
  // FIXME: used to paint a pipeline (frozen or not)
  // FIXME: doesn't forward any event
}

Viewport implements EventEmitter;

dictionary InputEvent {
  // FIXME. Do we also want mouse events?
  // chrome:
  // String type; // (required) - The type of the event, can be mouseDown, mouseUp, mouseEnter, mouseLeave, contextMenu, mouseWheel, mouseMove, keyDown, keyUp, char.
  // String[] modifiers; // - An array of modifiers of the event, can include shift, control, alt, meta, isKeypad, isAutoRepeat, leftButtonDown, middleButtonDown, rightButtonDown, capsLock, numLock, left, right.
}

interface HeadlessViewport : Viewport {
  readonly attribute unsigned short frameRate;
  void setFrameRate(unsigned short);
}

interface ViewportEvent : Event {
  const DOMString name;
}

interface ViewportBoundsSwitchedEvent : ViewportEvent {
  const DOMString name = "bounds-switched";
  unsigned long oldBoundIndex;
  unsigned long newBoundIndex;
  BoundsSwitchDirection direction;
}

interface ViewportGPUCrashEvent: ViewportEvent {
  const DOMString name = "gpu-crashed";
  // viewport.isGPUCrashed has been set to the new value
}

interface ViewportFrameRateChangedEvent: ViewportEvent {
  const DOMString name = "frame-rate-changed";
  // Only for headless viewport
  // viewport.frameRate has been set to the new value
}


// FIXME:
//  onfirstpaint; // FIXME: Doesn't really make sense here. Should be on pipeline pending -> not pending
//  onscroll // FIXME: no. Not needed.
//  oncursorchanged // FIXME: is this the right place? Aren't we replacing ports/ at this point?
