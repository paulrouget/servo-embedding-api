/**
 *  More or less equivalent to FrameState (which is very minimal so far).
 */

interface HistoryEntry : WeakRef {
  Promise<void> setHandler(HistoryEntryHandler handler);

  readonly attribute boolean isPipelineAlive;

  // **Important**: multiple entries can refer to a single pipeline.
  // Will fail if pipeline purged.
  readonly attribute Pipeline? pipeline;

  // Will only work if frozen
  Promise<void> purgePipeline();

  // FIXME: Doesn't it make sense? Why and when will we want to do this? Wouldn't that mess up with Browser.webidl's autopurge.
  Promise<Pipeline> restorePipeline();

  // To get up-to-date information about the document (url, title, …), use the pipeline.
  // If the pipeline is killed, use latestLoadData. It is initialized with the LoadData passed
  // at construction.
  Promise<LoadData> getLoadData();

  // FIXME: No reason for this to live in HistoryEntry
  Promise<Blob> serializeLoadData(LoadData loadData); // Used to save to disk
}

interface HistoryEntryHandler {
  // last chance to use pipeline (remove handlers)
  void onPipelineWillPurge();

  // pipeline is accessible
  // Either restored (if going back far in the history)
  // or swapped (in case of reload)
  // or restored via restorePipeline()
  void onPipelineCreated();

  void onDestroy(LoadData loadData);
}
