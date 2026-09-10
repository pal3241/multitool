# FileForge

FileForge adalah aplikasi multi-tool file **offline-first** untuk Windows dan Android. Semua pemrosesan media dilakukan lokal di perangkat; file pengguna tidak perlu di-upload ke server.

## Video Toolkit v0.2.1

Fitur saat ini:

- Video Info via FFprobe
- Compress Video: High Quality / Balanced / Smallest
- Target Size compression berdasarkan batas MB
- WhatsApp preset: 720p, 30 FPS, H.264 + AAC
- Resize Video: 1080p / 720p / 480p
- Trim / Cut berdasarkan start dan end time
- Change FPS: 24 / 30 / 60 FPS
- Batch Compress queue untuk banyak video
- Extract Audio → MP3
- Convert Video → MP4
- Remove Audio
- Video → GIF
- Progress pemrosesan + cancel
- FFmpeg log untuk debugging
- Android Storage Access Framework (SAF)
- Windows native file picker/save dialog

## Batch Compress

Batch Compress memproses antrean secara sequential supaya penggunaan RAM/CPU lebih aman di laptop maupun HP.

- Windows: pilih banyak video, lalu pilih satu folder output.
- Android: pilih banyak video; lokasi output diminta per file agar aplikasi tetap memakai storage model yang aman tanpa meminta izin akses semua file.

## Windows

Download `FileForge-Setup-v0.2.1.exe` dari GitHub Releases lalu jalankan installer. Installer akan memasang aplikasi, membuat shortcut Desktop dan Start Menu, menyediakan uninstaller, dan menawarkan menjalankan FileForge setelah instalasi selesai.

Versi portable juga tersedia.

Target: Windows 10/11 x86-64.

## Android

APK adalah installer native Android. Setelah terpasang, FileForge memiliki launcher entry `FileForge` dan muncul sebagai aplikasi normal di launcher. Minimum Android API 24 / Android 7.0.

Pilihan utama:

- ARM64 APK untuk mayoritas HP modern.
- Universal APK untuk kompatibilitas beberapa ABI.

## Arsitektur

```text
UI → VideoController → VideoEngine → FFmpeg / FFprobe
                 ↘ MediaPickerService
```

Project tetap modular sehingga Image, PDF, Audio, dan tool lain dapat ditambahkan tanpa menumpuk semuanya di satu file.

## Teknologi

- Flutter / Dart
- `ffmpeg_kit_flutter_new` 4.6.2
- FFmpeg 8.1.2 Full-GPL
- `file_picker` 12.2.0
- Inno Setup untuk installer Windows
- GitHub Actions untuk build dan GitHub Release

## Lisensi FFmpeg

FileForge saat ini menggunakan paket FFmpeg Full-GPL karena membutuhkan codec seperti x264. Distribusi publik harus mematuhi kewajiban lisensi dari komponen yang dibundel.

## Roadmap

- Image Toolkit
- Images → PDF
- PDF Toolkit
- Audio Toolkit
