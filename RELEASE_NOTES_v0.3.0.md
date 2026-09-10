# FileForge v0.3.0

FileForge v0.3.0 menambahkan Image Toolkit offline untuk Windows dan Android.

## Image Toolkit baru

- Compress Image ke JPG dengan preset High Quality / Balanced / Small Size
- Resize Image dengan target lebar 3840 / 1920 / 1280 / 720 px dan aspect ratio tetap terjaga
- Convert Image ke JPG / PNG / WebP
- Images → PDF A4 dari beberapa gambar
- Batch image processing sampai 50 file per pilihan
- Progress keseluruhan dan cancel antar-file
- Windows: satu folder output untuk batch
- Android: save dialog sistem agar kompatibel dengan scoped storage tanpa izin akses semua file
- Pemrosesan gambar dilakukan lokal menggunakan Dart image library

## Video Toolkit

Semua fitur v0.2.1 tetap tersedia, termasuk Compress Video, Target Size, WhatsApp preset, Resize, Trim, FPS converter, Extract Audio, Convert MP4, Remove Audio, GIF, dan Batch Compress.

## Windows

Gunakan `FileForge-Setup-v0.3.0.exe`. Installer membuat shortcut Desktop dan Start Menu serta menyediakan uninstaller.

## Android

Untuk mayoritas HP Android modern gunakan `FileForge-Android-arm64-v8a-v0.3.0.apk`. APK universal juga tersedia.

Semua pemrosesan file berlangsung lokal/offline setelah aplikasi terpasang.
