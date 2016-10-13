// Basic audio/video management.
// We want to be able to mute/pause a tab
// Implemented by Browser
// See MediaFlags in http://electron.atom.io/docs/api/web-contents/#event-context-menu

pub enum MediaType {
    Audio, Video, Plugin
}

pub struct MediaState {
    in_error: bool, // Whether the media element has crashed.
    is_paused: bool, // Whether the media element is paused.
    is_muted: bool, // Whether the media element is muted.
    has_audio: bool, // Whether the media element has audio.
    is_looping: bool, // Whether the media element is looping.
    is_controls_visible: bool, // Whether the media element’s controls are visible.
    can_rotate: bool, // Whether the media element can be rotated.
    can_toggle_controls: bool, // Whether the media element’s controls are toggleable.
}

pub trait Media {
    fn get_type(&self) -> MediaType;
    fn get_state(&self) -> MediaState;
    fn mute(&self);
    fn unmute(&self);
    fn play(&self);
    fn pause(&self);
    fn toggle_controls(&self);
}

pub trait MultimediaManager {
    fn get_all_media(&self) -> Vec<Media>,
    fn get_media_from_point(&self) -> Option<Media>;
}

pub trait MultimediaManagerHander {
    fn media_state_changed(&self, media: &Media);
}
