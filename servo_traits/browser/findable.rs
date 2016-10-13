pub enum CaseSensitivity {
    CaseSensitive,
    CaseInsensitive,
}

pub enum StopFindAction {
    ClearSelection,// Clear the selection
    KeepSelection, // Translate the selection into a normal selection.
    ActivateSelection, // Focus and click the selection node
}

pub struct FindState {
    is_active: bool,
    text: String,
    match_index: u32,
    matches_count: u32,
}

// Implemented by Browser, or maybe Pipeline
pub trait Findable {
    fn get_state(&self) -> FindState;
    fn find(&self, text: String, case_sensitivity: CaseSensitivity);
    fn findNext(&self);
    fn findPrevious(&self);
    fn stopFind(&self, action: StopFindAction);  
}

pub trait FindableHandler {
    fn findable_state_changed(&self);
}

