dictionary LoadURLOptions {
  URL httpReferrer;
  DOMString useragent;
  DOMString extraHeaders;
};


dictionary InputEventOption {
  String type; // (required) - The type of the event, can be mouseDown, mouseUp, mouseEnter, mouseLeave, contextMenu, mouseWheel, mouseMove, keyDown, keyUp, char.
  String[] modifiers; // - An array of modifiers of the event, can include shift, control, alt, meta, isKeypad, isAutoRepeat, leftButtonDown, middleButtonDown, rightButtonDown, capsLock, numLock, left, right.
}

enum SaveType {
  "HTMLOnly", // Save only the HTML of the page.
  "HTMLComplete", // Save complete-html page.
  "MHTML", // Save complete-html page as MHTML.
}

interface WebContents {
  // The unique ID of this WebContents.
  String id;

  // Returns the session object used by this webContents.
  Session session; // FIXME

  // Returns the WebContents that might own this WebContents.
  WebContents hostWebContents;

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




  void setAudioMuted(boolean muted);
  boolean isAudioMuted();


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

  void capturePage(Rect rect, callback);

  // Send an asynchronous message to renderer process via channel, you can also
  // send arbitrary arguments. The renderer process can handle the message by
  // listening to the channel event with the ipcRenderer module.
  void send(String channel, ...args[]);

  void showDefinitionForSelection(); // macos only
  void sendInputEvent(InputEventOption);

}


WebContents implements DevtoolsController;
WebContents implements ContentEditor;
WebContents implements Printable;
WebContents implements Searchable;
