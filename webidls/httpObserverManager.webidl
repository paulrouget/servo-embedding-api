// See https://dxr.mozilla.org/mozilla-central/source/toolkit/modules/addons/WebRequest.jsm
// and https://chromium.googlesource.com/chromium/src/+/master/extensions/common/api/web_request.json

FIXME

// from webcontent:

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

