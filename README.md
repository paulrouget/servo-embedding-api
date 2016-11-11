**This is a non-normative and non-functional Rust API proposal for Servo. Only used to illustrate and outline a possible Servo embedding API.**

It's built from the perspective of an embedder. It takes into consideration future work that will be required to build a full browser (multi window, session restore, web extensions, permissions, …). It delegates as much as possible to the embedder.

This API is in Rust. We don't want to expose a JS API directly from Servo.

See usage [examples here](https://github.com/paulrouget/servo-embedding-api/issues/2).

To understand how that fit in the BrowserHTML story, see the [JS_API.md](JS_API.md) document.

The API is split in two: [`/compositor/`](servo_traits/compositor)
and [`/browser/`](servo_traits/browser).
One code lives in the Compositor thread, the other in the Constellation thread.



# API Overview

The embedder provides a [`Drawable`](servo_traits/compositor/compositor.rs) object, which gives access to the GL context.

A [`Compositor`](servo_traits/compositor/compositor.rs) object is built from [`Drawable`](servo_traits/compositor/compositor.rs).

One [`Compositor+Drawable`](servo_traits/compositor/compositor.rs) per native window.

A [`Compositor`](servo_traits/compositor/compositor.rs) holds a list of [`BrowserView`](servo_traits/compositor/browserview.rs).

A [`BrowserView`](servo_traits/compositor/browserview.rs) is linked to one or several [`Browser`](servo_traits/browser/browser.rs).

A [`BrowserView`](servo_traits/compositor/browserview.rs) is where a web page is painted.

A [`DocumentView`](servo_traits/compositor/compositor.rs) is a special type of [`BrowserView`](servo_traits/compositor/browserview.rs) that can mirror a document from another Browser. Its dimensions don't affect the page layout.

All [`BrowserView`](servo_traits/compositor/browserview.rs) and [`DocumentView`](servo_traits/compositor/compositor.rs) have a coordinate (glViewport), a size, a z-index, an opacity and a background color. All these properties can be changed and animated.

All [`BrowserView`](servo_traits/compositor/browserview.rs) and [`DocumentView`](servo_traits/compositor/compositor.rs) are rendered and clipped by the [`Compositor`](servo_traits/compositor/compositor.rs).

A [`Browser`](servo_traits/browser/browser.rs) (Servo's Frame) is the equivalent of a tab.

A [`Browser`](servo_traits/browser/browser.rs) is attached to one [`BrowserView`](servo_traits/compositor/compositor.rs).

A [`Browser`](servo_traits/browser/browser.rs) offers access to methods and properties to manipulate the history and the web page.

A [`Session`](servo_traits/browser/session.rs) has multiple [`Browser`](servo_traits/browser/browser.rs) which have multiple [`Document`](servo_traits/browser/document.rs).

A [`Browser`](servo_traits/browser/browser.rs) is associated to one [`Session`](servo_traits/browser/session.rs), that controls offline data of a set of documents. Usually, a web browser would only use 2 sessions: a regular one, and a private one.

A [`BrowserHandler`](servo_traits/browser/browser.rs) reports all the activity of a browser (history changes, navigation, …).

A [`Document`](servo_traits/browser/document.rs) gives access to document properties and methods.

A [`DocumentHandler`](servo_traits/browser/document.rs) reports all the activity of a document (load state, url changes, title changes, …).

[`LoadData`](servo_traits/browser/load_data.rs) is a structure that holds all the information needed to load or restore a page.

# Life of an event

The embedder gets an event from the native window.

The relevant compositor is the one associated to the native window.

If it's a keyboard event, the relevant Browser is the focused Browser, which is
known by the embedder.

If it's a mouse/touch/pointer event, [Compositor's `get_browserviews_from_point()`](servo_traits/compositor/compositor.rs)
method will return all the browserviews under the mouse.  (up to the embedder to
pick the highest browserview or not).

[Browser's `handle_event`](servo_traits/browser/browser.rs) method is used to forward the event to the Browser.
Servo will pick the relevant Document.  A Future is returned. Once the Future
is resolved, the event has been through the page. The returned boolean will
tell the embedder if the event has been consumed by the content (scroll
actually happened, key event has been typed, preventDefault() has been called,
…).

This gives the embedder 2 chances to respond to the event: once received from
the native window, and after it's been through the content.

# Rational

A web browser is made of 3 components: the web engine, the frontend, and the runtime (OS integration). The work we are doing on the API is not about the runtime code (see [#7379](https://github.com/servo/servo/issues/7379) for runtime related work). The web engine is embedded. The web browser application is the embeddee. The proposed API is designed to make embedding Servo possible.

After experimenting with other APIs and web engines, we found three main problems that we want to address:
- Web standards get mixed up and polluted by non-web components (think Browser API & iframes),
- too much abstractions: implementing anything that goes beyond the usual “tabs and history” paradigm is nearly impossible with any existing APIs, as they are designed with the assumption all browsers will be built the same way
- no control over the compositor: we want to move pages around with gestures, bounce them,  scale them… but the current mechanisms jail pages in a rectangle

## Recommendations

### Servo should stay clean and safe contained, and delegate as much as possible

Servo should be only about rendering the web. Servo should worry as little as possible about OS-level problems. These should be handled in a "runtime", which is an orthogonal project.
Servo should not have to worry about non-web related permission management.
Servo should limit as much as possible non-standard behavior. The current Browser API "pollutes" Servo's code base, bends standards (`<iframe mozbrowser>`) and security policies (cross-domain XHR).


Disk IO should be delegated to the embedder where possible (session restore for example should be built at the embedder level).

### Rust only

Servo must stay a library. The exposed API should be a Rust API. It should be possible to build a JS wrapper around that library as a third-party project, same for other languages (C++ bindings, Java bindings, …). **Maybe the next-gen browser won’t be in JS, but in Rust. Let’s not limit the embedder options**.

### Low-level & Granularity

Servo should not expose a "Browser API", and "Web Extension API", and a "Webdriver API", but a low-level-enough API that can be used to build any of these, in any language.


The API should be powerful enough to build a full browser, on mobile and on desktop. The API should be close to the current Servo architecture, and make few assumptions about what the embedder needs. **Abstraction limits future experiment and requires more work on top of Servo. It's "libservo", not "libbrowser"**.

### Open up the compositor/webrender

Most of the known embedding APIs “jail” content into a rectangle with little control over how the page is displayed. The Servo API should not just be about controlling browsing, but also compositing/rendering.


Usually, size of the content is the size of its frame (frame clips the page at its boundaries), events are directly sent to the page, and only the active page is rendered.
We want to have a better control over which events go to the page. We don't want Cmd-W to go though the page. We want Cmd-R to go through the page but know if the content even called preventDefault=true
We want to render non active web page (page from the history), like the swipe-to-go-back feature in Safari (problem with Webkit: this is a builtin feature of the engine, it is not a feature the embedder has access to)
We want to be able to be able to change the UI on scroll, in the compositor. This kind of animation for example: https://youtu.be/Tf6PtZ1Z2eE / https://youtu.be/EhrkAKo4p5g


## Links

- [Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage)
- [Mozilla Browser API](https://developer.mozilla.org/en-US/docs/Mozilla/Gecko/Chrome/API/Browser_API)
- [Electron's webview](http://electron.atom.io/docs/api/web-contents/)
- [Android's webview](https://developer.android.com/reference/android/webkit/WebView.html)
- [iOS's WKWebview](https://developer.apple.com/reference/webkit/wkwebview)


## First steps

The API described here is large, but there's a minimal set of tasks that we can start with:
- We need to fix the top-level browsing context in Servo. We need the ability to have separate top-level browsing contexts. Either kill the root frame, or have multiple constellations.
- Implement "LoadData". It's an "offline" version of a pipeline and contains all the data required to restore a pipeline that has been killed (e.g. through app shut down, or because the pipeline has been purged because it's distant history, or the tab has been closed and we want to restore it). It is also used to open new links in tabs and windows. Basically, improve the "HistoryEntry" struct introduced in #11893
- Implement the "Browser" interface (no need to implement the Document API at this stage)
- figure out how to create and initialise Browser and Compositor (right threads)
- remove `fn main()` from components/servo, make ports/ the entry point, and move event routing to ports/ (maybe use libui-rs)
- build, in a separate repo, a JS binding for this API
- implement BrowserView and makes `<embed>` implement this interface (without `View::set_frame()`)
- implement a JS library that wrap the Servo API into the Browser API
- Now, at this point, we can create a Rust project, that embeds Servo, create a Browser, inject the JS binding to the Browser instance (giving it special privileges), make Servo create a browserview, and we end up with Servo being the embedder and the embeddee
- **get rid of all the mozbrowser code in Servo**
