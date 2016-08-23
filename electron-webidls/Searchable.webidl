dictionary FindOptions {
  boolean forward;
  boolean findNext; //Whether the operation is first request or a follow up
  boolean matchCase;
  boolean wordStart; // Whether to look only at the start of words. defaults to false.
  boolean medialCapitalAsWordStart; // When combined with wordStart, accepts a match in the middle of a word if the match begins with an uppercase letter followed by a lowercase or non-letter. Accepts several other intra-word matches, defaults to false.
}

enum StopFindInPageAction {
  "clearSelection", // Clear the selection
  "keepSelection", // Translate the selection into a normal selection.
  "activateSelection", // Focus and click the selection node
};


interface Searchable {
  void findInPage(DOMString text, FindOptions? options);
  void stopFindInPage(StopFindInPageAction action);
}
