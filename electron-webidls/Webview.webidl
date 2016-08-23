interface WebView {
  WebContents getWebContents();

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
}

WebView implements WebContents; // Confusing since there is getWebContents()
