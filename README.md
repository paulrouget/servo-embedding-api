A Rust API to embed Servo.

WebIDLs are not normative, and not valid. We use WebIDL as an simple way to draft the API.

The Rust traits are closer to final API.

This API tries to delegate as much as possible to the embedder.
For example, the way events propagate from the native window to the pipeline
is all controlled by the embedder.

# Overview

The embedder provides a `Drawable` object, which gives access to the GL context.

A `Compositor` object is built from `Drawable`.

One `Compositor+Drawable` per native window.

A `Compositor` holds a list of `Viewport`s.

A `Viewport` is where a web page is drawn.

A `PipelinePreview` is a special type of `Viewport` that can mirror a pipeline from another Browser. Its dimension don't affect the page layout.

All `Viewport`s and `PipelinePreview`s have a coordinate, a size, a z-index, an opacity and a background color. All these properties can be changed and animated.

All `Viewport`s and `PipelinePreview`s are render and clipped by the `Compositor`.

A `Browser` (equivalent of Servo's Frame) is the equivalent of a tab.

A `Browser` is attached to one `Viewport`.

A `Browser` offers access to most the expect methods and properties to manipulate the history and the web page.

A `Browser` is associated to one `SessionStorage`, that controls offline data of for set of documents. Usually, a web browser would only use 2 sessions: a regular one, and a private one.

A `Browser` is associated to several `ContentBlockers`.

A `BrowserHandler` reports all the activity of a browser (history changes, navigation, …).

A `PipelineProxy` gives access to document properties and methods.

A `PipelineHandler` reports all the activity of a document (load state, url changes, title changes, …).

`LoadData` is a structure that holds all the information needed to load or restore a page.


