class VideoInfo {
  const VideoInfo({
    required this.durationSeconds,
    required this.format,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.videoCodec,
    required this.audioCodec,
    required this.frameRate,
    required this.bitrate,
  });

  final double durationSeconds;
  final String format;
  final int? sizeBytes;
  final int? width;
  final int? height;
  final String videoCodec;
  final String audioCodec;
  final double? frameRate;
  final int? bitrate;

  String get durationLabel {
    final total = durationSeconds.round();
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get resolutionLabel =>
      width == null || height == null ? '-' : '$width×$height';

  String get sizeLabel {
    if (sizeBytes == null) return '-';
    final mb = sizeBytes! / 1024 / 1024;
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} GB';
    return '${mb.toStringAsFixed(2)} MB';
  }

  String get bitrateLabel {
    if (bitrate == null) return '-';
    return '${(bitrate! / 1000).toStringAsFixed(0)} kbps';
  }

  String get fpsLabel =>
      frameRate == null ? '-' : '${frameRate!.toStringAsFixed(2)} FPS';
}
