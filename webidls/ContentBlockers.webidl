// STATUS: draft

enum ContentBlockerType {
  "popup", // Popup blocker
  "tracking", // https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
  "mixed", // https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
  "custom", // adblockers, See https://github.com/servo/servo/issues/9749
}

interface ContentBlocker {
  readonly attribute ContentBlockerType type;
  readonly attribute boolean isEnabled;
  readonly attribute boolean isTargetedContentBlocked; // Content has been blocked
  readonly attribute boolean isTargetedContentLoaded; // Content that could have been blocked has been loaded (blocker is or was disabled)
  readonly attribute USVString? url; // for custom blockers

  Promise<void> enable();
  Promise<void> disable();
}

// FIXME: events, including "on destroy" when pipeline dies.
// FIXME: this is annoying. All these objects will have destroy events… can we do better?
