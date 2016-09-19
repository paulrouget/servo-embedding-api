enum ContentBlockerType {
  "popup", // Popup blocker
  "tracking", // https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
  "mixed", // https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
  "custom", // adblockers, See https://github.com/servo/servo/issues/9749
}

dictionary ContentBlockerDescription {
  ContentBlockerType type;
  USVString url; // for custom blockers, aka Safari content blocker
  boolean enabledByDefault;
}

interface ContentBlocker {
  Promise<void> setHandler(ContentBlockerHandler handler);

  readonly attribute ContentBlockerDescription description;

  readonly attribute boolean isEnabled;
  readonly attribute unsigned long blockedTargetedContentCount; // Content has been blocked
  readonly attribute unsigned long loadedTargetedContentCount; // Content that could have been blocked has been loaded (blocker is or was disabled)

  Promise<void> enable();
  Promise<void> disable();
}

interface ContentBlockerHandler {
  void onStatusDidChange(); // isEnabled changed
  void onCountDidChange(); // loaded/blockedTargetedContentCount
  void onDestroy();
}
