import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:fileforge/features/image/models/image_models.dart';
import 'package:fileforge/features/image/services/image_engine.dart';
import 'package:fileforge/features/image/services/image_picker_service.dart';

class ImageController extends ChangeNotifier {
  ImageController({required ImagePickerService picker, required ImageEngine engine})
      : _picker = picker,
        _engine = engine;

  final ImagePickerService _picker;
  final ImageEngine _engine;

  List<ImageSourceFile> images = const [];
  ImageQualityPreset quality = ImageQualityPreset.balanced;
  ImageOutputFormat outputFormat = ImageOutputFormat.jpg;
  int maxWidth = 1920;
  bool isPicking = false;
  bool isProcessing = false;
  bool _cancelRequested = false;
  double progress = 0;
  String status = 'Pilih satu atau beberapa gambar.';
  int completed = 0;
  int failed = 0;

  Future<void> pickImages() async {
    if (isProcessing) return;
    isPicking = true;
    status = 'Memilih gambar...';
    notifyListeners();
    try {
      final result = await _picker.pickImages();
      if (result.isEmpty) {
        status = images.isEmpty ? 'Belum ada gambar dipilih.' : 'Pemilihan dibatalkan.';
        return;
      }
      images = result;
      progress = 0;
      completed = 0;
      failed = 0;
      status = '${images.length} gambar siap diproses.';
    } finally {
      isPicking = false;
      notifyListeners();
    }
  }

  void setQuality(ImageQualityPreset value) {
    quality = value;
    notifyListeners();
  }

  void setOutputFormat(ImageOutputFormat value) {
    outputFormat = value;
    notifyListeners();
  }

  void setMaxWidth(int value) {
    maxWidth = value;
    notifyListeners();
  }

  Future<void> compress() => _runBatch(ImageAction.compress);
  Future<void> resize() => _runBatch(ImageAction.resize);
  Future<void> convert() => _runBatch(ImageAction.convert);

  Future<void> createPdf() async {
    if (images.isEmpty || isProcessing) return;
    isProcessing = true;
    _cancelRequested = false;
    progress = 0.05;
    completed = 0;
    failed = 0;
    status = 'Membuat PDF dari ${images.length} gambar...';
    notifyListeners();

    try {
      final source = <Uint8List>[];
      for (var i = 0; i < images.length; i++) {
        if (_cancelRequested) break;
        source.add(await images[i].readBytes());
        progress = 0.05 + ((i + 1) / images.length) * 0.35;
        notifyListeners();
      }
      if (_cancelRequested) {
        status = 'Proses dibatalkan.';
        return;
      }
      final pdf = await _engine.imagesToPdf(source);
      progress = 0.85;
      notifyListeners();
      final saved = await _picker.saveSingle(
        name: 'FileForge-images.pdf',
        bytes: pdf,
        mimeType: 'application/pdf',
      );
      if (!saved) {
        status = 'Penyimpanan PDF dibatalkan.';
        return;
      }
      completed = images.length;
      progress = 1;
      status = 'PDF selesai disimpan.';
    } catch (e) {
      failed++;
      status = 'Gagal membuat PDF: $e';
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _runBatch(ImageAction action) async {
    if (images.isEmpty || isProcessing) return;
    final windowsDirectory = images.length > 1 ? await _picker.chooseBatchDirectory() : null;
    if (images.length > 1 && defaultTargetPlatform == TargetPlatform.windows && windowsDirectory == null) {
      status = 'Folder output dibatalkan.';
      notifyListeners();
      return;
    }

    isProcessing = true;
    _cancelRequested = false;
    progress = 0;
    completed = 0;
    failed = 0;
    status = '${_actionLabel(action)} sedang berjalan...';
    notifyListeners();

    for (var i = 0; i < images.length; i++) {
      if (_cancelRequested) break;
      final source = images[i];
      try {
        final input = await source.readBytes();
        late Uint8List output;
        late String extension;
        late String mimeType;

        switch (action) {
          case ImageAction.compress:
            output = await _engine.compressJpg(input, quality);
            extension = 'jpg';
            mimeType = 'image/jpeg';
            break;
          case ImageAction.resize:
            output = await _engine.resize(
              bytes: input,
              maxWidth: maxWidth,
              format: outputFormat,
              quality: quality,
            );
            extension = outputFormat.extension;
            mimeType = outputFormat.mimeType;
            break;
          case ImageAction.convert:
            output = await _engine.convert(
              bytes: input,
              format: outputFormat,
              quality: quality,
            );
            extension = outputFormat.extension;
            mimeType = outputFormat.mimeType;
            break;
          case ImageAction.toPdf:
            throw StateError('PDF memakai alur terpisah.');
        }

        final name = '${_baseName(source.name)}_${_suffix(action)}.$extension';
        final saved = images.length == 1
            ? await _picker.saveSingle(name: name, bytes: output, mimeType: mimeType)
            : await _picker.saveBatchItem(
                name: name,
                bytes: output,
                mimeType: mimeType,
                windowsDirectory: windowsDirectory,
              );
        if (!saved) {
          _cancelRequested = true;
          break;
        }
        completed++;
      } catch (_) {
        failed++;
      }
      progress = (i + 1) / images.length;
      status = '${_actionLabel(action)}: $completed selesai, $failed gagal.';
      notifyListeners();
    }

    if (_cancelRequested) {
      status = 'Proses dihentikan. $completed selesai, $failed gagal.';
    } else {
      progress = 1;
      status = 'Selesai. $completed berhasil, $failed gagal.';
    }
    isProcessing = false;
    notifyListeners();
  }

  void cancel() {
    if (!isProcessing) return;
    _cancelRequested = true;
    status = 'Menghentikan setelah file saat ini selesai...';
    notifyListeners();
  }

  String _baseName(String name) {
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }

  String _suffix(ImageAction action) => switch (action) {
        ImageAction.compress => 'compressed',
        ImageAction.resize => '${maxWidth}px',
        ImageAction.convert => 'converted',
        ImageAction.toPdf => 'pdf',
      };

  String _actionLabel(ImageAction action) => switch (action) {
        ImageAction.compress => 'Compress Image',
        ImageAction.resize => 'Resize Image',
        ImageAction.convert => 'Convert Image',
        ImageAction.toPdf => 'Images to PDF',
      };
}
