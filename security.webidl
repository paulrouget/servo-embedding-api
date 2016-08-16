//   "insecure" indicates that the data corresponding to
//     the request was received over an insecure channel.
//
//   "broken" indicates an unknown security state.  This
//     may mean that the request is being loaded as part
//     of a page in which some content was received over
//     an insecure channel.
//
//   "secure" indicates that the data corresponding to the
//     request was received over a secure channel.
enum ConnectionSecurityState { "insecure", "broken", "secure" }
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
}

dictionary ConnectionSecurity {
  readonly attribute ConnectionSecurityType state;
  boolean extendedValidation;
  readonly attribute CertificateInfo? certificateInfo;
}

{
  

  // mixedState:
  //   "blocked_mixed_active_content": Mixed active content has been blocked from loading.
  //   "loaded_mixed_active_content": Mixed active content has been loaded.
  DOMString mixedState;
  boolean mixedContent;

  // trackingState:
  //   "loaded_tracking_content": tracking content has been loaded.
  //   "blocked_tracking_content": tracking content has been blocked from loading.
  DOMString trackingState;
  boolean trackingContent;
};



