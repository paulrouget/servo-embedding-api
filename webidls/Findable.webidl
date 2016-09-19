enum FindCaseSensitivity {
  "case-sensitive",
  "case-insensitive"
};

enum StopFindAction {
  "clearSelection", // Clear the selection
  "keepSelection", // Translate the selection into a normal selection.
  "activateSelection", // Focus and click the selection node
};

interface Findable {
  Promise<void> setFindableHandler(FindableHandler Handler);

  Promise<void> find(DOMString text, FindCaseSensitivity caseSensitivity);
  Promise<void> findNext();
  Promise<void> findPrevious();
  Promise<void> stopFind(StopFindAction action);  
  
  attribute readonly boolean isActive;
  attribute readonly DOMString text;
  attribute readonly unsigned long matchIndex;
  attribute readonly unsigned long numberOfMatches;
}

interface FindableHandler {
  void onChange();
}
