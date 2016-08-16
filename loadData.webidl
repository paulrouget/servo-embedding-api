typedef USVString URL;

enum HTTPMethod { "GET", "POST" }

enum ReferrerPolicy {
  "no-referrer",
  "no-referrer-when-downgrade",
  "origin",
  "same-origin",
  "origin-when-cross-origin",
  "unsafe-url"
};

// See also XMLHttpRequest.webidl
typedef (Blob or /*BufferSource or */ FormData or DOMString or URLSearchParams) Data;
interface LoadData {
  readonly attribute URL url;
  readonly attribute HTTPMethod method;
  readonly attribute Headers headers; // Headers.webidl
  readonly attribute BodyInit? data;
  readonly attribute ReferrerPolicy? referrerPolicy;
  readonly attribute URL? referrerUrl;
}

