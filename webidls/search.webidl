enum FindCaseSensitivity {
  "case-sensitive",
  "case-insensitive"
};

enum StopFindInPageAction {
  "clearSelection", // Clear the selection
  "keepSelection", // Translate the selection into a normal selection.
  "activateSelection", // Focus and click the selection node
};

interface Searchable {

  // FIXME: Fires find-change. isActive, text, matchIndex or numberOfMatches has changed.

  void find(DOMString text, FindCaseSensitivity caseSensitivity);
  void findNext();
  void findPrevious();
  void stop(StopFindInPageAction action);  

  readonly attribute boolean isActive;
  readonly attribute DOMString text;
  readonly attribute unsigned long matchIndex;
  readonly attribute unsigned long numberOfMatches;
  attribute long findLimit; // -1: no limits
}
