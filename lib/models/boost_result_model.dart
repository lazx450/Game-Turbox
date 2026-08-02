import 'package:equatable/equatable.dart';

/// Hasil satu sesi Boost.
///
/// [ownCacheClearedMb] -> NYATA. Android sandbox HANYA mengizinkan sebuah app
/// menghapus direktori cache MILIKNYA SENDIRI (`context.cacheDir`). Game Turbo X
/// tidak bisa dan tidak mencoba menghapus cache app lain tanpa root — itu
/// dilarang oleh sandboxing Android sejak API level rendah.
///
/// [backgroundAppsSuggestedToClose] -> NYATA sebagai DAFTAR SARAN. Sejak Android
/// 5.0 (Lollipop), API `ActivityManager.killBackgroundProcesses()` hanya bisa
/// mematikan proses milik app itu sendiri, bukan app lain. Game Turbo X hanya
/// bisa membaca app mana saja yang sedang "recent" (jika Usage Access diberikan)
/// dan MENYARANKAN pengguna menutupnya manual, atau mengarahkan ke halaman
/// Recent Apps sistem. Tidak ada proses app lain yang benar-benar dimatikan
/// otomatis oleh app ini.
///
/// [animationsDisabledSuggested] -> NYATA sebagai TAUTAN. App ini tidak punya izin
/// mengubah `Settings.Global.WINDOW_ANIMATION_SCALE` (butuh WRITE_SECURE_SETTINGS
/// yang hanya untuk app sistem). Yang dilakukan adalah membuka halaman
/// Developer Options terkait lewat Intent resmi agar pengguna mengaturnya sendiri.
///
/// [estimatedFpsImprovementPercent] -> ESTIMASI. Tidak ada API untuk mengukur FPS
/// game lain secara real, sehingga angka ini adalah heuristik berbasis kondisi
/// RAM/thermal sebelum-sesudah boost, ditandai jelas sebagai estimasi di UI.
class BoostResultModel extends Equatable {
  final int ownCacheClearedMb;
  final int freeRamBeforeMb;
  final int freeRamAfterMb;
  final List<String> backgroundAppsSuggestedToClose;
  final bool animationsDisabledSuggested;
  final bool networkOptimizationApplied;
  final bool thermalWarningShown;
  final double estimatedFpsImprovementPercent;
  final DateTime timestamp;

  const BoostResultModel({
    required this.ownCacheClearedMb,
    required this.freeRamBeforeMb,
    required this.freeRamAfterMb,
    required this.backgroundAppsSuggestedToClose,
    required this.animationsDisabledSuggested,
    required this.networkOptimizationApplied,
    required this.thermalWarningShown,
    required this.estimatedFpsImprovementPercent,
    required this.timestamp,
  });

  int get ramFreedMb => (freeRamAfterMb - freeRamBeforeMb).clamp(0, 1 << 30);

  @override
  List<Object?> get props => [
        ownCacheClearedMb,
        freeRamBeforeMb,
        freeRamAfterMb,
        backgroundAppsSuggestedToClose,
        animationsDisabledSuggested,
        networkOptimizationApplied,
        thermalWarningShown,
        estimatedFpsImprovementPercent,
        timestamp,
      ];
}
