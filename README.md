**WIP**

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
operating system access as "Runtime").

# Overview

Basic structure is: A browser holds a reference to history entries, that hold
a reference to a pipeline. A Browser is rendered in a Viewport.
A Pipeline can be rendered independently.

Pipeline can live without a history entry or a browser (orphan pipeline).

The embedder holds a list of Browser objects.

## [Browser](webidls/Browser.webidl)

Servo equivalent: a top level Frame.

Equivalent of a tab, a top level browsing context. Holds a reference to a
StorageSession object ([see bellow](#storagesession)). Holds a list of HistoryEntries
([see below](#historyentries)). Holds a list of ContentBlockers ([see below](#contentblockers)).
One history entry is active (current pipeline).

Holds default properties for future pipelines.

Responsible for the navigation through the history. Fire events when a new entry
is available (user clicks on a link).

## [HistoryEntries](webidls/HistoryEntry.webidl)

Servo equivalent: FrameState.

Holds an optional reference to a pipeline. Pipeline might be dead. Holds a
reference to LoadData ([see below](#loaddata)).

## [Pipeline](webidls/Pipeline.webidl)

A page.

A reference to a servo pipeline. Offers access to many internal information
about the document. Fires many events to keep track of the document status
(loading state, security state, etc) and request user actions (prompts,
security questions, …).

Can be pending, loading, interactive, complete (loaded).

A pipeline implements some extra interfaces: [Editable](webidls/Editable.webidl)
(to build the app "edit" menu), [FindInPage](webidls/FindInPage.webidl) (to build
a in page text search), [HTTPObserverManager](webidls/HTTPObserverManager.webidl)
(to track and overwrite HTTP connections), [MultimediaManager](webidls/MultimediaManager.webidl)
(to track multimedia content, to silence a tab for example),
[Printable](webidls/Printable.webidl) (to implement Print to printer or Print to PDF).

To preloada page (first result in the urlbar for example),
it's possible to create a new "orphan" pipeline and later attach it to a
Browser, as long as they share the same session.

## [LoadData](webidls/LoadData.webidl)

Serializable. Minimal set of information to create or restore a pipeline. Is
used to save a history entry if pipeline is being purged (#11893). Is used to
restore session (list of LoadData can be store on disk). Is used to transmit
request, to the embedder, to open a new window or a new tab.

## [StorageSession](webidls/Session.webidl) 

The StorageSession object, and restore session.

Holds offline data: appcache, cookies, fileSystem, indexdb, localStorage,
serviceworkers. Has methods to clear data. Is serializable to write to disk.

No disk IO is done in Servo.

Up to the embedder to save and restore data from disk.

A storage session stores offline data (cookies, localStorage, …). To build a
session recovery, storage session needs to be serialized and written to disk,
along with a list of list of list of LoadData (for tab restore). List of list
of list because a browser is usually made of a list of windows made of a list
of tabs made of a list of history entries. It's up to the embedder to
regularly saved the session. The process of writing the storage session and
the loaddata will require disk access, which is supposed to be handled by the
embedder.

## [ContentBlockers](webidls/ContentBlockers.webidl)

A Browser has access to multiple content blockers: Popup blocker, tracking
content blocker, mixed content blocker, custom blocker (à la Safari). A
pipeline can temporarly enable/disable a content blocker.

## [Viewport](webidls/Viewport.webidl)

Where a pipeline is rendered.

We want to dissociate clipping area and content boundaries. A viewport object
defines the boundaries geometry.

A viewport is responsible to pass keyboard/mouse/touch events to the
Browser/pipeline.

3 types of viewport:
- interactive: its layout define the size of the rendered pipeline. Events
  are forwarded to the pipeline.
- passive: used to preview a (possibly) frozen pipeline. Its size does NOT
  affect the pipeline.
- headless: not graphic output


