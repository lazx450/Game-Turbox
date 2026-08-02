import 'dart:io';
import 'package:device_apps/device_apps.dart';
import '../models/game_model.dart';

/// Service deteksi game terinstal.
///
/// NYATA: menggunakan `device_apps` yang membungkus `PackageManager` resmi
/// Android (`getInstalledApplications` + `ApplicationInfo.category ==
/// CATEGORY_GAME` untuk Android 8+, dengan fallback heuristik nama package
/// untuk Android < 8 yang belum punya field kategori). Ini API publik biasa,
/// tidak butuh root maupun izin berbahaya (`QUERY_ALL_PACKAGES` dideklarasikan
/// di manifest sesuai kebijakan Play Store untuk app booster/launcher).
///
/// TIDAK NYATA / TIDAK TERSEDIA tanpa root atau izin khusus:
/// - "Last Played" per game dari sistem -> Android tidak mengekspos ini lewat
///   PackageManager. Yang tersedia hanya lewat `UsageStatsManager` yang butuh
///   izin `PACKAGE_USAGE_STATS` (izin khusus, harus diaktifkan manual oleh user
///   di Settings). Service ini menyediakan method terpisah
///   [getUsageStatsIfGranted] yang HANYA mengembalikan data jika user benar-benar
///   memberi izin tsb -- tidak pernah mengarang data pemakaian.
class GameDetectorService {
  /// Daftar prefix/kata kunci package yang umum dipakai game populer,
  /// dipakai sebagai fallback klasifikasi di Android < 8 (belum ada
  /// ApplicationInfo.category).
  static const _knownGameKeywords = [
    'pubg',
    'freefire',
    'mobilelegends',
    'callofduty',
    'codm',
    'genshin',
    'bloodstrike',
    'honorofkings',
    'deltaforce',
    'standoff',
    'roblox',
    'minecraft',
    'game',
  ];

  Future<List<GameModel>> scanInstalledGames() async {
    if (!Platform.isAndroid) return [];

    final apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );

    final games = apps.where(_isLikelyGame).toList();

    return games.map((app) {
      final withIcon = app is ApplicationWithIcon ? app : null;
      return GameModel(
        packageName: app.packageName,
        appName: app.appName,
        icon: withIcon?.icon,
        installDate: DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis),
        versionName: app.versionName ?? 'N/A',
      );
    }).toList();
  }

  bool _isLikelyGame(Application app) {
    // Android 8+ menyediakan category resmi -> sumber paling akurat.
    if (app.category == ApplicationCategory.game) return true;

    // Fallback untuk Android < 8: cocokkan nama package/app dengan keyword
    // game populer. Ini heuristik, bisa false negative untuk game niche,
    // sehingga app juga menyediakan opsi "Tambah manual ke daftar game"
    // di UI (lihat ManualGameEntryDialog) agar user tetap bisa menambah game
    // yang tidak terdeteksi otomatis.
    final name = '${app.packageName} ${app.appName}'.toLowerCase();
    return _knownGameKeywords.any(name.contains);
  }

  /// Mengembalikan histori penggunaan NYATA hanya jika user sudah memberi izin
  /// "Usage Access" (PACKAGE_USAGE_STATS) secara manual lewat Settings.
  /// Mengembalikan null jika izin belum diberikan -- tidak pernah mengarang data.
  Future<Map<String, DateTime>?> getUsageStatsIfGranted() async {
    // Implementasi penuh membutuhkan MethodChannel native ke UsageStatsManager
    // karena tidak ada plugin resmi yang stabil untuk ini. Placeholder method
    // channel disiapkan di `android/.../UsageStatsHandler.kt` (lihat bagian
    // native selanjutnya) -- method ini akan diisi saat bagian native code
    // dikerjakan, dan SELALU mengembalikan null sebelum izin diberikan user.
    return null;
  }
}
