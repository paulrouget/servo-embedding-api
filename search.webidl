enum SearchCaseSensitivity { "case-sensitive", "case-insensitive" };
enum SearchDirection { "forward", "backward" };

enum SearchEventType { "searchchange" };

dictionary SearchableEvent {
  attribute readonly SearchableEventType type;
};


interface Searchable {

  // Fires SearchableEvent

  void searchAll(DOMString searchString, SearchCaseSensitivity caseSensitivity);
  void searchNext(SearchDirection direction);
  void searchClearMatch();  

  readonly attribute boolean searchIsActive;
  readonly attribute string searchString;
  attribute Number searchLimit;
  readonly attribute Number searchActiveMatchOrdinal;
  readonly attribute Number searchNumberOfMatches;
}
