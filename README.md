# Game Turbo X — Status Project

## Progres saat ini (Part 1 dari rencana bertahap)

Selesai dan **nyata/fungsional** (bukan dummy):
- [x] Struktur project Flutter (models / services / repository / providers / screens / theme / components)
- [x] `pubspec.yaml` dengan seluruh dependency asli yang akan dipakai
- [x] Tema Material 3 (warna, radius 20dp, shadow) sesuai spesifikasi desain
- [x] `DeviceInfoService` — baca RAM, CPU core, storage, versi Android **nyata** via `device_info_plus` & `disk_space_plus`
- [x] `GameDetectorService` — scan game terinstal **nyata** via `PackageManager` (`device_apps`)
- [x] `NetworkService` — ping/latency **nyata** via TCP socket, WiFi info nyata
- [x] `BoostService` — clear cache app sendiri **nyata**; aksi yang tidak legal tanpa root sudah **dihapus/diganti** rekomendasi
- [x] `BatteryService` — level & state baterai nyata
- [x] Splash Screen + Home Screen (fungsional, terhubung ke provider Riverpod nyata)
- [x] `AndroidManifest.xml` — hanya berisi izin yang benar-benar dipakai fitur nyata
- [x] Gradle project (Kotlin DSL) siap dibuka Android Studio

## Batasan teknis yang WAJIB Anda ketahui (kejujuran data)

Beberapa fitur di spesifikasi awal **secara teknis tidak mungkin** dilakukan app Android biasa (non-root, tanpa API privat), dan sudah diganti pendekatan legal:

| Fitur diminta | Kenapa tidak bisa nyata | Diganti dengan |
|---|---|---|
| Clear cache app lain | Sandbox Android melarang | Clear cache app sendiri (nyata) |
| Kill background process app lain | API `killBackgroundProcesses` sejak Android 5+ hanya untuk app sendiri | Saran/daftar app aktif untuk ditutup manual |
| Ubah CPU governor / GPU clock | Butuh akses kernel/root | Dihapus total dari kode |
| Disable animasi sistem | Butuh `WRITE_SECURE_SETTINGS` (app sistem only) | Buka halaman Developer Options via Intent resmi |
| Ubah GFX internal game lain | Tidak ada API publik | Diganti "GFX Profile" — rekomendasi setting yang disimpan lokal, bukan injeksi ke game |
| FPS realtime game lain | App lain berjalan di proses terpisah | FPS HUD mengukur overlay-nya sendiri sebagai estimasi + panduan |
| Battery cycle count | Tidak ada API publik lintas vendor | Diganti "Battery Health" kualitatif |
| Last Played / Most Played dari sistem | Butuh `PACKAGE_USAGE_STATS` (izin manual user) | Dicatat sendiri saat user pakai Quick Launch di app ini |

Semua ini didokumentasikan langsung di komentar kode masing-masing file agar tim developer Anda tahu persis apa yang nyata vs estimasi.

## Yang BELUM dikerjakan (menyusul di pesan berikutnya, otomatis tanpa saya tanya lagi)

- Boost Screen (UI hasil boost) + FPS HUD floating overlay
- Ping Monitor screen + grafik realtime (fl_chart)
- Device Analyzer screen lengkap + skor detail
- GFX Tool (editor profil grafis per game)
- Game Profile per game (PUBG, FF, ML, dst) + penyimpanan Hive
- Firebase integration penuh (Auth, Firestore, Remote Config, Crashlytics, Analytics) — kode sudah siap pola pemanggilannya, tinggal Anda pasang `google-services.json` asli
- AdMob (Banner/Interstitial/Rewarded/Native) dengan test ID lalu placeholder untuk ID asli Anda
- Google Play Billing (Premium)
- Storage Cleaner, Duplicate Finder, Screenshot/Video Manager, APK Analyzer, Notification Cleaner (via MediaStore API, legal)
- Widget Home Screen (App Widget native)
- Native MethodChannel (Kotlin) untuk UsageStatsManager & Overlay Window
- Testing (unit + widget test) & debugging pass
- Launcher icon set & asset final

## Cara membuka & build (di komputer Anda, bukan di sandbox ini)

Sandbox saya **tidak punya akses internet**, jadi saya tidak bisa menjalankan `flutter pub get` atau build APK di sini. Langkah di komputer Anda:

```bash
flutter create --platforms=android . --project-name game_turbo_x  # (opsional, lihat catatan di bawah)
flutter pub get
flutter run
```

**Catatan:** karena `flutter create` biasanya menimpa folder `android/`, project ini sudah menyertakan folder `android/` versi final secara manual — cukup jalankan `flutter pub get` lalu `flutter run` atau buka langsung di Android Studio (File → Open → pilih folder `game_turbo_x`). Pastikan Anda sudah punya Flutter SDK & Android SDK terpasang, lalu salin `android/local.properties.example` menjadi `android/local.properties` dan isi path SDK Anda.

Untuk build rilis, tambahkan `key.properties` + signing config Anda sendiri di `android/app/build.gradle.kts` (bagian `buildTypes.release.signingConfig` saat ini masih pakai debug signing sebagai placeholder yang jelas ditandai TODO).
