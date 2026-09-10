import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fileforge/core/models/media_location.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';

class MediaPickerService {
  Future<MediaLocation?> pickVideo() async {
    if (Platform.isAndroid) {
      final uri = await FFmpegKitConfig.selectDocumentForRead('video/*');
      if (uri == null) return null;

      final safPath = await FFmpegKitConfig.getSafParameterForRead(uri);
      if (safPath == null) return null;

      return MediaLocation(
        ffmpegPath: safPath,
        displayName: _androidDisplayName(uri),
      );
    }

    final file = await FilePicker.pickFile(type: FileType.video);
    if (file == null) return null;

    final path = await _usablePath(file);
    if (path == null) return null;

    return MediaLocation(ffmpegPath: path, displayName: file.name);
  }

  Future<List<MediaLocation>> pickVideos() async {
    final files = await FilePicker.pickFiles(type: FileType.video);
    if (files.isEmpty) return const [];

    final result = <MediaLocation>[];
    for (final file in files) {
      final path = await _usablePath(file);
      if (path == null) continue;
      result.add(MediaLocation(ffmpegPath: path, displayName: file.name));
    }
    return result;
  }

  Future<MediaLocation?> chooseOutput({
    required String suggestedName,
    required String extension,
    required String mimeType,
  }) async {
    if (Platform.isAndroid) {
      final uri = await FFmpegKitConfig.selectDocumentForWrite(
        suggestedName,
        mimeType,
      );
      if (uri == null) return null;

      final safPath = await FFmpegKitConfig.getSafParameterForWrite(uri);
      if (safPath == null) return null;

      return MediaLocation(
        ffmpegPath: safPath,
        displayName: suggestedName,
      );
    }

    final directory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Pilih folder output',
    );
    if (directory == null) return null;

    final path = '$directory${Platform.pathSeparator}$suggestedName';
    final finalPath = _ensureExtension(path, extension);
    return MediaLocation(
      ffmpegPath: finalPath,
      displayName: _basename(finalPath),
    );
  }

  Future<List<MediaLocation>?> chooseBatchOutputs({
    required List<String> suggestedNames,
    required String extension,
    required String mimeType,
  }) async {
    if (suggestedNames.isEmpty) return const [];

    if (Platform.isAndroid) {
      final outputs = <MediaLocation>[];
      for (final name in suggestedNames) {
        final output = await chooseOutput(
          suggestedName: name,
          extension: extension,
          mimeType: mimeType,
        );
        if (output == null) return null;
        outputs.add(output);
      }
      return outputs;
    }

    final directory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Pilih folder output batch',
    );
    if (directory == null) return null;

    return suggestedNames.map((name) {
      final path = '$directory${Platform.pathSeparator}$name';
      final finalPath = _ensureExtension(path, extension);
      return MediaLocation(
        ffmpegPath: finalPath,
        displayName: _basename(finalPath),
      );
    }).toList();
  }

  Future<String?> _usablePath(PlatformFile file) async {
    if (file.path != null && file.path!.isNotEmpty) return file.path;

    // Fallback untuk provider yang tidak memberikan path langsung:
    // salin stream ke cache lokal agar FFmpeg tetap dapat membacanya offline.
    try {
      final safeName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final path = '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'fileforge_${DateTime.now().microsecondsSinceEpoch}_$safeName';
      final sink = File(path).openWrite();
      try {
        await for (final chunk in file.readAsByteStream()) {
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }
      return path;
    } catch (_) {
      return null;
    }
  }

  String _androidDisplayName(String uri) {
    final decoded = Uri.decodeComponent(uri);
    final slash = decoded.lastIndexOf('/');
    final colon = decoded.lastIndexOf(':');
    final index = slash > colon ? slash : colon;
    if (index >= 0 && index + 1 < decoded.length) {
      return decoded.substring(index + 1);
    }
    return 'Selected video';
  }

  String _ensureExtension(String path, String extension) {
    final suffix = '.$extension';
    return path.toLowerCase().endsWith(suffix) ? path : '$path$suffix';
  }

  String _basename(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}
