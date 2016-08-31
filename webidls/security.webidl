dictionary ConnectionSecurity {
  readonly attribute CertificateInfo? certificateInfo;
  readonly attribute ConnectionSecurityType state;

  // Organization name has been verified, not just the domain.
  // Marks the difference from a green lock and a green lock + org name.
  readonly boolean attribute isExtendedValidation;

  // See: https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content
  readonly attribute boolean mixedContentAllowed; // FIXME: where is this set?
  readonly attribute boolean mixedContentLoaded;
  readonly attribute boolean mixedContentBlocked;

  // tracking content: content loaded from domains that track users across sites.
  // See: https://developer.mozilla.org/en-US/Firefox/Privacy/Tracking_Protection
  readonly attribute boolean trackingContentAllowed; // FIXME: where is this set?
  readonly attribute boolean trackingContentLoaded;
  readonly attribute boolean trackingContentBlocked;
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
  readonly attribute DOMString commonName;
  readonly attribute DOMString organization;
  readonly attribute DOMString organizationalUnit;
  readonly attribute DOMString issuerCommonName;
  readonly attribute DOMString issuerOrganization;
  readonly attribute DOMString issuerOrganizationUnit;
  readonly attribute DOMString sha256Fingerprint;
  readonly attribute DOMString sha1Fingerprint;
  readonly attribute DOMString validnotBeforeLocalDay;
  readonly attribute DOMString validNotAfterLocalDay;
};
