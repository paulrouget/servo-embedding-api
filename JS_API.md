# Building a Servo-based browser in HTML and JavaScript

The current Browser API "pollutes" Servo's code base, bends standards
(`<iframe mozbrowser>`) and security policies (cross-domain XHR).

We want a JS API to be as self contained as possible, and maybe not even live within Servo's code base.

Here is a possible approach:

[Build a JS runtime](https://github.com/servo/servo/issues/7379).
Just an event loop + Spidermonkey + bindings

On launch: `var browser1 = NewNativeWindow("./window.html")`

Behind NewNativeWindow, Rust code:
- create a native window (let's say a glutin window)
- create a Compositor out of the window
- create a full-window Viewport
- create and attach a Browser to the Viewport, load window.html, with a special module resolver (see below)
- return the corresponding JS Browser object

At this point, window.html is painted full window in the native window.

We want that web page to be able to create other windows within
that window (like "iframes", but we don't want to re-use an existing element).

The Browser JS API would be attached to this Browser via Browser::register_js_module_resolver.
So the JS code executed in this Browser would have access to an ECMAScript module that we
will call "Servo".

`import {Browser} from "Servo";`

This is how we give special privilege to a Browser.

At this point, the JS code could create a new browser (a tab): `var browser2 = new Browser()`.
This first tab is the second Browser created. Let's create a second tab: `var browser3 = new Browser()`.

**Note: at no point in the Servo API we mention hierarchy. The fact that browser2 and browser3
are inside another browser1 has no implication.**

This is not enough, as these new tabs would be headless. A Viewport object is necessary.

We want the geometry of the viewport to be part of the layout of the page.
Servo would allow the creation of a `<viewport>` element that could be attached
to the browsers. The layout thread of the top level Browser would update the
actual viewport coordinates and size.

The Viewport methods are not accessible from a script thread.
Same for the Compositor methods.

```
import {Browser, CompositorWorker} from "Servo";
var cw = new CompositorWorker('compositor.js')
```

CompositorWorker is a [SharedWorker](https://html.spec.whatwg.org/multipage/workers.html#sharedworker)
with access to a Compositor object (itself giving access to all the viewport object).

Browser JS code and Compositor JS code can communicate via message passing.

Each port the SharedWorker is a viewport. At this point, there are 2 viewport:
the Browser created in JS, and the top level Browser initially created in Rust.

That means all browsers in a window share the same compositor.

# Life of an event

The native window would get a new event, which would be sent as a message to the compositor
worker. It's then up to the JS code in compositor.js to route the event to the proper browser.
If it's a mouse event, `Compositor.get_viewports_from_point` will return the viewport to target.
If it's a keyboard event, the relevant viewport is the one that is attached to the focused browser.
The event is sent to the browser attached to the viewport, and eventually sent back to the
compositor.

___

**Note: The `<viewport>` tag will, hopefully, be the only non-standard element
that Servo will need to support. How to make it so that it's impossible to
create a viewport element from regular web content? Maybe the viewport could
be initialized only if this JS context has access to a valid Browser object
(only provided if the "Servo" module is accessible)?**

