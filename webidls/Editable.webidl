interface Editable {

  Promise<void> setEditableHandler(EditableHandler handler);

  // This is usually used to build the application Edit menu.

  // On resolve, editableStatus has been updated
  Promise<void> undo();
  Promise<void> redo();
  Promise<void> cut();
  Promise<void> copy();
  Promise<void> paste();
  Promise<void> pasteAndMatchStyle();
  Promise<void> delete();
  Promise<void> selectAll();
  Promise<void> unselect();
  Promise<void> replace(DOMString text);
  Promise<void> replaceMisspelling(DOMString text);
  Promise<void> insertText(DOMString text);

  readonly attribute DOMString selectionText;
  readonly attribute boolean isEditable;
  readonly attribute boolean canUndo;
  readonly attribute boolean canRedo;
  readonly attribute boolean canCut;
  readonly attribute boolean canCopy;
  readonly attribute boolean canPaste;
  readonly attribute boolean canDelete;
  readonly attribute boolean canSelectAll;
}

interface EditableHandler {
  void onChange();
}
