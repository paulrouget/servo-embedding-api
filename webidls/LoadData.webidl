enum HTTPMethod { "GET", "POST" }

// This is basically used to setup a new history entry. It can be used for session restore.
// FIXME: Can a URL be used instead of LoadData to create a new pipeline/entry?
// FIXME: No, and it needs to be constructable to create a new tab on windowopen events
// FIXME: … probably could be a dictionary (copy vs. ref), and we need a (de)serializer
// FIXME: Constructor too limited. It's important to be able to create a LoadData with httpreferrer, UA, & co
[Constructor, Constructor((USVString or Blob /* serialized loadata */))]
// Used to reload purged pipeline or to preload pipeline
interface LoadData {
  readonly attribute USVString url;
  readonly attribute HTTPMethod method;
  readonly attribute Headers headers; // Headers.webidl
  readonly attribute BodyInit? data; // See XMLHttpequest.webdil
  readonly attribute ReferrerPolicy? referrerPolicy; // See Request.webidl
  readonly attribute USVString? referrerUrl;
  readonly attribute DOMString? useragent; // FIXME: could it be set via prefs?
  // the guest page will have web security disabled.
  readonly attribute boolean disableWebSecurity;


  // Sets the session used by the page. If partition starts with persist:, the
  // page will use a persistent session available to all pages in the app with
  // the same partition. if there is no persist: prefix, the page will use an
  // in-memory session. By assigning the same partition, multiple pages can
  // share the same session. If the partition is unset then default session of
  // the app will be used.  This value can only be modified before the first
  // navigation, since the session of an active renderer process cannot change.
  // Subsequent attempts to modify the value will fail with a DOM exception.
  readonly attribute DOMString partition;

  readonly attribute boolean allowpopups;

  readonly attribute JSON prefs; // FIXME: JSON type doesn't exist. Object does.

  Promise<Blob> serialize(); // Used to save to disk
}


