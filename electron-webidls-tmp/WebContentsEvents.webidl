
// Emitted when failed to verify the certificate for url, to trust the
// certificate you should prevent the default behavior with
// event.preventDefault() and call callback(true).
dictionary CertificateErrorEventDetail {
  // type: 'certificate-error'
  URL url;
  String error;
  Certificate certificate;
  Function callback;
}

// Emitted when a client certificate is requested. The url corresponds to the
// navigation entry requesting the client certificate and callback needs to be
// called with an entry filtered from the list. Using event.preventDefault()
// prevents the application from using the first certificate from the store.
dictionary  SelectClientCertificateEventDetail {
  // type: ‘select-client-certificate’
  WebContents webContents;
  URL url;
  Certificate[] certificateList;
}


// Emitted when webContents wants to do basic auth. The default behavior is to
// cancel all authentications, to override this you should prevent the default
// behavior with event.preventDefault() and call callback(username, password)
// with the credentials.
dictionary LoginEventDetail { // FIXME: missing definitions
  // type: ‘login’
  WebContents webContents;
  Object request;
  String method;
  URL url;
  URL referrer;
  Object authInfo 
  boolean isProxy;
  String scheme;
  String host;
  Number port;
  String realm;
  Function callback;
}
