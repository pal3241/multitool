import 'package:flutter/material.dart';
import 'package:fileforge/features/video/models/video_operation.dart';

class VideoToolCard extends StatelessWidget {
  const VideoToolCard({
    super.key,
    required this.operation,
    required this.enabled,
    required this.onTap,
  });

  final VideoOperation operation;
  final bool enabled;
  final VoidCallback onTap;

  IconData get _icon => switch (operation) {
        VideoOperation.compress => Icons.compress_rounded,
        VideoOperation.extractAudio => Icons.audiotrack_rounded,
        VideoOperation.convertMp4 => Icons.sync_alt_rounded,
        VideoOperation.removeAudio => Icons.volume_off_rounded,
        VideoOperation.toGif => Icons.gif_box_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 30),
              const SizedBox(height: 16),
              Text(
                operation.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                operation.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
