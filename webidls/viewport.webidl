[Constructor(optional unrestricted double x = 0, optional unrestricted double y = 0,
             optional unrestricted double width = 0, optional unrestricted double height = 0),
 Exposed=(Window,Worker)]
interface Rect {
  attribute unrestricted double x;
  attribute unrestricted double y;
  attribute unrestricted double width;
  attribute unrestricted double height;
};

enum ViewportEventType { "visibilitychanged", "firstpaint" };

dictionary ViewportEvent{
  attribute readonly ViewportEventType type;
};

interface ViewPort {
  readonly attribute Rect frame;
  attribute Rect boundsAtRest;
  void animateBounds(Rect bounds, long duration, String transitionTimingFunction);
  attribute boolean visible; // Can this fail? If so, getter/setter
  attribute boolean updateBoundsOnScroll; // snapping?
  attribute boolean overscrollEnabled;
  onvisibylitychanged;
  onfirstpaint;
}
