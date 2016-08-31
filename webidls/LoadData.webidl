enum HTTPMethod { "GET", "POST" }

// This is basically used to setup a new history entry. It can be used for session restore.
// FIXME: Can a URL be used instead of LoadData to create a new pipeline/entry?
// FIXME: No, and it needs to be constructable to create a new tab on windowopen events
// FIXME: … probably could be a dictionary (copy vs. ref), and we need a (de)serializer
// FIXME: Constructor too limited. It's important to be able to create a LoadData with httpreferrer, UA, & co
[Constructor, Constructor((
  USVString /* URL */ or
  Blob /* serialized loadata */ or
  Pipeline /* from existing pipeline */))]
// Used to reload purged pipeline or to preload pipeline
interface LoadData {
  readonly attribute USVString url; // This won't get updated with redirect. Will need manual update to final URL.
  readonly attribute HTTPMethod method;
  readonly attribute Headers headers; // Headers.webidl
  readonly attribute BodyInit? body; // See XMLHttpequest.webdil
  readonly attribute ReferrerPolicy? referrerPolicy; // See Request.webidl
  readonly attribute USVString? referrerURL;
  // the guest page will have web security disabled.
  readonly attribute boolean disableWebSecurity;


  Promise<Blob> serialize(); // Used to save to disk - FIXME: maybe move to HistoryEntry
}


