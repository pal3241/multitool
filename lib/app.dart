import 'package:flutter/material.dart';
import 'package:fileforge/features/home/home_page.dart';

class FileForgeApp extends StatelessWidget {
  const FileForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D5DFB),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'FileForge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0E0F13),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
        ),
      ),
      home: const HomePage(),
    );
  }
}
