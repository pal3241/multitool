import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fileforge/features/image/models/image_models.dart';
import 'package:image/image.dart' as img;

class ImagePickerService {
  Future<List<ImageSourceFile>> pickImages() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return const [];

    final selected = <ImageSourceFile>[];
    for (final file in files.take(50)) {
      try {
        Uint8List? cached;
        final path = file.path;
        final bytes = path != null && path.isNotEmpty
            ? await File(path).readAsBytes()
            : await file.readAsBytes();
        if (path == null || path.isEmpty) cached = bytes;

        final decoded = img.decodeImage(bytes);
        if (decoded == null) continue;

        selected.add(ImageSourceFile(
          name: file.name,
          path: path,
          cachedBytes: cached,
          sizeBytes: bytes.length,
          width: decoded.width,
          height: decoded.height,
          format: _extension(file.name).toUpperCase(),
        ));
      } catch (_) {
        // Lewati file yang tidak dapat dibaca tanpa menggagalkan seluruh batch.
      }
    }
    return selected;
  }

  Future<bool> saveSingle({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Simpan hasil FileForge',
      fileName: name,
      bytes: bytes,
      mimeType: mimeType,
    );
    return uri != null;
  }

  Future<String?> chooseBatchDirectory() async {
    if (!Platform.isWindows) return null;
    return FilePicker.getDirectoryPath(dialogTitle: 'Pilih folder output Image Batch');
  }

  Future<bool> saveBatchItem({
    required String name,
    required Uint8List bytes,
    required String mimeType,
    String? windowsDirectory,
  }) async {
    if (Platform.isWindows && windowsDirectory != null) {
      final path = '$windowsDirectory${Platform.pathSeparator}$name';
      await File(path).writeAsBytes(bytes, flush: true);
      return true;
    }
    return saveSingle(name: name, bytes: bytes, mimeType: mimeType);
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    return dot < 0 || dot == name.length - 1 ? 'IMAGE' : name.substring(dot + 1);
  }
}
