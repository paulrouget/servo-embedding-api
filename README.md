This is a non-normative and non-functional Rust API proposal for Servo.
It's built from the perspective of an embedder. This is what we would need, at
least, to build a Servo-based browser.

This API is in Rust. We don't want to expose a JS API directly from Servo.

To understand how that fit in the BrowserHTML story, see the JS_API.md document.

# overview

Multiple `Compositor` have multiple `Viewport`.

A `Session` has multiple `Browser` which have multiple `Pipeline`.

A `Viewport` is linked to a `Browser`.

The embedder provides a `Drawable` object, which gives access to the GL context.

A `Compositor` object is built from `Drawable`.

One `Compositor+Drawable` per native window.

A `Compositor` holds a list of `Viewport`.

A `Viewport` is where a web page is drawn.

A `PipelinePreview` is a special type of `Viewport` that can mirror a pipeline from another Browser. Its dimensions don't affect the page layout.

All `Viewport` and `PipelinePreview` have a coordinate, a size, a z-index, an opacity and a background color. All these properties can be changed and animated.

All `Viewport` and `PipelinePreview` are render and clipped by the `Compositor`.

A `Browser` (Servo's Frame) is the equivalent of a tab.

A `Browser` is attached to one `Viewport`.

A `Browser` offers access to most the expect methods and properties to manipulate the history and the web page.

A `Browser` is associated to one `Session`, that controls offline data of for set of documents. Usually, a web browser would only use 2 sessions: a regular one, and a private one.

A `Browser` is associated to several `ContentBlockers`.

A `BrowserHandler` reports all the activity of a browser (history changes, navigation, …).

A `PipelineProxy` gives access to document properties and methods.

A `PipelineHandler` reports all the activity of a document (load state, url changes, title changes, …).

`LoadData` is a structure that holds all the information needed to load or restore a page.

# threads

Compositor and Viewport code lives in Servo's Compositor thread.

Browser code lives in Servo's constellation thread.

# life of an event

The embedder gets an event from the native window.

The relevant compositor is the one associated to the native window.

If it's a keyboard event, the relevant Browser is the focused Browser, which is
known by the embedder.

If it's a mouse/touch/pointer event, Compositor's `get_viewports_from_point()`
method will return all the viewports under the mouse.  (up to the embedder to
pick the highest viewport or not).

Browser's `handle_event` method is used to forward the event to the Browser.
Servo will pick the relevant Pipeline.  A Future is returned. Once the Future
is resolved, the event has been through the page. The returned boolean will
tell the embedder if the event has been consumed by the content (scroll
actually happened, key event has been typed, preventDefault() has been called,
…).

This gives the embedder 2 chances to respond to the event: once received from
the native window, and after it's been through the content.
