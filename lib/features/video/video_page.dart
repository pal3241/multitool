import 'package:flutter/material.dart';
import 'package:fileforge/core/services/media_picker_service.dart';
import 'package:fileforge/features/video/controllers/video_controller.dart';
import 'package:fileforge/features/video/models/video_operation.dart';
import 'package:fileforge/features/video/services/ffmpeg_video_engine.dart';
import 'package:fileforge/features/video/widgets/video_tool_card.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final VideoController controller;
  late final TextEditingController _targetSizeController;
  late final TextEditingController _trimStartController;
  late final TextEditingController _trimEndController;

  @override
  void initState() {
    super.initState();
    controller = VideoController(
      picker: MediaPickerService(),
      engine: FfmpegVideoEngine(),
    )..addListener(_refresh);
    _targetSizeController = TextEditingController(text: '15');
    _trimStartController = TextEditingController(text: '0');
    _trimEndController = TextEditingController();
  }

  @override
  void dispose() {
    controller
      ..removeListener(_refresh)
      ..dispose();
    _targetSizeController.dispose();
    _trimStartController.dispose();
    _trimEndController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _pickVideo() async {
    await controller.pickVideo();
    final info = controller.info;
    if (info != null) {
      _trimStartController.text = '0';
      _trimEndController.text = info.durationSeconds.toStringAsFixed(2);
    }
  }

  Future<void> _run(VideoOperation operation) async {
    final targetText = _targetSizeController.text.replaceAll(',', '.');
    final startText = _trimStartController.text.replaceAll(',', '.');
    final endText = _trimEndController.text.replaceAll(',', '.');

    final target = double.tryParse(targetText);
    if (target != null) controller.setTargetSizeMb(target);

    final start = double.tryParse(startText) ?? 0;
    final end = double.tryParse(endText) ?? controller.info?.durationSeconds ?? 0;
    controller.setTrimRange(start: start, end: end);

    await controller.run(operation);
  }

  @override
  Widget build(BuildContext context) {
    final info = controller.info;
    final enabled = info != null && !controller.isProcessing;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Video Toolkit',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Semua proses berjalan lokal di perangkat tanpa upload ke server.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.input?.displayName ?? 'Belum ada video',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(controller.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: controller.isPicking || controller.isProcessing
                          ? null
                          : _pickVideo,
                      icon: const Icon(Icons.video_file_rounded),
                      label: Text(controller.input == null ? 'Pilih Video' : 'Ganti'),
                    ),
                  ],
                ),
                if (info != null) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: 'Size', value: info.sizeLabel),
                      _InfoChip(label: 'Duration', value: info.durationLabel),
                      _InfoChip(label: 'Resolution', value: info.resolutionLabel),
                      _InfoChip(label: 'Video', value: info.videoCodec),
                      _InfoChip(label: 'Audio', value: info.audioCodec),
                      _InfoChip(label: 'FPS', value: info.fpsLabel),
                      _InfoChip(label: 'Bitrate', value: info.bitrateLabel),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nilai di bawah dipakai oleh Target Size, Resize, Trim, dan Change FPS.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 170,
                      child: TextField(
                        controller: _targetSizeController,
                        enabled: !controller.isProcessing,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target size (MB)',
                          border: OutlineInputBorder(),
                          helperText: 'Contoh: 15',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<int>(
                        initialValue: controller.resizeHeight,
                        decoration: const InputDecoration(
                          labelText: 'Resize',
                          border: OutlineInputBorder(),
                        ),
                        items: const [1080, 720, 480]
                            .map((height) => DropdownMenuItem(
                                  value: height,
                                  child: Text('${height}p'),
                                ))
                            .toList(),
                        onChanged: controller.isProcessing
                            ? null
                            : (value) {
                                if (value != null) controller.setResizeHeight(value);
                              },
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<int>(
                        initialValue: controller.targetFps,
                        decoration: const InputDecoration(
                          labelText: 'Target FPS',
                          border: OutlineInputBorder(),
                        ),
                        items: const [24, 30, 60]
                            .map((fps) => DropdownMenuItem(
                                  value: fps,
                                  child: Text('$fps FPS'),
                                ))
                            .toList(),
                        onChanged: controller.isProcessing
                            ? null
                            : (value) {
                                if (value != null) controller.setTargetFps(value);
                              },
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: TextField(
                        controller: _trimStartController,
                        enabled: !controller.isProcessing,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Trim start (sec)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: TextField(
                        controller: _trimEndController,
                        enabled: !controller.isProcessing,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Trim end (sec)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.queue_play_next_rounded, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batch Compress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            'Pilih banyak video dan kompres satu per satu dengan preset Compress aktif.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  controller.batchInputs.isEmpty
                      ? 'Belum ada video dalam antrean.'
                      : '${controller.batchInputs.length} video dalam antrean • '
                        '${controller.batchSucceeded} berhasil / ${controller.batchCompleted} diproses',
                ),
                if (controller.batchInputs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: controller.batchInputs
                        .take(6)
                        .map((item) => Chip(
                              visualDensity: VisualDensity.compact,
                              label: SizedBox(
                                width: 150,
                                child: Text(
                                  item.displayName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  if (controller.batchInputs.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('+${controller.batchInputs.length - 6} video lainnya'),
                    ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.isPicking || controller.isProcessing
                          ? null
                          : controller.pickBatchVideos,
                      icon: const Icon(Icons.video_library_rounded),
                      label: const Text('Pilih Banyak Video'),
                    ),
                    FilledButton.icon(
                      onPressed: controller.batchInputs.isEmpty || controller.isProcessing
                          ? null
                          : controller.runBatchCompress,
                      icon: const Icon(Icons.compress_rounded),
                      label: const Text('Mulai Batch'),
                    ),
                    if (controller.batchInputs.isNotEmpty)
                      TextButton.icon(
                        onPressed: controller.isProcessing ? null : controller.clearBatch,
                        icon: const Icon(Icons.clear_all_rounded),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
                if (Theme.of(context).platform == TargetPlatform.android) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Android akan meminta lokasi simpan untuk setiap output agar tetap memakai Storage Access Framework tanpa izin akses semua file.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            DropdownButton<CompressionPreset>(
              value: controller.preset,
              onChanged: controller.isProcessing
                  ? null
                  : (value) {
                      if (value != null) controller.setPreset(value);
                    },
              items: CompressionPreset.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('Compress: ${value.label}'),
                      ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1050 ? 3 : (width >= 650 ? 2 : 1);
            final itemWidth = (width - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: VideoOperation.values
                  .map((operation) => SizedBox(
                        width: itemWidth,
                        child: VideoToolCard(
                          operation: operation,
                          enabled: enabled,
                          onTap: () => _run(operation),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
        if (controller.isProcessing || controller.progress > 0) ...[
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(controller.status)),
                      if (controller.isProcessing)
                        TextButton.icon(
                          onPressed: controller.cancel,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Cancel'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: controller.progress <= 0 ? null : controller.progress,
                  ),
                  const SizedBox(height: 6),
                  Text('${(controller.progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ],
        if (controller.logs.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('FFmpeg log'),
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 260),
                padding: const EdgeInsets.all(12),
                color: Colors.black26,
                child: SingleChildScrollView(
                  child: SelectableText(
                    controller.logs.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
