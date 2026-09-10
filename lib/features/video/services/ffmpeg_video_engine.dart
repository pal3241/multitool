import 'dart:async';
import 'dart:math' as math;

import 'package:fileforge/core/models/media_location.dart';
import 'package:fileforge/core/models/process_result.dart';
import 'package:fileforge/features/video/models/video_info.dart';
import 'package:fileforge/features/video/models/video_operation.dart';
import 'package:fileforge/features/video/services/video_engine.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class FfmpegVideoEngine implements VideoEngine {
  int? _activeSessionId;

  @override
  Future<VideoInfo> probe(MediaLocation input) async {
    final session = await FFprobeKit.getMediaInformation(input.ffmpegPath);
    final information = session.getMediaInformation();
    if (information == null) {
      final output = await session.getOutput();
      throw StateError('FFprobe gagal membaca video. ${output ?? ''}'.trim());
    }

    final streams = information.getStreams();
    final videoStream = streams.where((s) => s.getType() == 'video').firstOrNull;
    final audioStream = streams.where((s) => s.getType() == 'audio').firstOrNull;

    final duration = double.tryParse(information.getDuration() ?? '') ?? 0;
    final size = int.tryParse(information.getSize() ?? '');
    final bitrate = int.tryParse(information.getBitrate() ?? '');

    return VideoInfo(
      durationSeconds: duration,
      format: information.getFormat() ?? '-',
      sizeBytes: size,
      width: videoStream?.getWidth(),
      height: videoStream?.getHeight(),
      videoCodec: videoStream?.getCodec() ?? '-',
      audioCodec: audioStream?.getCodec() ?? 'No audio',
      frameRate: _parseFrameRate(videoStream?.getAverageFrameRate()),
      bitrate: bitrate,
    );
  }

  @override
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
  }) async {
    final completer = Completer<ProcessResult>();
    final args = _buildArguments(
      operation: operation,
      input: input.ffmpegPath,
      output: output.ffmpegPath,
      preset: compressionPreset,
      durationSeconds: durationSeconds,
      targetSizeMb: targetSizeMb,
      resizeHeight: resizeHeight,
      targetFps: targetFps,
      trimStartSeconds: trimStartSeconds,
      trimEndSeconds: trimEndSeconds,
    );

    onLog('FFmpeg operation: ${operation.title}');

    final session = await FFmpegKit.executeWithArgumentsAsync(
      args,
      (completedSession) async {
        final returnCode = await completedSession.getReturnCode();
        _activeSessionId = null;

        if (ReturnCode.isSuccess(returnCode)) {
          onProgress(1);
          completer.complete(ProcessResult(
            success: true,
            cancelled: false,
            message: 'Selesai.',
            outputName: output.displayName,
          ));
          return;
        }

        if (ReturnCode.isCancel(returnCode)) {
          completer.complete(const ProcessResult(
            success: false,
            cancelled: true,
            message: 'Proses dibatalkan.',
          ));
          return;
        }

        final ffmpegOutput = await completedSession.getOutput();
        completer.complete(ProcessResult(
          success: false,
          cancelled: false,
          message: ffmpegOutput?.trim().isNotEmpty == true
              ? ffmpegOutput!.trim()
              : 'FFmpeg gagal menjalankan proses.',
        ));
      },
      (log) {
        final message = log.getMessage().trim();
        if (message.isNotEmpty) onLog(message);
      },
      (statistics) {
        if (durationSeconds <= 0) return;
        final progress = (statistics.getTime() / (durationSeconds * 1000))
            .clamp(0.0, 0.99)
            .toDouble();
        onProgress(progress);
      },
    );

    _activeSessionId = session.getSessionId();
    return completer.future;
  }

  @override
  Future<void> cancel() async {
    final id = _activeSessionId;
    if (id != null) {
      await FFmpegKit.cancel(id);
    }
  }

  List<String> _buildArguments({
    required VideoOperation operation,
    required String input,
    required String output,
    required CompressionPreset preset,
    required double durationSeconds,
    required double targetSizeMb,
    required int resizeHeight,
    required int targetFps,
    required double trimStartSeconds,
    required double trimEndSeconds,
  }) {
    final commonInput = ['-y', '-i', input];

    return switch (operation) {
      VideoOperation.compress => [
          ...commonInput,
          '-map', '0:v:0',
          '-map', '0:a?',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', preset.crf.toString(),
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', preset.audioBitrate,
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.targetSize => _targetSizeArguments(
          input: input,
          output: output,
          durationSeconds: durationSeconds,
          targetSizeMb: targetSizeMb,
        ),
      VideoOperation.whatsapp => [
          ...commonInput,
          '-map', '0:v:0',
          '-map', '0:a?',
          '-vf', 'scale=-2:720,fps=30',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '28',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '96k',
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.extractAudio => [
          ...commonInput,
          '-vn',
          '-c:a', 'libmp3lame',
          '-b:a', '192k',
          output,
        ],
      VideoOperation.convertMp4 => [
          ...commonInput,
          '-map', '0:v:0',
          '-map', '0:a?',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '23',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '160k',
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.removeAudio => [
          ...commonInput,
          '-map', '0:v:0',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '23',
          '-pix_fmt', 'yuv420p',
          '-an',
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.toGif => [
          ...commonInput,
          '-filter_complex',
          '[0:v]fps=12,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse',
          '-loop', '0',
          output,
        ],
      VideoOperation.resize => [
          ...commonInput,
          '-map', '0:v:0',
          '-map', '0:a?',
          '-vf', 'scale=-2:$resizeHeight',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '23',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '128k',
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.trim => [
          '-y',
          '-i', input,
          '-ss', trimStartSeconds.toStringAsFixed(3),
          '-t', math.max(0.1, trimEndSeconds - trimStartSeconds).toStringAsFixed(3),
          '-map', '0:v:0',
          '-map', '0:a?',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '23',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '128k',
          '-movflags', '+faststart',
          output,
        ],
      VideoOperation.changeFps => [
          ...commonInput,
          '-map', '0:v:0',
          '-map', '0:a?',
          '-vf', 'fps=$targetFps',
          '-c:v', 'libx264',
          '-preset', 'veryfast',
          '-crf', '23',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '128k',
          '-movflags', '+faststart',
          output,
        ],
    };
  }

  List<String> _targetSizeArguments({
    required String input,
    required String output,
    required double durationSeconds,
    required double targetSizeMb,
  }) {
    final safeDuration = math.max(1.0, durationSeconds);
    final safeTarget = math.max(1.0, targetSizeMb);

    // Gunakan 88% dari budget agar output cenderung tetap di bawah target
    // setelah memperhitungkan mux/container overhead dan variasi encoder.
    final totalKbps = ((safeTarget * 1024 * 1024 * 8 * 0.88) /
            safeDuration /
            1000)
        .floor();
    final audioKbps = math.max(48, math.min(128, (totalKbps * 0.12).floor()));
    final videoKbps = math.max(100, totalKbps - audioKbps);

    return [
      '-y',
      '-i', input,
      '-map', '0:v:0',
      '-map', '0:a?',
      '-c:v', 'libx264',
      '-preset', 'veryfast',
      '-b:v', '${videoKbps}k',
      '-maxrate', '${videoKbps}k',
      '-bufsize', '${videoKbps * 2}k',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'aac',
      '-b:a', '${audioKbps}k',
      '-movflags', '+faststart',
      output,
    ];
  }

  double? _parseFrameRate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!value.contains('/')) return double.tryParse(value);
    final parts = value.split('/');
    if (parts.length != 2) return null;
    final a = double.tryParse(parts[0]);
    final b = double.tryParse(parts[1]);
    if (a == null || b == null || b == 0) return null;
    return a / b;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
