// STATUS: ok

dictionary EditableStatus {
  DOMString selectionText;
  boolean isEditable;
  boolean canUndo;
  boolean canRedo;
  boolean canCut;
  boolean canCopy;
  boolean canPaste;
  boolean canDelete;
  boolean canSelectAll;
}

interface Editable {

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

  EditableStatus editableStatus;

}

interface EditableDidChangeEvent: Event {
  const DOMString name = "editable-did-change";
}
