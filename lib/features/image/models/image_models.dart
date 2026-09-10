import 'dart:io';
import 'dart:typed_data';

enum ImageOutputFormat { jpg, png, webp }

extension ImageOutputFormatX on ImageOutputFormat {
  String get extension => switch (this) {
        ImageOutputFormat.jpg => 'jpg',
        ImageOutputFormat.png => 'png',
        ImageOutputFormat.webp => 'webp',
      };

  String get label => switch (this) {
        ImageOutputFormat.jpg => 'JPG',
        ImageOutputFormat.png => 'PNG',
        ImageOutputFormat.webp => 'WebP',
      };

  String get mimeType => switch (this) {
        ImageOutputFormat.jpg => 'image/jpeg',
        ImageOutputFormat.png => 'image/png',
        ImageOutputFormat.webp => 'image/webp',
      };
}

enum ImageQualityPreset { high, balanced, small }

extension ImageQualityPresetX on ImageQualityPreset {
  String get label => switch (this) {
        ImageQualityPreset.high => 'High Quality',
        ImageQualityPreset.balanced => 'Balanced',
        ImageQualityPreset.small => 'Small Size',
      };

  int get jpegQuality => switch (this) {
        ImageQualityPreset.high => 90,
        ImageQualityPreset.balanced => 75,
        ImageQualityPreset.small => 55,
      };
}

class ImageSourceFile {
  const ImageSourceFile({
    required this.name,
    required this.path,
    required this.cachedBytes,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.format,
  });

  final String name;
  final String? path;
  final Uint8List? cachedBytes;
  final int sizeBytes;
  final int width;
  final int height;
  final String format;

  Future<Uint8List> readBytes() async {
    final memory = cachedBytes;
    if (memory != null) return memory;
    final filePath = path;
    if (filePath == null || filePath.isEmpty) {
      throw StateError('File $name tidak memiliki data yang dapat dibaca.');
    }
    return File(filePath).readAsBytes();
  }

  String get resolutionLabel => '$width×$height';

  String get sizeLabel {
    final mb = sizeBytes / 1024 / 1024;
    if (mb >= 1) return '${mb.toStringAsFixed(2)} MB';
    return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
  }
}

enum ImageAction { compress, resize, convert, toPdf }
