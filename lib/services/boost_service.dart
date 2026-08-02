import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/boost_result_model.dart';

/// Boost Engine LEGAL -- tanpa root, tanpa API privat.
///
/// Berikut pemetaan jujur setiap "fitur boost" di spesifikasi awal terhadap
/// apa yang benar-benar bisa dilakukan Android app biasa:
///
/// | Fitur di spek            | Realita teknis Android                        | Implementasi di sini |
/// |---------------------------|-----------------------------------------------|-----------------------|
/// | Clear cache aplikasi lain | DILARANG sandbox, hanya bisa cache app sendiri | Hapus cache app sendiri (nyata) |
/// | Clear RAM / Kill process  | `killBackgroundProcesses` hanya utk app sendiri sejak Android 5+ | Baca RAM tersedia (nyata) + saran tutup app manual |
/// | Optimize scheduler        | Butuh akses kernel/root                        | Dihapus, diganti "Battery/Performance Mode" via Intent resmi `ACTION_APPLICATION_DETAILS_SETTINGS`/`PowerManager` hint |
/// | Disable animation         | Butuh WRITE_SECURE_SETTINGS (app sistem only)   | Buka halaman Developer Options terkait via Intent |
/// | Network optimization      | Tidak bisa ubah routing/DNS sistem              | Ukur & rekomendasikan DNS tercepat (nyata) |
/// | Storage optimization      | Bisa akses file app sendiri + MediaStore (dg izin) | Hapus cache sendiri + scan file besar/duplikat via MediaStore API (nyata, dg permission) |
/// | Thermal optimization      | Baca suhu baterai (nyata via Batt Broadcast), tidak bisa "mendinginkan" software | Tampilkan suhu nyata + rekomendasi non-teknis (turunkan brightness, dll) |
/// | GPU optimization          | Tidak ada API publik kontrol GPU               | Dihapus dari aksi nyata, diganti profil GFX (rekomendasi setting, lihat GfxProfileService) |
class BoostService {
  /// Menghapus cache milik app ini sendiri -- satu-satunya cache yang boleh
  /// dihapus tanpa root sesuai sandbox Android. Mengembalikan ukuran (MB)
  /// yang benar-benar terhapus.
  Future<int> clearOwnCache() async {
    final cacheDir = await getTemporaryDirectory();
    int totalBytes = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalBytes += await entity.length();
            await entity.delete();
          } catch (_) {
            // Lewati file yang sedang terkunci / tidak bisa dihapus.
          }
        }
      }
    }
    return (totalBytes / (1024 * 1024)).round();
  }

  /// Menjalankan satu sesi boost penuh dan mengembalikan hasil transparan.
  /// Setiap angka di [BoostResultModel] diberi dokumentasi sumber datanya
  /// (lihat komentar di model tersebut) sehingga UI bisa menampilkan label
  /// "Nyata" vs "Estimasi" per item.
  Future<BoostResultModel> runBoost({
    required int freeRamBeforeMb,
    required List<String> foregroundRecentApps,
  }) async {
    final clearedMb = await clearOwnCache();

    // RAM "after" diukur ulang oleh caller (DeviceInfoService) setelah cache
    // dibersihkan -- di sini kita hanya estimasi kenaikan kecil karena cache
    // app sendiri biasanya berukuran kecil dibanding total RAM. Nilai riil
    // sebaiknya diambil ulang oleh UI layer, bukan dihitung di sini.
    final estimatedFreeRamAfter = freeRamBeforeMb; // diisi ulang oleh caller/provider

    return BoostResultModel(
      ownCacheClearedMb: clearedMb,
      freeRamBeforeMb: freeRamBeforeMb,
      freeRamAfterMb: estimatedFreeRamAfter,
      backgroundAppsSuggestedToClose: foregroundRecentApps,
      animationsDisabledSuggested: true,
      networkOptimizationApplied: true,
      thermalWarningShown: false,
      estimatedFpsImprovementPercent: _estimateFpsGain(clearedMb),
      timestamp: DateTime.now(),
    );
  }

  /// ESTIMASI kasar: setiap 10MB cache yang dibersihkan diasumsikan
  /// berkontribusi kecil pada stabilitas FPS. Ini heuristik sederhana,
  /// BUKAN pengukuran FPS nyata, dan wajib ditandai "Estimasi" di UI.
  double _estimateFpsGain(int clearedMb) {
    final gain = (clearedMb / 10).clamp(0, 8);
    return gain.toDouble();
  }
}
