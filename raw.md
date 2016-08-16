
~~~~

For viewport:
- frame + bounds
- bounds could be defined with padding, which can be animated via CSS transitions!


Get color information for favicon. Pipeline sampling. See #973


https://github.com/browserhtml/browserhtml/issues/1227

~~~~~
another neat idea!
What if when you click a link on a page we slide current page slightly down and slide new page on top with a progressbar
so that your current page is still usable and interactive
but once initial load is complete then we slide the previous page out and new page in
that’s kind of another use case for having pipeline controls vs just iframe


~~~~~

notes from meetings:

Irakli says: no container, only pipeline, no <pipelineoutput>
Paul: I think it's possible, but container necessary

Irakli and Paul: agreed to have a non-including top level element (webview), but a parallel element (viewport)

At the end:

<pipeline>
<viewport>:
- coordinates, position
- content margins
- visibility
- private browsing
- focus

need a way to create new pipeline in JS

low level first, then gfx integration (because rust and js have different rendering mechanism) with Glenn 

<pipelineoutput> will just be <pipeline preview-mode>

Removing a <pipeline> element should kill the internal servo pipeline.

How does lifetime.

DOM mutation API


How do we create pipeline: open question, dunno yet

****make it possible to create pipeline ahead maybe for preload an stuff***



~~~~


Servo's constrains:
- speed
- spec
- not pollute servo
- minimal embedding API
- use without JS
- not tight to DOM
- developer experience vs. impact on servo

```
My suggested API:
- less intrusive
- thinner connection to servo internals
- a lot of the implementation can be done in JS
- a micro low level rust+js API will be used

we need higher level for:
- rendering:
    - toolbar mechanism, think about overflow (osx style), scrollgrab
    - shared layout
- how would you load a new URL?
- higher level API and shared properties (visibility, focus, privatebrowsing, …)
- event propagation
- easier for Servo internals

We need a mirror tag for:
- CSS styling
- no layout constrains

```


~~~~~

Irakli said:

@paul: in regards to visibility, can `setVisibility(v)` fail ? And if so can user really do anything about it ? If no then only reason promise is there is to observe when that property got reflected, but then there is an event already for that user can listen to, so if someone want’s promise flavored API it’s trivial to make one with setter + event listener.
I guess what I meant implied that was not obvious is that setting a visibility did not imply that property getting the visibility will return new value. Which I guess may be misleading. But I think it’s better to go about it differently more or less how `iframe.src` works. If you change `src` it does not mean page is loaded but merely that load was scheduled & there are events to let you know about the progress of that task.
I think it would be best if there was something along this lines (changing naming because I think visibility is confusing).

```js
element.setAttribute(‘priority’, 0)
element.getAttribute(‘priority’) // => “0”
element.priority // 0
element.isSuspended() // => false
element.addEventListener(“suspend”, event => {
```

Idea is that you can control “visibility” (which I’d rather replace with a diff name) in this case via `priority` sync regular DOM prop / attribute. Changes to the `priority` asynchronously  get reflected on the pipeline and cause event on the element. In nutshell idea is that you have regular property that reflects state on the client thread and getter method only to check what the state of things are on the server.
Not sure if the `client` and `server` naming was very clear, but what I meant is “front end JS” and “Servo engine”. (edited)
The reason I prefer this approach is because it’s simple & compatible with DOM abstractions. Advanced will imply listening to event and doing extra stuff but  other than event handling it’s all declarative.
In regards to `<webview>` & `<pipeline>`, I’ll start with that it’s magnitudes  better than anything I’ve seeing out there. There are some questions / suggestion / thoughts I have is no particular order: (edited)
1. Attributes that you can’t change does not seem like a great idea. At best users will learn that they are read only, but more likely it will cause some confusion. I think `thing.getFaveicon()` and associated event is better as it’s ambiguous. I also think it’s ok to leave out read-only getters functions in first iteration and just have events as those getters functions can be implemented in user land and also added later on.
2. `pipelineid` attribute raises same questions ? What if I change it, what if I add another element myself what should attribute value be etc. I think `element.getPipelineID()` or something like that is a way better for the same reasons.
3. More I think about this stuff more I’m convinced that `<webview/>` is just a **container** that logically groups `<pipeline>`s  and provides few functions to do multiple `<pipeline>` operations in one call, which just as easy could be done in JS. For example `webview.goTo(offset)` could be expressed as:
```const goTo = (offset, pipeline) => {
  pipeline.priority = SUSPENDED;
  const pp = getPipelineContainer(pipeline).querySelector('pipeline');
  const index = Math.max(Math.min(pp.indexOf(pipeline) + offest, 0), pp.length);
  pp[index].priority = PRIMARY;
}

const goBack = goTo.bind(null, -1);
const goForward = goTo.bind(null, 1);
```
4. If you get rid of `<webview>` tag you no longer will need to have `<pipelineoutput>` instead you can have different values for `pipeline.priority`.

```// Pipeline is killed. Displays nothing. Can not be restored.
const DISPOSED = -1;
// Pipeline is frozen. Displays nothing. Can be restored.
const FROZEN = 0;
// Pipeline is frozen. Displays last rendered pixels. Can be restored.
const SUSPENDED = 1;
// Pipeline is interactive in it's group. Renders interactive page. Can be frozen.
const PRIMARY = 2;  
```

I think it’s totally OK if making a pipeline from the “same session group” automatically degrades priority of the currently “primary” pipeline from the same “same session group”.
This also composes well with the `priority` and `isSuspended` separation, as again “priority” attribute is just users “request” actual decision are made by servo and communicated via events. What I mean is that even if I user code has an error and two `<pipelines>` have `PRIMARY` priority it’s somewhat clear that engine decides which one will actually get priority and which one does not. (edited)
5. If you get rid of `<webview>` you still can do same stuff with open / close as you described, it’s just “open” event will be triggered on the initiating `<pipeline>` and user would have to create element etc as you described. `pipelineid` is kind of doomed to be odd though, but I can’t really think of any better way though.
6. At the end of the day I think only reason for `<webview>` to exist is to group pipelines in one session group where only one of them can be interactive no ? If so I would much rather have `sessionid` attribute instead.
To summarize what I’m suggesting is unite `pipeline` and `pipelineoutput` under single element (& please choose a different name) and use some property to control it’s state. Like if it’s interactive, styleable (your pipelineoutput) or suspended (I presume there is a reason why we want to differentiate between suspended & styleble pipelines, if not they should just be a same thing IMO). That would avoid necessary coordination between `<pipeline>`s and `<pipelineoutput>`s. Get rid of the `<webview>`  tag (or better yet rename `<pipeline>` to `<webview>`) and let’s use some attribute to group pipelines. That way we’ll be more flexible in layout & styling & parent container elements and all it’s utilities can be implemented in userland. That would also allow experimentation via web components to provide the best container API. It also get’s rid of the error surface like what if I set two pipelines as selected etc. To receive events from all pipelines from the same session just set up listeners on the common ancestor and handle bubbled events.
After reflecting on my feedback, I think I’d recommend to don’t even bother with `getFaveicon()` and `element.isSuspended()` like getters only & just have events. We can add those after we learn more from our experience.



Irakli said:

@paul: I really care about declarativeness of the API, otherwise it becomes kind of a pain to deal with with virtual-dom like abstractions or tempalting. So ideally API would be as declarative as possible.
@paul: I think `webview.state` that is JSON is ok, but odd though
@paul: I think regular properties like `input.selectionStart` or alike would be better as it will be more consistent with rest of the DOM. I think it would also make sense if those were reflected in as attributes but probably not too big of deal if they remain just as properties. Web platform already has instances like that above mentioned `input.selectionStart` is one of them.
In regards to getting read of `event.details` one thing is to keep in mind is that sometimes events let you cancel effect of it. So in some cases you may want to have details presumably because event will occur before change is made to the webview and not just to notify that change happened. Now weather we want such thing in webview API or not is a different subject and deserves weighting cons / pros IMO.
@paul: So at first you said you want to put all of the current state into JSON like structure but now you’re considering communicate that user is navigating back via events. I definitely want some notification, but never the less I still think it is useful to expose all of the parts of the state as getters or properties or attributes as otherwise it means user needs to keep track of events and store that state somewhere on the side, which is not ideal.
@paul: I really hate `.goBack()` though I would strongly prefer declarative API. The thing is if there is no declarative API we still end up creating one and use imperative API under it. I would much rather solve that problem at the core if that makes sense.
@paul: This kind of how I realized fundamental problem with mozbrowser iframe API as well. The only reason we need imperative methods like that is because we have no way of talking or referring to a pages (a.ka. pipelines). That is why in ideal case you would just have elements for pages (a.k.a pipelines) that would have url and some of it’s state. Then webview is just a sugar to help restoring / freezing pipelines and stuff like that.
Now I it’s understandable if you don’t want to solve all problems in one go and there will be compromises. While doing compromises I’d stick to the following principles:
1. If there is a piece of state that can be mutated it should be exposed as property (and preferably also as an attribute).
2. If there is a piece of state that can not be mutated, it should not have a attribute or property. Changes to that state should be communicated via event and possibly `.getThatProperty()` functions should be there as well that return value right away no promise or any of that stuff. The reason I think method is preferable there is: A. There is no way to make a mistake of trying to  mutate it, it’s clearly read-only. B. I expect that users will mutate their own state on events, but such getters would help testing that all updates are handled properly. C. No promises! Platform should just update state on the main thread on an appropriate state change events & never query other thread for the info, in fact only reason there will be a getter functions is so that it’s clear that it’s a read-only state.
3. Prefer property over `.goBack()`, `stop()` etc. That one is tricky but again not solving this problem at the platform level just makes it user space problem. For example instead of `goBack` having something like an `offset` is magnitudes better & it does not even has to expose anything new. It’s better because now you can jump several steps back / forward and it’s declarative so compatible with abstractions like virtual-dom or templating. Stop is trickier as you can’t even represent it with a boolean field like `paused` as you can’t unpause it. But I guess `stopped:Boolean` is still better than `.stop()` it’s just unstopping it will have no consequence but I think that’s alright.
@paul: I hope that explains where I stand in terms of API design.
@paul: If it was up to me, I would in fact go ahead and say let’s not have `webview` which is flavor of `iframe` at all. But just have tags that represent `pipelines` and we can implement things like `webview` ourselves. How to optimize such an API can be optimized is definitely conversation worth having with @asajeffrey @cbrewster


~~~~ Paul's answer:

@gozala: thanks for your feedback. It's definitively useful. Question: you say no promises. I can see how to do that for the getters. But what about operations that can't be sync, like setting `visibility` for example. We can't block the main thread just to wait until it's actually done.  Does that mean that for any non-sync operations we have a setter: `setVisibility(…)` and a getter `getVisibility(…)`?
@gozala: there are so many things to expose to a single element. A thing I'm exploring that is kind of compatible with what you're describing: imagine we have a `<pipeline>` tag, which has its own event/properties. What I'd really like to do is to have 3 tags. This is totally WIP, and there are known issues with this approach, but let me know what you think:

```xml
<webview>
  <pipeline pipelineid="{0:1}" url="…" favicon="…"></pipeline>
  <pipeline pipelineid="{1:1}" url="…" favicon="…" selected></pipeline>
  <pipeline pipelineid="{2:1}" url="…" favicon="…"></pipeline>
</webview>
<pipelineoutput forpipeline="{0:1}"></pipelineoutput>
```
The `<pipeline>` tags would never render anything (its size is 0x0). It's done by the `<webview>` tag. All the frame level operations/events would happen in `<webview>` (like `setVisibility`).
Each pipeline would have its set of events (load, security changed, …) ​*(Question: in the above example, a `<pipeline>` has a `favicon` attribute, which is supposed to be a readonly thing. So does that means it needs to be moved into a JS property (`pipeline.getFavicon()`)?)*​
For history management: Something like `mozbrowser.goBack()` would translate into toggling the `selected` attribute on the right pipeline element (note: the `<webview>` tag might also fire an event when another pipeline is selected, for example when the history is manipulated by the content).
`<pipelineoutput>` is just a way to mirror a pipeline (only render the page, no input) that can be styled in CSS. This will be used to show the previous page with the gestures (go back).
An important note: the `<pipeline>` DOM node would ​*not*​ be created by Servo when the user navigates to a new page, and it's not necessary to have a `<pipeline>` DOM element for Servo to be able to create an internal pipeline. This is how it would work: the user is visiting foo.com. There's only one pipeline. He clicks on a link to bar.com. A new internal pipeline is created. The page starts loading. `<webview>` emits an "new-pipeline" event. It's up to browserhtml to create and append the `<pipeline>` tag, and add the new event listeners, linked to the internal pipeline (via the `pipelineid`). It will  also be up to browserhtml to remove the `<pipeline>` tag and the event listeners. The reason why this is important is that 1) we don't want to force people who use Servo to use this API, so pipeline can exist without a DOM representation 2) we don't want the lifetime of a pipeline to depend on the lifetime of its DOM representation (that's one of the reason that gecko was struggling with `window.open`), 3) I don't know any standardised DOM elements that create/remove elements by itself
There will also be a new set of events/properties: pipeline frozen, pipeline dropped, …
Also, it's going to be possible to move pipeline from a `<webview >`to another `<webview>`, to support things like `window.open`, and it will be possible to create new pipeline from scratch, from things like session restore.
Don't look too much into the details, and let me know what you think.



~~~~


Addressing https://github.com/browserhtml/browserhtml/issues/639
Also see: https://github.com/servo/servo/issues/7083


Webview +

- no `<iframe>`
- better history mgt
    - control its length
    - no bookeeping
    - gundo style: https://github.com/benfrancis/webview/issues/4
- tag should be declarative! (maybe with pipelineid="…") … see how other HTML elements work. No "src" attr, or update attribute over time
- more hooks for preventing behavior
- more granular API
- history + declarative, Irakli says:
    - I think the best compromise without changing API too much would be to add something like document.readyState that could have values like uninitialized / going back / going forward / reloading / stoping / loading / interactive / complete. If that was also exposed as an attribute that would even make API declarative and there for make it compatible with DOM abstraction libraries.
- no no-op attributes after DOM insertion
- hook on "will-navigate". See https://github.com/browserhtml/browserhtml/issues/553
    - allow detaching pipeline from a frame and render it in another iframe/webview. Think "navigating to another domain from pinned tab:
- initiate from pipeline
    - see https://github.com/browserhtml/browserhtml/issues/382
- have a global JSON object representing the r/o info
- better window.open / openwindow / opentab events
- smarter security model?
- a general read-only property that tells use the current state of the iframe ("goingback", or maybe just "navigating")
- way to discuss with content. executeScript with postMessage back to chrome process
- content blocker?
- privatebrowsing?
- key, gesture & scroll events propagation
    - Event propagation / delegation should be specified. Ex: https://github.com/browserhtml/browserhtml/issues/317
    - forcetouch, escape issue
    - Even bubbling / capturing is a mess. There is no deterministic behavior in some cases embedder can handle / prevent events before it reaches content of the mozbrowser and in other cases it can not. It's specially messy for keyboard events some OS level keybindings seem to trigger on the content while others do not we still have a specific outstanding issue #317 related to this. I think the most reasonable to implement same bubbling / capturing as with regular iframes so that outer document could cancel propagation with a capture phase and content document could cancel bubbling to outer document by canceling event in bubbling phase. I won't even start talking about scroll events.
- We need a way to smoothly change the viewport without resizing the iframe from the parent process https://github.com/browserhtml/browserhtml/issues/355
- how to: session restore



~~~~~~~~~


Do we want a new API, what's the benefit?
If we share with Electron, we can also share a test suite.
That would not suite us perfectly, but good enough?

~~~~~~~~~

Browser API V2: study docshell/pipeline, browser api, webview, CEF

- status (r/o)
- methods (write)
- events
- initialization
- security model
- gfx


- link preview
- dns prefetching, preload
- content blockers
- popup story
- key, gesture & scroll events propagation
on crash?

Very important to understand http://electron.atom.io/docs/api/web-contents/#event-new-window
- question: by default a new window (native) is create and load the url in it?
- preventDefault() can prevent that

Not sure, but I think there are events for webview, but also events per "pipeline" (webContent), makes event handling easier?
But there's also webview.webContents.contents (like contents.loadURL())
-> it's all the same thing!


Maybe have global events/methods for the array of pipeline, and events/methods for specific pipeline (for example, handle focus, … but what else?)


https://github.com/browserhtml/browserhtml/issues/639

_______

HOWTO

The transparent toolbar thing? Like… define visible frame and stuff. scrollsnapping and scrollgrab? What about synced anim with scroll or animations/transitions?
Context menu? https://github.com/browserhtml/browserhtml/issues/29
overscroll
sharing setting with content?
cmd/ctrl/middle click
target, browsing context, referer and opener support

private browsing
now if native titlebar is on or off

how to swipe- if swiping is handled in JS, how does one access this kind of information: https://github.com/servo/servo/issues/6226 (3 fingers vs 2 fingers). <- this is an interesting use case and can be used as an example in the final document




Do we need “preload”? https://github.com/electron/electron/blob/master/docs/api/browser-window.md



________


We don’t have to design for JS only. Rust API?

Now if native titlebar is on or off

Is JS/HTML the way to go?

Make it so servo stays a Web engine 
How to include gecko 

read about CEF: https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage

Extension model


￼


read https://medium.freecodecamp.com/browserhistory-2abad38022b1#.5f93efn9o

I’m wondering if there’s a way to reunite the Browser API, webdriver, and webextension, devtools API…


@gozala, about the Browser API V2, I’m trying to understand what could have a significant impact on the servo internals.

Is the tree-based history a thing that really matters or that was just an idea for an experiment we wanted to do?

Let’s imagine we implement something like
`
<webview>
`
, with 3 additions:
1) access to history entries, back and forward (url, title, pipelineid (if the pipeline hasn’t been dropped))
2) we can initiate a webview from an already internally loaded document, with an id, like
`
<wevbiew pipelineid="(1,2)">
`
(to avoid the ugly iframe attached to the
`
bmozrowserwindowopen
`
event)
3) we introduce a new tag (
`
<pipeline>
`
) that can mirror any frozen (or not even frozen) pipeline that haven’t been dropped. We could style this in CSS  (like
`
-moz-element
`
in Gecko)

Can we assume that, beside these things, any changes we want to make to the API are not significant and mostly cosmetic?

There are some other internal changes I’d like to propose (for example, I’d like to understand why we don’t have one constellation per tab), but I don’t think this will impact the API itself.

understand webdriver

read https://github.com/ConnorGBrewster/ServoNavigation && https://github.com/servo/servo/pull/11866#issuecomment-233522345 (most up to date is apparently https://github.com/asajeffrey/ServoNavigation/blob/master/notes/notes.pdf)

libui(-rs)


~~~~~

An API to handle pipelines, with no iframe at all. For example, we want to be able to freeze pipeline, drop/purge them.

Time machine like UI for history entries.

The Browser API v2 needs to include: history entries manipulation, render pipelines, initiate iframe.

Irakli wants to delegate the history entries construction to JS.

Use case: Build a vim:GUndo-like visualisation of the history from a tab, and maybe to drop a branch.


Irakli said perfect if: read-only access to history entries + rendering of frozen pipeline

Also, how do we do screenshot of a pipeline for session restore & co.

~~~~~

Look at the context graph project.

executeScript / webextension to get content from the page.


~~~~~


Figure out if we really need swipe gestures:
For browser.html, we want to be able to respond to two-finger gestures, and move things around according.
Here is a video showing http://fat.gfycat.com/ElatedDistantDrever.mp4
Maybe we only need scroll gestures???
2. Expose raw trackpad touch events as regular DOM touch events. Trackpad touch events do not come with on-screen coordinates, but trackpad-relative coordinates, so it's not exactly touch events like on mobile. But maybe we can extend the touch events to include `trackpadX|Y` coordinates.
3. Moving 2 fingers on the trackpad is also used for scrolling. So we want scrolling to happen, and then get swipe events. The ultimate goal is to pan/move objects when we reach its scroll limit (if scrollable, otherwise, we start panning right away). So maybe a solution that would mix overscroll (https://github.com/servo/servo/issues/7671) and scroll events,  
See also:
* Gecko's `MozSwipeGesture*` events: https://dxr.mozilla.org/mozilla-central/source/dom/interfaces/events/nsIDOMSimpleGestureEvent.idl
* Cocoa reference: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/HandlingTouchEvents/HandlingTouchEvents.html


~~~~~


Servo:
- Rendering: https://github.com/mozilla/browser.html/issues/562
- Browser API: https://github.com/mozilla/browser.html/issues/639


http://electron.atom.io/docs/api/web-view-tag/
http://electron.atom.io/docs/api/web-contents/



~~~

