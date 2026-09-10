import 'package:fileforge/core/models/media_location.dart';
import 'package:fileforge/core/models/process_result.dart';
import 'package:fileforge/features/video/models/video_info.dart';
import 'package:fileforge/features/video/models/video_operation.dart';

typedef ProgressCallback = void Function(double progress);
typedef LogCallback = void Function(String message);

abstract class VideoEngine {
  Future<VideoInfo> probe(MediaLocation input);

  Future<ProcessResult> process({
    required VideoOperation operation,
    required MediaLocation input,
    required MediaLocation output,
    required CompressionPreset compressionPreset,
    required double durationSeconds,
    required double targetSizeMb,
    required int resizeHeight,
    required int targetFps,
    required double trimStartSeconds,
    required double trimEndSeconds,
    required ProgressCallback onProgress,
    required LogCallback onLog,
  });

  Future<void> cancel();
}
