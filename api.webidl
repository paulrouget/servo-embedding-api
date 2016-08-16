typedef USVString URL;

[ArrayClass]
interface PipelineList {
  readonly attribute unsigned long length;
  getter Pipeline getItem(unsigned long index);
};

interface HistoryEntry {
  readonly attribute boolean isAlive;
  readonly attribute Pipeline pipeline;
  readonly attribute LoadData loadData;
  readonly attribute boolean isPrivate;

  void purge();
  void restore(); // Doesn't it make sense?
}

interface PipelineInitData {
  readonly attribute boolean isPrivate;
  readonly attribute ViewPortDimension viewportDimension;
  readonly attribute BrowsingContext browsingContext;
  readonly attribute LoadData loadData;
}

enum ReferrerPolicy {
  "no-referrer",
  "no-referrer-when-downgrade",
  "origin",
  "same-origin",
  "origin-when-cross-origin",
  "unsafe-url"
};

interface LoadData {
  readonly attribute URL url;
  readonly attribute HTTPMethod method;
  readonly attribute HTTPHeaders headers;
  readonly attribute HTTPData? data;
  readonly attribute ReferrerPolicy? referrerPolicy;
  readonly attribute URL? referrerUrl;
}

interface BrowsingContext {
  readonly attribute PipelineList pipelines;
  Pipeline getActivePipeline();
  Pipeline getPipelineById(PipelineID id);
  boolean isPrivate();
  void navigate(PipelineInitData pipelineInitData); // will create a new pipeline

  attribute boolean autoPurgePipelines; // Default yes
  attribute long historyToKeep;

  onclose;
  on-new-pipeline;
  on-will-opentab /* can be cancelled */
  on-did-opentab /* comes with a BrowsingContext */
  /* Same for windowpen */
  /* duplicate what Electron does here */
}

interface ViewPort {
  attribute boolean enableOverscroll;
  readonly attribute Rect frame;
  readonly attribute Rect boundsAtRest;
  attribute boolean updateBoundsOnScroll; // snapping?
  void animateBounds(Rect bounds, long duration, TimingFunction timingFunction);
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

  /* Audio ? */

  readonly attribute boolean isPurged;
  readonly attribute boolean isPending;
  readonly attribute boolean isFrozen;
  readonly attribute boolean isActive; // A preloading pipeline can be non frozen and non visible

  readonly attribute URL url;
  readonly attribute DOMString title;
  readonly attribute DocumentReadyState doumentReadyState;
  readonly attribute URL[] icons;
  readonly attribute MetaTag[] metas; // only <meta name="…">

  readonly attribute SecurityState securityState;

  void findAll(DOMString searchString, FindCaseSensitivity caseSensitivity);
  void findNext(FindDirection direction);
  void clearMatch();  


  void purge();
  void reload();
  void stopLoad();
  void clearCacheAndReload();
  void download(URL url, optional DownloadOptions options);

  void executeScript(/*FIXME*/);

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

/*
usernameandpasswordrequired
showmodalprompt
selectionstatechanged
findchange
*/
  
}
