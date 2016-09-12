// STATUS: WIP

enum FindCaseSensitivity {
  "case-sensitive",
  "case-insensitive"
};

enum StopFindInPageAction {
  "clearSelection", // Clear the selection
  "keepSelection", // Translate the selection into a normal selection.
  "activateSelection", // Focus and click the selection node
};

dictionary FindInPageStatus {
  boolean isActive;
  DOMString text;
  unsigned long matchIndex;
  unsigned long numberOfMatches;
}

interface FindInPage {

  // On resolve, findInPageStatus has been updated.
  Promise<void> findInPage(DOMString text, FindCaseSensitivity caseSensitivity);
  Promise<void> findNextInPage();
  Promise<void> findPreviousInPage();
  Promise<void> stopFindInPage(StopFindInPageAction action);  

  readonly attribute FindInPageStatus findInPageStatus;
};

interface FindInPageDidChangeEvent : Event {
  const DOMString name = "find-in-page-status-did-change";
}


