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

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final path = file.path;
    if (path == null) return null;

    return MediaLocation(ffmpegPath: path, displayName: file.name);
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

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save output',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: [extension],
    );
    if (path == null) return null;

    return MediaLocation(
      ffmpegPath: _ensureExtension(path, extension),
      displayName: _basename(_ensureExtension(path, extension)),
    );
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
