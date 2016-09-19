interface MultimediaManager {
  Promise<void> setHandler(MultimediaManagerHander handler);
  void muteAudio();
  void unmuteAudio();
  void playActiveMedia();
  void pausePlayingMedia();
  attribute readonly boolean isAudioMuted;
  attribute readonly boolean isMediaPlaying;
}

interface MultimediaManagerHander {
  void onStartedPlaying();
  void onPaused();
  void onMute();
  void onUnmute();
}
