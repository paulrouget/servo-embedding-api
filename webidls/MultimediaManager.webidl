// STATUS: nothing to see here.

// FIXME: can do a lot better than that
// use case: mute tab, play/pause button in tab


interface MultimediaManager {
  void setAudioMuted(boolean muted);
  boolean isAudioMuted();

  FrozenList<Media> all();

  isPlaying;

  pauseActiveMedia();
  playActiveMedia();

}

interface Media {
  MediaFlags flags; // FIXME: state, flags… pick one
  // Event: "change" … not really granular

  play();
  pause();

}

dictionary MediaFlags {
  boolean inError;
  boolean isPaused;
  boolean isMuted;
  boolean hasAudio;
  boolean isLooping;
  boolean isControlsVisible;
  boolean canToggleControls;
  boolean canRotate;
}


// from Chrome:

/*
// Emitted when media starts playing.
dictionary MediaStartedPlayingEventDetail {
  // type: ‘media-started-playing’
  // not in webContents
}

// Emitted when media is paused or done playing.
dictionary MediaPausedEventDetail {
  // type: ‘media-paused’
  // not in webContents
}
*/
