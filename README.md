This is a non-normative and non-functional Rust API proposal for Servo.
It's built from the perspective of an embedder. This is what we would need, at
least, to build a Servo-based browser.

This API is in Rust. We don't want to expose a JS API directly from Servo.

See usage [examples here](https://github.com/paulrouget/servo-embedding-api/issues/2).

To understand how that fit in the BrowserHTML story, see the [JS_API.md](JS_API.md) document.

The API is split in two: [`/compositor/`](servo_traits/compositor)
and [`/browser/`](servo_traits/browser).
One code lives in the Compositor thread, the other in the Constellation thread.

# overview

A [`Viewport`](servo_traits/compositor/viewport.rs) is linked to a [`Browser`](servo_traits/browser/browser.rs).

The embedder provides a [`Drawable`](servo_traits/compositor/compositor.rs) object, which gives access to the GL context.

A [`Compositor`](servo_traits/compositor/compositor.rs) object is built from [`Drawable`](servo_traits/compositor/compositor.rs).

One [`Compositor+Drawable`](servo_traits/compositor/compositor.rs) per native window.

A [`Compositor`](servo_traits/compositor/compositor.rs) holds a list of [`Viewport`](servo_traits/compositor/viewport.rs).

A [`Viewport`](servo_traits/compositor/viewport.rs) is where a web page is drawn.

A [`PipelinePreview`](servo_traits/compositor/compositor.rs) is a special type of [`Viewport`](servo_traits/compositor/viewport.rs) that can mirror a pipeline from another Browser. Its dimensions don't affect the page layout.

All [`Viewport`](servo_traits/compositor/viewport.rs) and [`PipelinePreview`](servo_traits/compositor/compositor.rs) have a coordinate, a size, a z-index, an opacity and a background color. All these properties can be changed and animated.

All [`Viewport`](servo_traits/compositor/viewport.rs) and [`PipelinePreview`](servo_traits/compositor/compositor.rs) are rendered and clipped by the [`Compositor`](servo_traits/compositor/compositor.rs).

A [`Browser`](servo_traits/browser/browser.rs) (Servo's Frame) is the equivalent of a tab.

A [`Browser`](servo_traits/browser/browser.rs) is attached to one [`Viewport`](servo_traits/compositor/compositor.rs).

A [`Browser`](servo_traits/browser/browser.rs) offers access to methods and properties to manipulate the history and the web page.

A [`Session`](servo_traits/browser/session.rs) has multiple [`Browser`](servo_traits/browser/browser.rs) which have multiple [`Pipeline`](servo_traits/browser/pipeline.rs).

A [`Browser`](servo_traits/browser/browser.rs) is associated to one [`Session`](servo_traits/browser/session.rs), that controls offline data of a set of documents. Usually, a web browser would only use 2 sessions: a regular one, and a private one.

A [`BrowserHandler`](servo_traits/browser/browser.rs) reports all the activity of a browser (history changes, navigation, …).

A [`Pipeline`](servo_traits/browser/pipeline.rs) gives access to document properties and methods.

A [`PipelineHandler`](servo_traits/browser/pipeline.rs) reports all the activity of a document (load state, url changes, title changes, …).

[`LoadData`](servo_traits/browser/load_data.rs) is a structure that holds all the information needed to load or restore a page.

# life of an event

The embedder gets an event from the native window.

The relevant compositor is the one associated to the native window.

If it's a keyboard event, the relevant Browser is the focused Browser, which is
known by the embedder.

If it's a mouse/touch/pointer event, [Compositor's `get_viewports_from_point()`](servo_traits/compositor/compositor.rs)
method will return all the viewports under the mouse.  (up to the embedder to
pick the highest viewport or not).

[Browser's `handle_event`](servo_traits/browser/browser.rs) method is used to forward the event to the Browser.
Servo will pick the relevant Pipeline.  A Future is returned. Once the Future
is resolved, the event has been through the page. The returned boolean will
tell the embedder if the event has been consumed by the content (scroll
actually happened, key event has been typed, preventDefault() has been called,
…).

This gives the embedder 2 chances to respond to the event: once received from
the native window, and after it's been through the content.
