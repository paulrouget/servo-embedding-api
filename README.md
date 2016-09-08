**WIP**

webidls status: check top level comment of each file
- *draft* means some details need work, but the scope is well defined
- *WIP* means the way the interface plays with the others has not been figured out yet

This project is an attempt to put together a multi-purpose low-level API to
embed and control Servo.

The initial motivation is to improve Mozilla's [Browser
API](https://developer.mozilla.org/en-US/docs/Web/API/Using_the_Browser_API),
which is a set of extra methods, property and events on top of the DOM
`<iframe>` element (mozbrowser). After experimenting with Gecko's and Servo's
implementation of the Browser API, and Electron's `<webview>`, we started
drafting a potential V2 of the API.

This API proposal is also designed to be used to implement the
[WebExtension](https://developer.chrome.com/extensions) API (in combination
with Runtime API and application-specific implementations).

Even though the API is described with WebIDL, we try to avoid relying much (or
at all) on DOM, as we eventually want to make this API available for non-JS
consumers (embedding Servo in a Rust app for example). Anything DOM-specific
has its own section.

The main goals of this API are:
- exhaustive and granular. We want it to cover enough that it will suffice for
  most Servo embedders
- minimal impact on Servo's internals
- minimal impact on standardised components (unlike the current Browser API
  that re-use the `<iframe>` element)
- non-blocking (both directions)

"ease-to-use" and "abstractions" are not goals. We want to be close enough to
Servo's implementation. We don't want to limit the API too early for the sake
of simplification (this can be done later on top of this API).

This low level API covers only **Servo <-> embedder** communication. This is
not enough to build a full browser application, which requires some other extra
powers, like access to the operating system. This project doesn't address this
problematic as it's an orthogonal problem (we usually refer to app level or
operating system access as "Runtime).
