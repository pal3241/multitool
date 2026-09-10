enum VideoOperation {
  compress,
  extractAudio,
  convertMp4,
  removeAudio,
  toGif,
}

extension VideoOperationX on VideoOperation {
  String get title => switch (this) {
        VideoOperation.compress => 'Compress Video',
        VideoOperation.extractAudio => 'Extract Audio',
        VideoOperation.convertMp4 => 'Convert to MP4',
        VideoOperation.removeAudio => 'Remove Audio',
        VideoOperation.toGif => 'Video to GIF',
      };

  String get description => switch (this) {
        VideoOperation.compress => 'Kurangi ukuran dengan H.264 + AAC.',
        VideoOperation.extractAudio => 'Ambil audio dan simpan sebagai MP3.',
        VideoOperation.convertMp4 => 'Ubah video menjadi MP4 yang kompatibel.',
        VideoOperation.removeAudio => 'Buat salinan video tanpa suara.',
        VideoOperation.toGif => 'Ubah video menjadi GIF 12 FPS.',
      };

  String get extension => switch (this) {
        VideoOperation.extractAudio => 'mp3',
        VideoOperation.toGif => 'gif',
        _ => 'mp4',
      };

  String get mimeType => switch (this) {
        VideoOperation.extractAudio => 'audio/mpeg',
        VideoOperation.toGif => 'image/gif',
        _ => 'video/mp4',
      };
}

enum CompressionPreset { highQuality, balanced, smallest }

extension CompressionPresetX on CompressionPreset {
  String get label => switch (this) {
        CompressionPreset.highQuality => 'High Quality',
        CompressionPreset.balanced => 'Balanced',
        CompressionPreset.smallest => 'Smallest',
      };

  int get crf => switch (this) {
        CompressionPreset.highQuality => 23,
        CompressionPreset.balanced => 28,
        CompressionPreset.smallest => 32,
      };

  String get audioBitrate => switch (this) {
        CompressionPreset.highQuality => '160k',
        CompressionPreset.balanced => '128k',
        CompressionPreset.smallest => '96k',
      };
}
