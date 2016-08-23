dictionary LoadURLOptions {
  URL httpReferrer;
  DOMString useragent;
  DOMString extraHeaders;
};


dictionary FindOptions {
  boolean forward;
  boolean findNext; //Whether the operation is first request or a follow up
  boolean matchCase;
  boolean wordStart; // Whether to look only at the start of words. defaults to false.
  boolean medialCapitalAsWordStart; // When combined with wordStart, accepts a match in the middle of a word if the match begins with an uppercase letter followed by a lowercase or non-letter. Accepts several other intra-word matches, defaults to false.
}

enum StopFindInPageAction {
  "clearSelection", // Clear the selection
  "keepSelection", // Translate the selection into a normal selection.
  "activateSelection", // Focus and click the selection node
};

dictionary PrintOptions {
  Number marginsType; // - Specifies the type of margins to use. Uses 0 for default margin, 1 for no margin, and 2 for minimum margin.
  String pageSize; // - Specify page size of the generated PDF. Can be A3, A4, A5, Legal, Letter, Tabloid or an Object containing height and width in microns.
  boolean printBackground; // - Whether to print CSS backgrounds.
  boolean printSelectionOnly; // - Whether to print selection only.
  boolean landscape; // - true for landscape, false for portrait. 
}


dictionary InputEventOption {
  String type; // (required) - The type of the event, can be mouseDown, mouseUp, mouseEnter, mouseLeave, contextMenu, mouseWheel, mouseMove, keyDown, keyUp, char.
  String[] modifiers; // - An array of modifiers of the event, can include shift, control, alt, meta, isKeypad, isAutoRepeat, leftButtonDown, middleButtonDown, rightButtonDown, capsLock, numLock, left, right.
}

enum SaveType {
  "HTMLOnly", // Save only the HTML of the page.
  "HTMLComplete", // Save complete-html page.
  "MHTML", // Save complete-html page as MHTML.
}

interface Webview {



  // HTML attributes:



  // Returns the visible URL. Writing to this attribute initiates top-level
  // navigation.  Assigning src its own value will reload the current page.
  attribute URL src;

  // If autosize “on”, the webview container will automatically resize within
  // the bounds specified by the attributes minwidth, minheight, maxwidth, and
  // maxheight. These constraints do not impact the webview unless autosize is
  // enabled. When autosize is enabled, the webview container size cannot be
  // less than the minimum values or greater than the maximum.
  attribute DOMString autosize;
  attribute DOMString minwidth;
  attribute DOMString minheight;

  // If “on”, the guest page in webview will have node integration and can use
  // node APIs like require and process to access low level system resources.
  attribute DOMString nodeintegration;

  // If “on”, the guest page in webview will be able to use browser plugins.
  attribute DOMString plugins;

  // Specifies a script that will be loaded before other scripts run in the
  // guest page.  The protocol of script’s URL must be either file: or asar:,
  // because it will be loaded by require in guest page under the hood.  When
  // the guest page doesn’t have node integration this script will still have
  // access to all Node APIs, but global objects injected by Node will be
  // deleted after this script has finished executing.
  attribute URL preload;

  // Sets the referrer URL for the guest page.
  attribute URL httpreferrer;


  // Sets the user agent for the guest page before the page is navigated to.
  // Once the page is loaded, use the setUserAgent method to change the user
  // agent.
  attribute DOMString useragent;

  // If “on”, the guest page will have web security disabled.
  attribute DOMString disablewebsecurity;

  // Sets the session used by the page. If partition starts with persist:, the
  // page will use a persistent session available to all pages in the app with
  // the same partition. if there is no persist: prefix, the page will use an
  // in-memory session. By assigning the same partition, multiple pages can
  // share the same session. If the partition is unset then default session of
  // the app will be used.  This value can only be modified before the first
  // navigation, since the session of an active renderer process cannot change.
  // Subsequent attempts to modify the value will fail with a DOM exception.
  attribute DOMString partition;

  
  // If “on”, the guest page will be allowed to open new windows.
  attribute DOMString allowpopups;

  // A list of strings which specifies the blink features to be enabled
  // separated by ,. The full list of supported feature strings can be found in
  // the RuntimeEnabledFeatures.in file.
  attribute DOMString blinkfeatures;
  attribute DOMString disableblinkfeatures;

  

  // DOM properties
  // Note: The webview element must be loaded before using the methods.


  void loadURL(URL url, LoadURLOptions loadURLOptions);
  URL getURL();
  DOMString getTitle();
  // Returns a boolean whether guest page is still loading resources.
  boolean isLoading();
  // Returns a boolean whether the guest page is waiting for a first-response
  // for the main resource of the page.
  boolean isWaitingForResponse();

  void stop();
  void reload();
  void reloadIgnoringCache();

  boolean cangoBack();
  boolean cangoForward();
  
  boolean canGoToOffset(Number offset);

  void clearHistory();
  void goBack();
  void goForward();
  
  void goToIndex(Number index);
  void goToOffset(Number offset);

  boolean isCrashed();

  void setUserAgent(DOMString ua);

  DOMString getUserAgent();

  void insertCSS(DOMString code);

  // Evaluates code in page. If userGesture is set, it will create the user
  // gesture context in the page. HTML APIs like requestFullScreen, which
  // require user action, can take advantage of this option for automation.
  void executeJavaScript(DOMString code,
                         boolean userGesture /* pretend user-triggered action */,
                         Function callback);

  void openDevtools();

  void closeDevtools();
  boolean isDevToolsOpened();
  boolean isDevToolsFocused();
  void inspectElement(Number x, Number y);
  void inspectServiceWorker();
  void addWorkSpace(path);
  void removeWorkSpace(path);
  void hasServiceWorker(callback);
  void unregisterServiceWorker(callback);
  void enableDeviceEmulation(parameters);
  void disableDeviceEmulation();



  void setAudioMuted(boolean muted);
  boolean isAudioMuted();


  void undo()
  void redo()
  void cut()
  void copy()
  void paste()
  void pasteAndMatchStyle()
  void delete()
  void selectAll()
  void unselect()
  void replace(DOMString text)
  void replaceMisspelling(DOMString text)
  void insertText(DOMString text)


  void findInPage(DOMString text, FindOptions? options);
  void stopFindInPage(StopFindInPageAction action);

  void print(PrintOptions options);
  void printToPDF(PrintOptions options, callback);
  void capturePage(Rect rect, callback);

  // Send an asynchronous message to renderer process via channel, you can also
  // send arbitrary arguments. The renderer process can handle the message by
  // listening to the channel event with the ipcRenderer module.
  void send(String channel, ...args[]);

  void showDefinitionForSelection(); // macos only
  void sendInputEvent(InputEventOption);

  WebContents getWebContents();

  // Not part of <webview>, only webContents:

  void downloadURL(URL url);
  boolean isDestroyed();
  boolean isFocused();
  boolean isLoadingMainFrame();
  void setZoomFactor(factor);
  void getZoomFactor(callback);


  // Changes the zoom level to the specified level. The original size is 0 and
  // each increment above or below represents zooming 20% larger or smaller to
  // default limits of 300% and 50% of original size, respectively.
  void setZoomLevel(level);
  void getZoomLevel(callback);

  // Sets the maximum and minimum zoom level.
  void setZoomLevelLimits(minimumLevel, maximumLevel);

  void copyImageAt(long x, long y);



  // Begin subscribing for presentation events and captured frames, the
  // callback will be called with callback(frameBuffer, dirtyRect) when there
  // is a presentation event.  The frameBuffer is a Buffer that contains raw
  // pixel data. On most machines, the pixel data is effectively stored in
  // 32bit BGRA format, but the actual representation depends on the endianness
  // of the processor (most modern processors are little-endian, on machines
  // with big-endian processors the data is in 32bit ARGB format).  The
  // dirtyRect is an object with x, y, width, height properties that describes
  // which part of the page was repainted. If onlyDirty is set to true,
  // frameBuffer will only contain the repainted area. onlyDirty defaults to
  // false.
  void beginFrameSubscription(optional boolean onlyDirty,callback);
  void endFrameSubscription();


  // Sets the item as dragging item for current drag-drop operation, file is
  // the absolute path of the file to be dragged, and icon is the image showing
  // under the cursor when dragging.
  void startDrag(String iteam, NativeImage icon);

  void savePage(String fullPath, SaveType saveType, callback);


  // Indicates whether offscreen rendering is enabled.
  boolean isOffscreen();

  // If offscreen rendering is enabled and not painting, start painting.
  void startPainting();

  // If offscreen rendering is enabled and painting, stop painting.
  void stopPainting();

  // If offscreen rendering is enabled returns whether it is currently painting.
  boolean isPainting();

  // If offscreen rendering is enabled sets the frame rate to the specified
  // number. Only values between 1 and 60 are accepted.
  void setFrameRate(fps);

  // If offscreen rendering is enabled returns the current frame rate.
  long getFrameRate();

  // The unique ID of this WebContents.
  String id;

  // Returns the session object used by this webContents.
  Session session; // FIXME

  // Returns the WebContents that might own this WebContents.
  WebContents hostWebContents;

  // Get the WebContents of DevTools for this WebContents.
  WebContents devToolsWebContents;

  // Get the debugger instance for this webContents.
  DebuggerInstance debugger;

}

// DOM EVSNTS

// FIXME


// Fired when a load has committed. This includes navigation within the current
// document as well as subframe document-level loads, but does not include
// asynchronous resource loads.
dictionary LoadCommitEventDetail {
  // type: "load-commit"
  // not in webContents
  // not cancellable
  URL url;
  boolean isMainFrame
}

// Fired when the navigation is done, i.e. the spinner of the tab will stop
// spinning, and the onload event is dispatched.
dictionary DidFinishLoadEventDetail {
  // type: "did-finish-load"
  // not cancellable
}

// This event is like did-finish-load, but fired when the load failed or was
// cancelled, e.g. window.stop() is invoked.
dictionary DidFailLoadEventDetail {
  // type: ‘did-fail-load’
  // not cancellable
  Number errorCode;
  String errorDescription;
  String validatedURL;
  boolean isMainFrame;
}

// Fired when a frame has done navigation.
dictionary DidFrameFinishLoadEventDetail {
  // type: ‘did-frame-finish-load’
  // not cancellable
  boolean isMainFrame;
}

// Corresponds to the points in time when the spinner of the tab starts
// spinning.
dictionary DidStartLoadingEventDetail {
  // type: ‘did-start-loading’
  // not cancellable
}


// Corresponds to the points in time when the spinner of the tab stops
// spinning.
dictionary DidStopLoadingEventDetail {
  // type: ‘did-stop-loading’
  // not cancellable
}

// Fired when details regarding a requested resource is available. status
// indicates socket connection to download the resource.
dictionary DidGetResponseDetailsEventDetail {
  // type: ‘did-get-response-details’
  // not cancellable
  boolean status;
  Srting newURL;
  String originalURL;
  Number httpResponseCode;
  String requestMethod;
  String referrer;
  Object headers;
  String resourceType;
}

// Fired when a redirect was received while requesting a resource.
dictionary DidGetRedirectRequestEventDetail {
  // type: ‘did-get-redirect-request’
  // not cancellable
  URL oldURL;
  String newURL;
  boolean isMainFrame;
}


// Fired when document in the given frame is loaded.
dictionary DOMReadyEventDetail {
  // type: ‘dom-ready’
  // not cancellable
}

// Fired when page title is set during navigation. explicitSet is false when
// title is synthesized from file url.
dictionary PageTitleUpdatedEventDetail {
  // type: ‘page-title-updated’
  // not cancellable
  // not in webContents
  String title;
  boolean explicitSet;
}


// Fired when page receives favicon urls.
dictionary PageFaviconUpdatedEventDetail {
  // type: ‘page-favicon-updated’
  // not cancellable
  URL[] favicons; // Array - Array of URLs.
}

// Fired when page enters fullscreen triggered by HTML API.
dictionary EnterHTMLFullScreenEventDetail {
  // type: ‘enter-html-full-screen’
  // not in webContents
  // cancellable?
}

// Fired when page leaves fullscreen triggered by HTML API.
dictionary LeaveHTMLFullScreenEventDetail {
  // not in webContents
  // type: ‘leave-html-full-screen’
}

// Fired when the guest window logs a console message.
dictionary ConsoleMessageEventDetail {
  // type: ‘console-message’
  // not in webContents
  // not cancellable
  Number level;
  String message;
  Number line;
  String sourceId;
}

// Fired when a result is available for webview.findInPage request.
dictionary FoundInPageEventDetail {
  // type: ‘found-in-page’
  // not in webContents
  Number requestId;
  boolean finalUpdate; // Indicates if more responses are to follow.
  Number? activeMatchOrdinal; // Position of the active match.
  Number? matches; // Number of Matches.
  Object selectionArea; // Coordinates of first match region.
}

enum WindowDisposition {
  "foreground-tab",
  "background-tab",
  "new-window"m
}
// Fired when the guest page attempts to open a new browser window.
dictionary NewWindowEventDetail {
  // type: ‘new-window’
  // cancellable only for webContents
  URL url;
  String frameName;
  WindowDisposition disposition;
  NewWindowOptions options; // The options which should be used for creating the new BrowserWindow.
  // PAUL FIXME: more details about NewWindowOptions
}

// Emitted when a user or the page wants to start navigation. It can happen
// when the window.location object is changed or a user clicks a link in the
// page.  This event will not emit when the navigation is started
// programmatically with APIs like <webview>.loadURL and <webview>.back.  It is
// also not emitted during in-page navigation, such as clicking anchor links or
// updating the window.location.hash. Use did-navigate-in-page event for this
// purpose.  Calling event.preventDefault() does NOT have any effect.
dictionary WillNavigateEventDetail {
  // type: ‘will-navigate’
  // cancellable only for webContents
  URL url;
}

// Emitted when a navigation is done. This event is not emitted for in-page
// navigations, such as clicking anchor links or updating the
// window.location.hash. Use did-navigate-in-page event for this purpose.
dictionary DidNavigateEventDetail {
  // type: ‘did-navigate’
  URL url;
}

// Emitted when an in-page navigation happened. When in-page navigation
// happens, the page URL changes but does not cause navigation outside of the
// page. Examples of this occurring are when anchor links are clicked or when
// the DOM hashchange event is triggered.
dictionary DidNavigateInPageEventDetail {
  // type: ‘did-navigate-in-page’
  // not cancellable
  URL url;
}

// Fired when the guest page attempts to close itself.
dictionary CloseEventDetail {
  // type: ‘close’
  // cancellable?
  // not in webContents
}

// Fired when the guest page has sent an asynchronous message to embedder page.
dictionary IPCMessageEventDetail {
  // type: ‘ipc-message’
  String channel;
  Object[] args;
}


// Fired when the renderer process is crashed.
dictionary CrashedEventDetail {
  // type: ‘crashed’
}

// Fired when the gpu process is crashed.
dictionary GPUCrashedEventDetail {
  // type: ‘gpu-crashed’
}

// Fired when a plugin process is crashed.
dictionary PluginCrashed {
  // type: ‘plugin-crashed’
  String name;
  String version;
}

// Fired when the WebContents is destroyed.
dictionary DestroyedEventDetail {
  // type: ‘destroyed’
}

// Emitted when media starts playing.
dictionary MediaStartedPlayingEventDetail {
  // type: ‘media-started-playing’
  // not in webContents
}

// Emitted when media is paused or done playing.
dictionary MediaPausedEventDetail {
  // type: ‘media-paused’
  // not in webContents
}

// Emitted when a page’s theme color changes. This is usually due to
// encountering a meta tag: <meta name='theme-color' content='#ff0000'>
dictionary DidChangeThemColorEventDetail {
  // type: ‘did-change-theme-color’
  // not in webContents
  String themeColor;
}

// Emitted when mouse moves over a link or the keyboard moves the focus to a
// link.
dictionary UpdateTargetURLEventDetail {
  // type: ‘update-target-url’
  // not in webContents
  String url;
}

// Emitted when DevTools is opened.
dictionary DevtoolsOpenedEventDetail {
  // type: ‘devtools-opened’
}

// Emitted when DevTools is closed.
dictionary DevtoolsClosedEventDetail {
  // type: ‘devtools-closed’
}

// Emitted when DevTools is focused / opened.
dictionary DevtoolsFocusedEventDetail {
  // type: ‘devtools-focused’
}

dictionary Certificate {
  Buffer data; // PEM encoded data
  String issuerName; // Issuer’s Common Name
  String subjectName; // Subject’s Common Name
  String serialNumber; // Hex value represented string
  Integer validStart; // Start date of the certificate being valid in seconds
  Integer validExpiry; // End date of the certificate being valid in seconds
  String fingerprint; // Fingerprint of the certificate
}

// Emitted when failed to verify the certificate for url, to trust the
// certificate you should prevent the default behavior with
// event.preventDefault() and call callback(true).
dictionary CertificateErrorEventDetail {
  // type: 'certificate-error'
  URL url;
  String error;
  Certificate certificate;
  Function callback;
}

// Emitted when a client certificate is requested. The url corresponds to the
// navigation entry requesting the client certificate and callback needs to be
// called with an entry filtered from the list. Using event.preventDefault()
// prevents the application from using the first certificate from the store.
dictionary  SelectClientCertificateEventDetail {
  // type: ‘select-client-certificate’
  WebContents webContents;
  URL url;
  Certificate[] certificateList;
}


// Emitted when webContents wants to do basic auth. The default behavior is to
// cancel all authentications, to override this you should prevent the default
// behavior with event.preventDefault() and call callback(username, password)
// with the credentials.
dictionary LoginEventDetail { // FIXME: missing definitions
  // type: ‘login’
  WebContents webContents;
  Object request;
  String method;
  URL url;
  URL referrer;
  Object authInfo 
  boolean isProxy;
  String scheme;
  String host;
  Number port;
  String realm;
  Function callback;
}


dictionary CursorChangedEventDetail {
  // type: ‘cursor-changed’
  NativeImage? image;
  Object? size; // the size of the image
  float? scale; // scaling factor for the custom cursor
  Object? hotspot; // coordinates of the custom cursor’s hotspot
  long width;
  long height;
  long x;
  long y;

}

dictionary ContextMenuEventDetail {
  // type: ‘context-menu’
  Object params;
  Integer x; // x coordinate
  Integer y; // - y coordinate
  String linkURL; // - URL of the link that encloses the node the context menu was invoked on.
  String linkText; // - Text associated with the link. May be an empty string if the contents of the link are an image.
  String pageURL; // - URL of the top level page that the context menu was invoked on.
  String frameURL; // - URL of the subframe that the context menu was invoked on.
  String srcURL; // - Source URL for the element that the context menu was invoked on. Elements with source URLs are images, audio and video.
  String mediaType; // - Type of the node the context menu was invoked on. Can be none, image, audio, video, canvas, file or plugin.
  Boolean hasImageContents; // - Whether the context menu was invoked on an image which has non-empty contents.
  Boolean isEditable; // - Whether the context is editable.
  String selectionText; // - Text of the selection that the context menu was invoked on.
  String titleText; // - Title or alt text of the selection that the context was invoked on.
  String misspelledWord; // - The misspelled word under the cursor, if any.
  String frameCharset; // - The character encoding of the frame on which the menu was invoked.
  String inputFieldType; // - If the context menu was invoked on an input field, the type of that field. Possible values are none, plainText, password, other.
  String menuSourceType; // - Input source that invoked the context menu. Can be none, mouse, keyboard, touch, touchMenu.
  MediaFlags mediaFlags; // - The flags for the media element the context menu was invoked on. See more about this below.
  EditFlags editFlags; // - These flags indicate whether the renderer believes it is able to perform the corresponding action. See more about this below.
}

dictionary MediaFlags {
  boolean inError; // - Whether the media element has crashed.
  boolean isPaused; // - Whether the media element is paused.
  boolean isMuted; // - Whether the media element is muted.
  boolean hasAudio; // - Whether the media element has audio.
  boolean isLooping; // - Whether the media element is looping.
  boolean isControlsVisible; // - Whether the media element’s controls are visible.
  boolean canToggleControls; // - Whether the media element’s controls are toggleable.
  boolean canRotate; // - Whether the media element can be rotated.
}

dictionary EditFlags {
  boolean canUndo; // - Whether the renderer believes it can undo.
  boolean canRedo; // - Whether the renderer believes it can redo.
  boolean canCut; // - Whether the renderer believes it can cut.
  boolean canCopy; // - Whether the renderer believes it can copy
  boolean canPaste; // - Whether the renderer believes it can paste.
  boolean canDelete; // - Whether the renderer believes it can delete.
  boolean canSelectAll; // - Whether the renderer believes it can select all.
}


// Emitted when bluetooth device needs to be selected on call to
// navigator.bluetooth.requestDevice. To use navigator.bluetooth api
// webBluetooth should be enabled. If event.preventDefault is not called, first
// available device will be selected. callback should be called with deviceId
// to be selected, passing empty string to callback will cancel the request.
dictionary SelectBluetoothDeviceEventDetail {
  // type: ‘select-bluetooth-device’
  Objects[] devices;
  String deviceName;
  String deviceId;
  Function callback;
  String deviceId;
}

// Emitted when a new frame is generated. Only the dirty area is passed in the
// buffer.
dictionary PaintEventDetail {
  // type: ‘paint’
  Rect dirtyRect;
  NativeImage image; // The image data of the whole frame.
}
