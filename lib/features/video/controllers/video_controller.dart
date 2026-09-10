import 'package:flutter/foundation.dart';
import 'package:fileforge/core/models/media_location.dart';
import 'package:fileforge/core/models/process_result.dart';
import 'package:fileforge/core/services/media_picker_service.dart';
import 'package:fileforge/features/video/models/video_info.dart';
import 'package:fileforge/features/video/models/video_operation.dart';
import 'package:fileforge/features/video/services/video_engine.dart';

class VideoController extends ChangeNotifier {
  VideoController({
    required MediaPickerService picker,
    required VideoEngine engine,
  })  : _picker = picker,
        _engine = engine;

  final MediaPickerService _picker;
  final VideoEngine _engine;

  MediaLocation? input;
  VideoInfo? info;
  CompressionPreset preset = CompressionPreset.balanced;
  bool isPicking = false;
  bool isProcessing = false;
  double progress = 0;
  String status = 'Pilih video untuk memulai.';
  String? lastOutput;
  final List<String> logs = [];

  Future<void> pickVideo() async {
    if (isProcessing) return;
    isPicking = true;
    status = 'Memilih video...';
    notifyListeners();

    try {
      final picked = await _picker.pickVideo();
      if (picked == null) {
        status = input == null ? 'Belum ada video dipilih.' : 'Pemilihan dibatalkan.';
        return;
      }

      input = picked;
      info = null;
      lastOutput = null;
      status = 'Membaca informasi video...';
      notifyListeners();

      info = await _engine.probe(picked);
      status = 'Video siap diproses.';
    } catch (e) {
      status = 'Gagal membaca video: $e';
    } finally {
      isPicking = false;
      notifyListeners();
    }
  }

  void setPreset(CompressionPreset value) {
    preset = value;
    notifyListeners();
  }

  Future<void> run(VideoOperation operation) async {
    final source = input;
    final videoInfo = info;
    if (source == null || videoInfo == null || isProcessing) return;

    final base = _withoutExtension(source.displayName);
    final suffix = switch (operation) {
      VideoOperation.compress => '_compressed',
      VideoOperation.extractAudio => '_audio',
      VideoOperation.convertMp4 => '_converted',
      VideoOperation.removeAudio => '_mute',
      VideoOperation.toGif => '',
    };
    final suggested = '$base$suffix.${operation.extension}';

    final output = await _picker.chooseOutput(
      suggestedName: suggested,
      extension: operation.extension,
      mimeType: operation.mimeType,
    );
    if (output == null) {
      status = 'Penyimpanan output dibatalkan.';
      notifyListeners();
      return;
    }

    isProcessing = true;
    progress = 0;
    logs.clear();
    lastOutput = null;
    status = '${operation.title} sedang berjalan...';
    notifyListeners();

    try {
      final result = await _engine.process(
        operation: operation,
        input: source,
        output: output,
        compressionPreset: preset,
        durationSeconds: videoInfo.durationSeconds,
        onProgress: (value) {
          progress = value;
          notifyListeners();
        },
        onLog: (message) {
          logs.add(message);
          if (logs.length > 120) logs.removeAt(0);
          notifyListeners();
        },
      );
      _applyResult(result);
    } catch (e) {
      status = 'Proses gagal: $e';
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> cancel() async {
    if (!isProcessing) return;
    status = 'Membatalkan...';
    notifyListeners();
    await _engine.cancel();
  }

  void _applyResult(ProcessResult result) {
    if (result.success) {
      progress = 1;
      lastOutput = result.outputName;
      status = 'Selesai: ${result.outputName ?? 'output tersimpan'}';
    } else if (result.cancelled) {
      status = 'Proses dibatalkan.';
    } else {
      status = 'Gagal. Buka log untuk detail.';
      if (result.message.isNotEmpty) logs.add(result.message);
    }
  }

  String _withoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }
}
