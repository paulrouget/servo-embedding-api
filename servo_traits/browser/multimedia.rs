// Basic audio/video management.
// We want to be able to mute/pause a tab
// Implemented by Browser, or maybe PipelineProxy

pub struct MultimediaState {
    muted: bool,
    playing: bool,
}

pub trait MultimediaManager {
    fn get_multimedia_state(&self) -> MultimediaState;
    fn mute(&self);
    fn unmuted(&self);
    fn play_active_media(&self);
    fn pause_active_media(&self);
}

pub trait MultimediaManagerHander {
    fn multimedia_state_changed(&self);
}

