interface ContentEditor {
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
