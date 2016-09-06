interface Editable {

  // FIXME: pipeline implements Editable.
  // That means there will be a event name collision.

  readonly attribute boolean isEditable;
  readonly attribute DOMString selectionText;
  readonly attribute boolean canUndo;
  readonly attribute boolean canRedo;
  readonly attribute boolean canCut;
  readonly attribute boolean canCopy;
  readonly attribute boolean canPaste;
  readonly attribute boolean canDelete;
  readonly attribute boolean canSelectAll;


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
}

Editable implements EventEmitter;

interface OnEditableChange: Event {
  const DOMString name = "editable-changed";
}
