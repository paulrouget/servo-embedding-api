enum HTTPMethod { "GET", "POST" }

// This is used to setup a new history entry.
// It can be used for session restore.
// Used to reload purged pipeline or to preload pipeline.
dictionary LoadData {
  USVString url;
  HTTPMethod method;
  Headers headers; // Headers.webidl
  BodyInit? body; // See XMLHttpequest.webdil
  USVString? referrerURL = null;
  DOMPoint? scrollPosition = 0;
  boolean isTrackingContentAllowed = true;
  boolean isMixedContentAllowed = true;
  // the guest page will have web security disabled.
  boolean isWebSecurityDisabled = false;

  ReferrerPolicy? referrerPolicy; // See Request.webidl // FIXME: that makes no sense. What policy are we talking about? Past entry? If so, referrer is set already, according to past policy. Current entry? Not useful as the policy will be set via headers
}
