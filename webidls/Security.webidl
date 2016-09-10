// STATUS: ok

dictionary ConnectionSecurity {
  // Note: Tracking and content blocking has been removed from this interface.

  CertificateInfo? certificateInfo = null;
  ConnectionSecurityState state;

  // Organization name has been verified, not just the domain.
  // Marks the difference from a green lock and a green lock + org name.
  boolean isExtendedValidation;
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
