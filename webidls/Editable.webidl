interface Editable {

  // This is usually used to build the application Edit menu.

  // FIXME: pipeline implements Editable.
  // That means there will be a event name collision.
  // Maybe use as asEditable()

  readonly attribute DOMString selectionText;
  readonly attribute boolean isEditable;
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

interface EditableChangedEvent: Event {
  const DOMString name = "changed";
}

interface EditableDestroyEvent: Event {
  const DOMString name = "changed";
}
