// STATUS: draft

// FIXME: How to add/remove blockers from Browser and/or pipeline?

enum ContentBlockerType {
  "popup", // Popup blocker
  "tracking", // https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
  "mixed", // https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
  "custom", // adblockers, See https://github.com/servo/servo/issues/9749
}

dictionary ContentBlockerStatus {
  boolean isEnabled;
  unsigned long blockedTargetedContentCount; // Content has been blocked
  unsigned long loadedTargetedContentCount; // Content that could have been blocked has been loaded (blocker is or was disabled)
}

interface ContentBlocker : WeakRef {

  readonly attribute USVString? url; // for custom blockers
  readonly attribute ContentBlockerType type;
  readonly attribute ContentBlockerStatus status;

  Promise<void> enable();
  Promise<void> disable();
}

interface ContentBlockerChangedEvent : Event {
  const DOMString name = "status-changed"; 
}
