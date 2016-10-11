pub struct ConnectionSecurity {
  // Note: Tracking and content blocking has been removed from this interface.
    certificate_info: Option<CertificateInfo>,
    state: ConnectionSecurityState,
  // Organization name has been verified, not just the domain.
  // Marks the difference from a green lock and a green lock + org name.
    is_extended_validation: bool,
};

pub enum ConnectionSecurityState {
  // indicates that the data corresponding to the request was
  // received over an insecure channel.
  Insecure,
  // indicates an unknown security state.  This may mean that
  // the request is being loaded as part of a page in which some
  // content was received over an insecure channel.
  Broken,
  // indicates that the data corresponding to the request was
  // received over a secure channel.
  Secure,
};

pub struct CertificateInfo {
  common_name: String;
  organization: String;
  organizational_unit: String;
  issuer_common_name: String;
  issuer_organization: String;
  issuer_organization_unit: String;
  sha256_fingerprint: String;
  sha1_fingerprint: String;
  valid_not_before_local_day: String;
  valid_not_after_local_day: String;
};

