// A Browser has access to multiple content blockers: Popup blocker, tracking
// content blocker, mixed content blocker, custom blocker (à la Safari).
// Blockers are registered at 3 different levels: Session, Browser, Document
// Blockers can be enabled or disabled.
// Document blockers take precedence over Browser blockers which take precedence
// over Session blockers.
// Blockers can be enabled/disabled just for a document (allowing mixed content
// for example is per page), just for a browser (we might want to allow popups
// just for a tab) or for a whole session (block tracking for the whole session)
//
// Not all content blockers are enable on page load. Enabling a content blocker
// for a page doesn't mean it will be activated for the next document.

pub enum ContentBlockerType {
    Popup, // Popup blocker
    Tracking, // https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
    Mixed, // https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
    Custom(String), // adblockers, See https://github.com/servo/servo/issues/9749
}

// Is content blocker enabled at the session level.
// See session.rs
pub struct SessionContentBlocker {
    type_: ContentBlockerType,
    enabled: bool,
}

// We might want to display the number of blocked elements
// or the number of elements that could have been blocked
// if the blocker would be enabled
pub struct BlockedContentCount {
    blocked: u32,
    blockable: u32,
}

// ** Implemented by Session, Browser and Document **
// A content blocker can be enabled just for a page, for a tab,
// or for the whole browser.
pub trait ContentBlockerConfiguration {
    fn enable_content_blocker(&self, type_: ContentBlockerType);
    fn disable_content_blocker(&self, type_: ContentBlockerType);
    fn is_content_blocker_enabled(&self, type_: ContentBlockerType);
}
