import 'package:flutter/material.dart';
import 'package:fileforge/features/image/controllers/image_controller.dart';
import 'package:fileforge/features/image/models/image_models.dart';
import 'package:fileforge/features/image/services/image_engine.dart';
import 'package:fileforge/features/image/services/image_picker_service.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late final ImageController controller;

  @override
  void initState() {
    super.initState();
    controller = ImageController(
      picker: ImagePickerService(),
      engine: ImageEngine(),
    )..addListener(_refresh);
  }

  @override
  void dispose() {
    controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = controller.images.isNotEmpty && !controller.isProcessing;
    final totalBytes = controller.images.fold<int>(0, (sum, image) => sum + image.sizeBytes);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Image Toolkit',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text('Compress, resize, convert, batch processing, dan Images → PDF. Semua lokal.'),
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
                            controller.images.isEmpty
                                ? 'Belum ada gambar'
                                : '${controller.images.length} gambar dipilih',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(controller.status),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: controller.isPicking || controller.isProcessing
                          ? null
                          : controller.pickImages,
                      icon: const Icon(Icons.add_photo_alternate_rounded),
                      label: Text(controller.images.isEmpty ? 'Pilih Gambar' : 'Ganti'),
                    ),
                  ],
                ),
                if (controller.images.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('${controller.images.length} file')),
                      Chip(label: Text(_sizeLabel(totalBytes))),
                      Chip(label: Text('Max 50 file / batch')),
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
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<ImageQualityPreset>(
                  value: controller.quality,
                  onChanged: controller.isProcessing ? null : (v) => v == null ? null : controller.setQuality(v),
                  items: ImageQualityPreset.values
                      .map((v) => DropdownMenuItem(value: v, child: Text('Quality: ${v.label}')))
                      .toList(),
                ),
                DropdownButton<int>(
                  value: controller.maxWidth,
                  onChanged: controller.isProcessing ? null : (v) => v == null ? null : controller.setMaxWidth(v),
                  items: const [
                    DropdownMenuItem(value: 3840, child: Text('Resize: 3840 px')),
                    DropdownMenuItem(value: 1920, child: Text('Resize: 1920 px')),
                    DropdownMenuItem(value: 1280, child: Text('Resize: 1280 px')),
                    DropdownMenuItem(value: 720, child: Text('Resize: 720 px')),
                  ],
                ),
                DropdownButton<ImageOutputFormat>(
                  value: controller.outputFormat,
                  onChanged: controller.isProcessing ? null : (v) => v == null ? null : controller.setOutputFormat(v),
                  items: ImageOutputFormat.values
                      .map((v) => DropdownMenuItem(value: v, child: Text('Output: ${v.label}')))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Tools', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1050 ? 4 : (constraints.maxWidth >= 650 ? 2 : 1);
            final itemWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ToolCard(
                  width: itemWidth,
                  icon: Icons.compress_rounded,
                  title: 'Compress Image',
                  description: 'Encode ke JPG dengan pilihan kualitas. Mendukung batch.',
                  enabled: enabled,
                  onTap: controller.compress,
                ),
                _ToolCard(
                  width: itemWidth,
                  icon: Icons.photo_size_select_large_rounded,
                  title: 'Resize Image',
                  description: 'Batasi lebar sambil menjaga aspect ratio.',
                  enabled: enabled,
                  onTap: controller.resize,
                ),
                _ToolCard(
                  width: itemWidth,
                  icon: Icons.transform_rounded,
                  title: 'Convert Format',
                  description: 'Ubah ke JPG, PNG, atau WebP.',
                  enabled: enabled,
                  onTap: controller.convert,
                ),
                _ToolCard(
                  width: itemWidth,
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'Images → PDF',
                  description: 'Gabungkan gambar sesuai urutan pilihan menjadi PDF A4.',
                  enabled: enabled,
                  onTap: controller.createPdf,
                ),
              ],
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
                  LinearProgressIndicator(value: controller.progress <= 0 ? null : controller.progress),
                  const SizedBox(height: 6),
                  Text('${(controller.progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ],
        if (controller.images.isNotEmpty) ...[
          const SizedBox(height: 20),
          ExpansionTile(
            title: Text('Selected files (${controller.images.length})'),
            children: controller.images
                .take(20)
                .map((image) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.image_outlined),
                      title: Text(image.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${image.resolutionLabel} • ${image.sizeLabel} • ${image.format}'),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  String _sizeLabel(int bytes) {
    final mb = bytes / 1024 / 1024;
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} GB total';
    return '${mb.toStringAsFixed(2)} MB total';
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 30),
                const SizedBox(height: 14),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
