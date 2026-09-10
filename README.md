# FileForge

FileForge adalah aplikasi multi-tool file **offline-first** untuk Windows dan Android. Semua pemrosesan media dilakukan lokal di perangkat; file pengguna tidak perlu di-upload ke server.(saya miskin jadi tidak ada server)

## Video Toolkit v0.1

Fitur yang sudah tersedia:

- Video Info via FFprobe
- Compress Video: High Quality / Balanced / Smallest
- Extract Audio → MP3
- Convert Video → MP4 (H.264 + AAC)
- Remove Audio
- Video → GIF
- Progress pemrosesan
- Cancel proses
- FFmpeg log untuk debugging
- Android Storage Access Framework (SAF)
- Windows native file picker/save dialog

## Aplikasi siap pakai

Pengguna akhir **tidak menjalankan BAT, PowerShell, Python, Flutter, atau FFmpeg secara manual**.

GitHub Actions otomatis membangun aplikasi setiap ada push ke branch `main`:

- `FileForge-Android` — berisi APK universal dan APK per ABI.
- `FileForge-Windows-x64` — berisi ZIP aplikasi Windows. Ekstrak ZIP lalu jalankan `fileforge.exe`.

> Windows Flutter membutuhkan DLL dan folder `data` di sebelah executable. Karena itu distribusi Windows diberikan sebagai satu ZIP portable, bukan hanya satu file EXE yang dipisahkan dari dependensinya.

## Android

Minimum Android: API 24 (Android 7.0).

Artifact Android berisi:

- `FileForge-Android-universal.apk` — paling mudah dipasang, mendukung beberapa ABI tetapi ukuran lebih besar.
- `FileForge-Android-arm64-v8a.apk` — pilihan utama untuk mayoritas HP Android modern.
- `FileForge-Android-armeabi-v7a.apk` — perangkat ARM 32-bit lama.
- `FileForge-Android-x86_64.apk` — emulator/perangkat x86_64.

## Windows

Target saat ini: Windows 10/11 x86-64.

Setelah mengunduh artifact `FileForge-Windows-x64`:

1. Ekstrak ZIP.
2. Buka folder hasil ekstrak.
3. Jalankan `fileforge.exe`.

Tidak membutuhkan script `.bat` untuk penggunaan aplikasi.

## Arsitektur

```text
lib/
├─ core/
│  ├─ models/
│  └─ services/
├─ features/
│  ├─ home/
│  └─ video/
│     ├─ controllers/
│     ├─ models/
│     ├─ services/
│     └─ widgets/
├─ app.dart
└─ main.dart
```

Alur Video Toolkit:

```text
UI → VideoController → VideoEngine → FFmpeg / FFprobe
                 ↘ MediaPickerService
```

## Teknologi

- Flutter / Dart
- `ffmpeg_kit_flutter_new` 4.6.2
- FFmpeg 8.1.2 Full-GPL
- `file_picker`

FFmpegKit saat ini mendukung Android API 24+ dan Windows 10+ x86-64. Native FFmpeg dibundel ke hasil aplikasi saat proses build, sehingga runtime pemrosesan video berlangsung lokal.

## Compression preset

| Preset | CRF | Audio |
|---|---:|---:|
| High Quality | 23 | 160 kbps |
| Balanced | 28 | 128 kbps |
| Smallest | 32 | 96 kbps |

Video dikodekan menggunakan H.264 `libx264`, audio menggunakan AAC.

## Lisensi FFmpeg

Prototype menggunakan paket FFmpeg Full-GPL karena membutuhkan codec seperti x264. Distribusi publik harus mematuhi kewajiban GPL dari komponen yang dibundel.

## Roadmap

- Target-size compression
- Preset WhatsApp / Discord
- Trim/cut
- Resize 1080p / 720p / 480p
- FPS converter
- Batch queue
- Image Toolkit
- Images → PDF
- PDF Toolkit
- Audio Toolkit
