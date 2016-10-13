// From Browser::get_content_from_point(). The node found is called "Target"
// Used to build context menu
// Inspired by http://electron.atom.io/docs/api/web-contents/#event-context-menu


pub enum InputType {
    PlainText, Password, Other
}

pub struct ContentDescriptionAtPoint {
    x: f32,
    y: f32,

    pipeline_id: PipelineID, // Document owning the target
    link_url: Option<String>, // URL of the link that encloses the target
    link_text: Option<String>, // Text associated with the link. May be an empty string if the contents of the link are an image.
    src_url: Option<String>, // Source URL of the target. Elements with source URLs are images, audio and video.
    has_image_contents: bool, // Whether the target is an image which has non-empty contents.
    title_text: Option<String>, // Title or alt text of the target
    misspelled_word: Option<String>, // The misspelled word, if any.
    frame_charset: Option<String>, // The character encoding of the document owning the target
    input_field_type: Option<InputType>, // If target is an input field, the type of that field.

    editable_state: EditableState, // See editable.rs

    // See multimedia.rs
    media_type: Option<MediaType>, // Type of the target if media.
    media_flags: MediaState, // State of the media.

}
