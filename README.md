# FileForge

FileForge adalah aplikasi multi-tool file **offline-first** untuk Windows dan Android. Semua pemrosesan media dilakukan lokal di perangkat; file pengguna tidak perlu di-upload ke server.

## Video Toolkit v0.2

Fitur saat ini:

- Video Info via FFprobe
- Compress Video: High Quality / Balanced / Smallest
- Target Size compression berdasarkan batas MB
- WhatsApp preset: 720p, 30 FPS, H.264 + AAC
- Resize Video: 1080p / 720p / 480p
- Trim / Cut berdasarkan start dan end time
- Change FPS: 24 / 30 / 60 FPS
- Extract Audio → MP3
- Convert Video → MP4
- Remove Audio
- Video → GIF
- Progress pemrosesan
- Cancel proses
- FFmpeg log untuk debugging
- Android Storage Access Framework (SAF)
- Windows native file picker/save dialog

## Aplikasi siap pakai

Pengguna akhir **tidak menjalankan BAT, PowerShell, Python, Flutter, atau FFmpeg secara manual**.

### Windows

Download `FileForge-Setup-v0.2.0.exe` dari GitHub Releases lalu jalankan installer. Installer akan:

- memasang FileForge ke Windows,
- membuat shortcut Desktop,
- membuat shortcut Start Menu,
- menyediakan uninstaller,
- menawarkan menjalankan FileForge setelah instalasi selesai.

Versi portable `FileForge-Windows-portable-v0.2.0.zip` juga tersedia.

Target: Windows 10/11 x86-64.

### Android

APK adalah installer native Android. Setelah terpasang, FileForge muncul sebagai aplikasi normal dengan launcher entry `FileForge`.

Minimum Android: API 24 / Android 7.0.

Pilihan APK:

- `FileForge-Android-arm64-v8a-v0.2.0.apk` — direkomendasikan untuk mayoritas HP modern.
- `FileForge-Android-universal-v0.2.0.apk` — kompatibilitas luas, ukuran lebih besar.
- `FileForge-Android-armeabi-v7a-v0.2.0.apk` — ARM 32-bit.
- `FileForge-Android-x86_64-v0.2.0.apk` — x86_64/emulator.

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
- `file_picker`
- Inno Setup untuk installer Windows
- GitHub Actions untuk build dan GitHub Release

## Target-size compression

Target size dihitung dari durasi dan budget bitrate dengan margin aman. Ini dirancang agar hasil cenderung berada di bawah batas yang diminta, tetapi ukuran final dapat sedikit berbeda karena overhead container dan karakteristik video.

## Compression preset

| Preset | CRF | Audio |
|---|---:|---:|
| High Quality | 23 | 160 kbps |
| Balanced | 28 | 128 kbps |
| Smallest | 32 | 96 kbps |

Video dikodekan menggunakan H.264 `libx264`, audio menggunakan AAC.

## Lisensi FFmpeg

FileForge saat ini menggunakan paket FFmpeg Full-GPL karena membutuhkan codec seperti x264. Distribusi publik harus mematuhi kewajiban lisensi dari komponen yang dibundel.

## Roadmap

- Batch queue
- Image Toolkit
- Images → PDF
- PDF Toolkit
- Audio Toolkit
