# Building a Servo-based browser in HTML and JavaScript

The current Browser API "pollutes" Servo's code base, bends standards (`<iframe mozbrowser>`) and security policies (cross-domain XHR).

We want the JS API to be as self contained as possible. It doesn't have to live within Servo's code base.

We like the Electron approach where a webpage embeds a webpage, with a JS runtime as a bridge between the embedder and the OS.

The idea is to make Servo embed itself.

Here is a possible approach

---

A JS app is made out of 4 files:
- app.js
- window.html
- window.js
- compositor.js

___

*app.js* is run via a [JS runtime](https://github.com/servo/servo/issues/7379).
An event loop + Spidermonkey + bindings.
Here we're not talking about Servo's JS runtime. Just Spidermonkey by itself.

On launch: `var browser1 = NewNativeWindow("./window.html")`

Behind `NewNativeWindow`, Rust code:
- create a native window (let's say a glutin window)
- load libservo
- create a Servo's [Compositor](servo_traits/compositor/compositor.rs) out of the window (wrapped as a [Drawable](servo_traits/compositor/compositor.rs))
- create a full-window [BrowserView](servo_traits/compositor/browserview.rs)
- create and attach a [Browser](servo_traits/browser/browser.rs) to the BrowserView, load `window.html`, with a special module resolver (see below)
- a JS binding translates the Rust Browser into a JS Browser object (`browser1`)

At this point, *window.html* is rendered full window in the native window.

We want that web page to be able to create other windows within that window (like `<iframes>`, but we want to use `<embed>`).

To do so, we need to be able to create a Browser and a BrowserView in JavaScript.

### Browser:

To expose JS bindings to *window.js*, when the window.html' browser is created in `NewNativeWindow`, a module resolver is registered via `Browser::register_js_module_resolver`

The binding will then be accessible from via a JS module:

`import {Browser} from "Servo";`

**This is how we give special privilege to a Browser**.

At this point, the JS code (`<script>` within `browser1`) can create a new browser (a tab):
`var browser2 = new Browser()`.
This first tab is the second Browser created.
Let's create a second tab: `var browser3 = new Browser()`.

At this point, 3 browsers are accessible:
- browser1, in app.js, run in the JS runtime. It's the top level browser.
- browser2 and browser3, in window.js, run in Servo JS runtime. Two tabs.

*Note: at no point in the Servo API we mention hierarchy. The fact that browser2 and browser3
are "inside" browser1 has no implication.*

### BrowserView:

This is not enough, as these new tabs would be headless. A BrowserView per Browser is necessary.
`browser1` already has a browserview, created in Rust in `NewNativeWindow`.

We want the geometry of the browserview to be part of the layout of the page.
To do so, Servo would use the `<embed>` tag as a browserview, to draw a Browser.
The layout thread of the top level Browser would update the actual BrowserView
coordinates and size.

The browser could be initialized that way:

`var browser2 = new Browser(embed_element)`

The BrowserView methods are not accessible from browser1 script thread.
Same for the Compositor methods.

```
import {CompositorWorker} from "Servo";
var cw = new CompositorWorker('compositor.js')
```

CompositorWorker is a [SharedWorker](https://html.spec.whatwg.org/multipage/workers.html#sharedworker)
run in Servo's Compositor thread, where Compositor's methods are accessible.

Browser JS code and Compositor JS code can communicate via message passing.

Each port of the SharedWorker is a browserview (3 here).

That means all browsers in a window share the same compositor.

# Life of an event

The native window would get a new event, which would be sent as a message to the compositor
worker. It's then up to the JS code in compositor.js to route the event to the proper browser.
If it's a mouse event, `Compositor.get_browserviews_from_point` will return the browserview to target.
If it's a keyboard event, the relevant browserview is the one that is attached to the focused browser.
The event is sent to the browser attached to the browserview, and eventually sent back to the
compositor.

___

*Note: It is important to make `browser/` code and `compositor/` code live in different threads.
We assumed `browser/` lives in the script thread of the host page, and `compositor/` in a worker,
but we could also have both in workers.*
