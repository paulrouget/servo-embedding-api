/*



focus
onnewpipeline
executeScript

onopentab
onopenwindow

audioplaybackchanged

mozbrowserusernameandpasswordrequired
mozbrowsershowmodalprompt
mozbrowserselectionstatechanged
mozbrowserfindchange

… add stuff from <webview>


*/


[ArrayClass]
interface PipelineList {
  readonly attribute unsigned long length;
  getter Pipeline getItem(unsigned long index);
};

interface BrowsingContext {
  readonly attribute PipelineList pipelines;
  Pipeline getActivePipeline();
  Pipeline getPipelineById(PipelineID id);
  boolean isPrivate();

  void requestNewPipeline(/*FIXME*/);
  onclose;
}

interface ViewPort {
  readonly attribute Rect frame;
  readonly attribute Rect bounds;
  readonly attribute BrowsingContext browsingContexts;
  attribute boolean visible; // Can this fail? If so, getter/setter
  onvisibylitychanged;
  onfirstpaint;
}

interface PipelinePreview {
}

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


enum FindCaseSensitivity { "case-sensitive", "case-insensitive" };
enum FindDirection { "forward", "backward" };

dictionary MetaTag {
  readonly attribute DOMString name;
  readonly attribute DOMString content;
}

interface pipeline {

  readonly attribute ConnectionSecurityState connectionSecurityState;

  attribute float devicePixelRatio;

  readonly attribute DOMString id;
  readonly attribute DOMString sessionId;

  isPrivate; // Here in browsing context?

  readonly attribute boolean isPurged;
  readonly attribute boolean isPending;
  readonly attribute boolean isFrozen;
  readonly attribute boolean isActive; // A preloading pipeline can be non frozen and non visible

  readonly attribute USVString url;
  readonly attribute DOMString title;
  readonly attribute DocumentReadyState doumentReadyState;
  readonly attribute USVString[] icons;
  readonly attribute MetaTag[] metas; // only <meta name="…">

  readonly attribute SecurityState securityState;

  void findAll(DOMString searchString, FindCaseSensitivity caseSensitivity);
  void findNext(FindDirection direction);
  void clearMatch();  


  void purge();
  void reload();
  void stopLoad();
  void clearCacheAndReload();
  void download(USVString url, optional DownloadOptions options);

  ontitlechanged;
  onurlchanged;
  oniconschanged;
  onmetachanged;
  onpurged;
  onfrozen;
  onthaw;
  onactive;
  onunactive;
  
  onsecuritystatechange;
  
  oncontextmenu

  onerror
  
}
