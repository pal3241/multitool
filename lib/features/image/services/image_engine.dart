import 'dart:isolate';
import 'dart:typed_data';

import 'package:fileforge/features/image/models/image_models.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageEngine {
  Future<Uint8List> compressJpg(Uint8List bytes, ImageQualityPreset preset) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw StateError('Format gambar tidak dapat dibaca.');
      final oriented = img.bakeOrientation(decoded);
      return img.encodeJpg(oriented, quality: preset.jpegQuality);
    });
  }

  Future<Uint8List> resize({
    required Uint8List bytes,
    required int maxWidth,
    required ImageOutputFormat format,
    required ImageQualityPreset quality,
  }) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw StateError('Format gambar tidak dapat dibaca.');
      final oriented = img.bakeOrientation(decoded);
      final resized = oriented.width > maxWidth
          ? img.copyResize(
              oriented,
              width: maxWidth,
              interpolation: img.Interpolation.cubic,
            )
          : oriented;
      return _encode(resized, format, quality.jpegQuality);
    });
  }

  Future<Uint8List> convert({
    required Uint8List bytes,
    required ImageOutputFormat format,
    required ImageQualityPreset quality,
  }) {
    return Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw StateError('Format gambar tidak dapat dibaca.');
      final oriented = img.bakeOrientation(decoded);
      return _encode(oriented, format, quality.jpegQuality);
    });
  }

  Future<Uint8List> imagesToPdf(List<Uint8List> sourceImages) {
    return Isolate.run(() async {
      final document = pw.Document();
      for (final bytes in sourceImages) {
        final decoded = img.decodeImage(bytes);
        if (decoded == null) continue;
        final oriented = img.bakeOrientation(decoded);
        final jpg = img.encodeJpg(oriented, quality: 90);
        final memory = pw.MemoryImage(jpg);
        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (_) => pw.Center(
              child: pw.Image(memory, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
      return Uint8List.fromList(await document.save());
    });
  }

  static Uint8List _encode(
    img.Image image,
    ImageOutputFormat format,
    int jpegQuality,
  ) {
    return switch (format) {
      ImageOutputFormat.jpg => img.encodeJpg(image, quality: jpegQuality),
      ImageOutputFormat.png => img.encodePng(image, level: 6),
      ImageOutputFormat.webp => img.encodeWebP(image),
    };
  }
}
