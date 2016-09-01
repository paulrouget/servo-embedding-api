// FIXME: what about sub iframes?

interface Editable {
  void undo();
  void redo();
  void cut();
  void copy();
  void paste();
  void pasteAndMatchStyle();
  void delete();
  void selectAll();
  void unselect();
  void replace(DOMString text);
  void replaceMisspelling(DOMString text);
  void insertText(DOMString text);

  readonly attribute EditState state; // Event: on-change. // FIXME: pipeline implements Editable. That means there will be a event name collision.
}

dictionary EditState {
  // FIXME: see context-menu:event params
  DOMString selectionText;
  boolean isEditable; // FIXME: Is that necessary?
  boolean canUndo;
  boolean canRedo;
  boolean canCut;
  boolean canCopy;
  boolean canPaste;
  boolean canDelete;
  boolean canSelectAll;
}

