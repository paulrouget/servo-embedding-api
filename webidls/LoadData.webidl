/**
 *  This is all that is necessary to create a pipeline.
 *  It can be (de)serialized and saved on disk. It can be used for session restore, and to undo
 *  tab close (Cmd-Shift-T)
 *  The creation of a pipeline (navigation, session restore, restore on navigate) relies on this.
 *  See constellation_msg::LoadData
 *  Relevant: https://github.com/servo/servo/pull/11893
 */

// FIXME: where to (de)serialize LoadData?

enum HTTPMethod { "GET", "POST" };

enum TransitionType {
  // https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/api/history.json
  // FIXME: most of these might not be useful
  "link", "typed", "auto_bookmark", "auto_subframe", "manual_subframe",
  "generated", "auto_toplevel", "form_submit", "reload", "keyword",
  "keyword_generated",
}

dictionary FormDataEntry {
  USVString name;
  (File or USVString) value;
}

dictionary LoadData : Serializable /* FIXME: a dictionary can't inherit from an interface */ {
  USVString url;
  DOMString? title;
  HTTPMethod method;
  Headers headers; // Headers.webidl
  BodyInit? body = null; // See XMLHttpequest.webdil
  USVString? referrerURL;
  DOMPoint? scrollPosition;
  ScrollRestoration scrollRestorationMode;
  TransitionType? transitionType;
  Sequence<FormDataEntry>? formData = null;

  // The user input that lead to load this entry. For example,
  // if the user typed "foo bar" that eventually redirect to a
  // google URL, user typed value is "foo bar"
  DOMString userTypedValue;

  ReferrerPolicy? referrerPolicy; // See Request.webidl
  // FIXME: I don't understand why this is necessary, it's
  // present in Servo's LoadData, and also in Gecko's session
  // restore code

  // FIXME: we should make it possible to store any kind of JSON-like object along LoadData.
  // FIXME: how do we save the save of the content blockers?
  // FIXME: Gecko also store user styles
}
