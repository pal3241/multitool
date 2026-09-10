class MediaLocation {
  const MediaLocation({
    required this.ffmpegPath,
    required this.displayName,
  });

  /// Path understood by FFmpeg. On Android this can be an FFmpegKit SAF URL.
  final String ffmpegPath;

  /// Friendly name shown in the UI.
  final String displayName;
}
