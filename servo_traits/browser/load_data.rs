// LoadData is a central structure of the browser. It is used in many places.
// For example, when the user type a new url and hit enter, Browser::navigate
// is called with a LoadData.
// 
// This is all that is necessary to create a pipeline. It can be (de)serialized and saved on disk.
// It can be used for session restore, and to undo tab close (Cmd-Shift-T). The creation of a
// pipeline (navigation, session restore, restore on navigate) relies on this.  See
// constellation_msg::LoadData Relevant: https://github.com/servo/servo/pull/11893

pub enum HTTPMethod { GET, POST }

pub enum TransitionType {
    // How this document has been reached
    // See: https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/api/history.json
    LinkClicked(MouseButton, KeyModifier),
    JavaScript,
    Typed,
    Bookmark,
    FormSubmit,
    Reload,
    Keyword,
}

pub struct FormDataEntry {
  String name;
  String value; // FIXME: What about File?
}

#[derive(Deserialize, Serialize)]
pub struct LoadData {
  url: String,
  title: Option<String>,
  http_method: HTTPMethod,
  http_headers: Option<HTTPHeaders>, // See Headers.webidl
  body: Option<BodyInit>, // See XMLHttpequest.webdil
  referrer_url: Option<String>,
  scroll_position: Option<Point2D<f32>>,
  scroll_restoration_mode: ScrollRestoration, // See History.webid. Auto by default
  transition_type: TransitionType,
  js_state_object: Option<JSObject>, // window.history.pushState & co
  form_data: Option<Vec<FormDataEntry>>,
  // The user input that lead to load this entry. For example,
  // if the user typed "foo bar" that eventually redirect to a
  // google URL, user typed value is "foo bar"
  user_typed_value: Option<String>,

  // FIXME: I don't understand why the referrer policy should be
  // part of the LoadData, it's present in Servo's LoadData, and
  // also in Gecko's session restore code.
  // The LoadData is supposed to be filled according to the referrer
  // policy, so there's no need for it.
  referrer_policy: ReferrerPolicy, // See Request.webidl

  // FIXME: how do we save the state of the content blockers?
  // FIXME: Gecko also store user styles
}

