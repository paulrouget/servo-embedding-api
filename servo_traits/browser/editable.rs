// This is usually used to build the application Edit menu.
// Implemented by Browser, or maybe Document

pub struct EditableState {
    selected_text: String,
    is_editable: bool,
    can_undo: bool,
    can_redo: bool,
    can_cut: bool,
    can_copy: bool,
    can_paste: bool,
    can_delete: bool,
    can_select_all: bool,
}

pub trait Editable {
    fn get_state(&self) -> EditableState;

    fn undo(&self);
    fn redo(&self);
    fn cut(&self);
    fn copy(&self);
    fn paste(&self);
    fn paste_and_match_style(&self);
    fn delete(&self);
    fn select_all(&self);
    fn unselect(&self);
    fn replace(&self, text: String);
    fn replace_misspelling(&self, text: String);
    fn insert_text(&self, text: String);
}

pub trait EditableHandler {
    fn editable_state_changed(&self);
}
