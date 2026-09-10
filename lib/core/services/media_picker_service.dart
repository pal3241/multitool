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

    final file = await FilePicker.pickFile(
      type: FileType.video,
    );
    if (file == null) return null;

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
