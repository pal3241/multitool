import 'package:flutter/material.dart';
import 'package:fileforge/features/image/image_page.dart';
import 'package:fileforge/features/video/video_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  static const pages = <Widget>[
    VideoPage(),
    ImagePage(),
    _ComingSoonPage(title: 'PDF Toolkit'),
    _ComingSoonPage(title: 'Audio Toolkit'),
  ];

  static const destinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie_rounded),
      label: Text('Video'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.image_outlined),
      selectedIcon: Icon(Icons.image_rounded),
      label: Text('Image'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.picture_as_pdf_outlined),
      selectedIcon: Icon(Icons.picture_as_pdf_rounded),
      label: Text('PDF'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.audiotrack_outlined),
      selectedIcon: Icon(Icons.audiotrack_rounded),
      label: Text('Audio'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 760;
        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) => setState(() => index = value),
                  extended: constraints.maxWidth >= 1100,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: _Brand(compact: true),
                  ),
                  destinations: destinations,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[index]),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const _Brand()),
          body: pages[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Video'),
              NavigationDestination(icon: Icon(Icons.image_outlined), label: 'Image'),
              NavigationDestination(icon: Icon(Icons.picture_as_pdf_outlined), label: 'PDF'),
              NavigationDestination(icon: Icon(Icons.audiotrack_outlined), label: 'Audio'),
            ],
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Tooltip(
        message: 'FileForge',
        child: Icon(Icons.handyman_rounded, size: 28),
      );
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.handyman_rounded),
        SizedBox(width: 8),
        Text('FileForge'),
      ],
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension_rounded, size: 54),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            const Text('Fondasi modul sudah disiapkan. Tool ini akan ditambahkan berikutnya.'),
          ],
        ),
      ),
    );
  }
}
