enum VideoOperation {
  compress,
  targetSize,
  whatsapp,
  extractAudio,
  convertMp4,
  removeAudio,
  toGif,
  resize,
  trim,
  changeFps,
}

extension VideoOperationX on VideoOperation {
  String get title => switch (this) {
        VideoOperation.compress => 'Compress Video',
        VideoOperation.targetSize => 'Target Size',
        VideoOperation.whatsapp => 'WhatsApp Preset',
        VideoOperation.extractAudio => 'Extract Audio',
        VideoOperation.convertMp4 => 'Convert to MP4',
        VideoOperation.removeAudio => 'Remove Audio',
        VideoOperation.toGif => 'Video to GIF',
        VideoOperation.resize => 'Resize Video',
        VideoOperation.trim => 'Trim / Cut',
        VideoOperation.changeFps => 'Change FPS',
      };

  String get description => switch (this) {
        VideoOperation.compress => 'Kurangi ukuran dengan preset kualitas H.264 + AAC.',
        VideoOperation.targetSize => 'Kompres mendekati batas ukuran MB yang kamu tentukan.',
        VideoOperation.whatsapp => 'Optimasi 720p, 30 FPS, H.264 + AAC untuk WhatsApp.',
        VideoOperation.extractAudio => 'Ambil audio dan simpan sebagai MP3.',
        VideoOperation.convertMp4 => 'Ubah video menjadi MP4 yang kompatibel.',
        VideoOperation.removeAudio => 'Buat salinan video tanpa suara.',
        VideoOperation.toGif => 'Ubah video menjadi GIF 12 FPS.',
        VideoOperation.resize => 'Ubah tinggi video ke 1080p, 720p, atau 480p.',
        VideoOperation.trim => 'Potong video berdasarkan waktu mulai dan selesai.',
        VideoOperation.changeFps => 'Ubah frame rate ke 24, 30, atau 60 FPS.',
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
