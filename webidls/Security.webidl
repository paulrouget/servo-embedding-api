dictionary ConnectionSecurity {
  CertificateInfo? certificateInfo = null;
  ConnectionSecurityState state;

  // Organization name has been verified, not just the domain.
  // Marks the difference from a green lock and a green lock + org name.
  boolean isExtendedValidation;

  // mixedContent and trackingPolicy are set at pipeline creation

  // See: https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
  boolean isMixedContentLoaded;
  boolean isMixedContentBlocked;

  // tracking content: content loaded from domains that track users across sites.
  // See: https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
  boolean isTrackingContentLoaded;
  boolean isTrackingContentBlocked;
};

enum ConnectionSecurityState {
  // indicates that the data corresponding to the request was
  // received over an insecure channel.
  "insecure",
  // indicates an unknown security state.  This may mean that
  // the request is being loaded as part of a page in which some
  // content was received over an insecure channel.
  "broken",
  // indicates that the data corresponding to the request was
  // received over a secure channel.
  "secure"
};

dictionary CertificateInfo {
  DOMString commonName;
  DOMString organization;
  DOMString organizationalUnit;
  DOMString issuerCommonName;
  DOMString issuerOrganization;
  DOMString issuerOrganizationUnit;
  DOMString sha256Fingerprint;
  DOMString sha1Fingerprint;
  DOMString validnotBeforeLocalDay;
  DOMString validNotAfterLocalDay;
};
