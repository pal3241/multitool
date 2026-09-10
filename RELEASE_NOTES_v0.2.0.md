# FileForge v0.2.0

FileForge adalah multi-tool offline untuk Windows dan Android. Semua pemrosesan video dilakukan lokal di perangkat menggunakan FFmpeg/FFprobe yang dibundel.

## Video Toolkit v0.2

- Compress Video dengan preset High Quality / Balanced / Smallest
- Target Size compression berdasarkan batas ukuran MB
- WhatsApp preset: 720p, 30 FPS, H.264 + AAC
- Resize Video: 1080p / 720p / 480p
- Trim / Cut berdasarkan waktu mulai dan selesai
- Change FPS: 24 / 30 / 60 FPS
- Extract Audio ke MP3
- Convert ke MP4
- Remove Audio
- Video ke GIF
- Video Info, progress, cancel, dan FFmpeg log

## Windows

Gunakan `FileForge-Setup-v0.2.0.exe` untuk instalasi normal. Installer memasang aplikasi ke Windows, membuat shortcut Desktop dan Start Menu, serta menyediakan uninstaller.

`FileForge-Windows-portable-v0.2.0.zip` disediakan sebagai alternatif portable tanpa instalasi.

## Android

- `FileForge-Android-arm64-v8a-v0.2.0.apk` direkomendasikan untuk mayoritas HP Android modern.
- `FileForge-Android-universal-v0.2.0.apk` kompatibel dengan beberapa ABI tetapi ukurannya lebih besar.
- APK ARM32 dan x86_64 juga tersedia.

Minimum Android: API 24 / Android 7.0.

## Catatan target size

Target-size memakai bitrate budget dengan margin aman untuk mengurangi risiko output melewati ukuran yang diminta. Ukuran final tetap dapat sedikit berbeda karena overhead container dan karakteristik video.
