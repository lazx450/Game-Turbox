import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import '../models/device_info_model.dart';

/// Service yang membaca informasi perangkat NYATA melalui API resmi Android.
///
/// Tidak ada root, tidak ada API privat. Semua sumber data:
/// - `device_info_plus` -> membungkus `android.os.Build` (resmi, publik).
/// - `disk_space_plus`  -> membungkus `StatFs` (resmi, publik).
/// - `Platform.numberOfProcessors` -> jumlah core CPU yang terlihat oleh Dart VM,
///   setara `Runtime.getRuntime().availableProcessors()` di Android (resmi).
///
/// RAM total dihitung dari `ActivityManager.MemoryInfo` yang diekspos oleh
/// `device_info_plus` versi terbaru (AndroidDeviceInfo.systemFeatures tidak
/// menyediakan RAM, sehingga estimasi RAM total di implementasi ini datang dari
/// physicalRamSize channel bawaan plugin; jika plugin tidak menyediakannya pada
/// versi tertentu, nilai fallback 0 ditampilkan sebagai "tidak tersedia", BUKAN
/// angka rekaan).
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final DiskSpacePlus _diskSpace = DiskSpacePlus();

  Future<DeviceInfoModel> getDeviceInfo() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Game Turbo X hanya mendukung Android.');
    }

    final androidInfo = await _deviceInfoPlugin.androidInfo;

    final totalStorageMb = ((await _diskSpace.getTotalDiskSpace) ?? 0).round();
    final freeStorageMb = ((await _diskSpace.getFreeDiskSpace) ?? 0).round();

    final cpuCoreCount = Platform.numberOfProcessors;

    // RAM total: device_info_plus mengekspos physicalRamSize di beberapa versi.
    // Jika tidak tersedia pada perangkat/plugin versi tertentu, fallback ke 0
    // dan UI wajib menampilkan "Tidak tersedia" -- bukan mengarang angka.
    final int totalRamMb = _extractRamMbSafely(androidInfo);

    final chipsetGuess = _guessChipset(androidInfo.hardware, androidInfo.board);

    final performanceScore = _computeHeuristicScore(
      ramMb: totalRamMb,
      cores: cpuCoreCount,
      sdkInt: androidInfo.version.sdkInt,
    );

    return DeviceInfoModel(
      manufacturer: androidInfo.manufacturer,
      model: androidInfo.model,
      board: androidInfo.board,
      hardware: androidInfo.hardware,
      androidVersion: androidInfo.version.release,
      sdkInt: androidInfo.version.sdkInt,
      supportedAbis: androidInfo.supportedAbis,
      isPhysicalDevice: androidInfo.isPhysicalDevice,
      totalRamMb: totalRamMb,
      cpuCoreCount: cpuCoreCount,
      totalStorageMb: totalStorageMb,
      freeStorageMb: freeStorageMb,
      chipsetGuess: chipsetGuess,
      chipsetIsEstimate: true,
      performanceScore: performanceScore,
      performanceScoreIsEstimate: true,
    );
  }

  int _extractRamMbSafely(AndroidDeviceInfo info) {
    // Sebagian versi device_info_plus tidak mengekspos RAM fisik langsung.
    // Nilai ini diisi 0 secara sengaja jika tidak dapat dibaca -- UI harus
    // menampilkan "Tidak tersedia", bukan angka default yang menyesatkan.
    try {
      // ignore: avoid_dynamic_calls
      final dynamic dyn = info;
      final dynamic ram = dyn.physicalRamSize;
      if (ram is int) return ram;
    } catch (_) {
      // Properti tidak ada pada versi plugin ini -> fallback aman.
    }
    return 0;
  }

  /// ESTIMASI nama chipset dari string hardware/board.
  /// Android tidak punya API publik resmi untuk nama chipset/GPU,
  /// sehingga ini murni heuristik string matching dan HARUS ditandai
  /// sebagai perkiraan di UI (lihat [DeviceInfoModel.chipsetIsEstimate]).
  String _guessChipset(String hardware, String board) {
    final combined = '$hardware $board'.toLowerCase();
    if (combined.contains('qcom') || combined.contains('sm8') || combined.contains('kona')) {
      return 'Qualcomm Snapdragon (perkiraan)';
    }
    if (combined.contains('exynos')) return 'Samsung Exynos (perkiraan)';
    if (combined.contains('mt') || combined.contains('mediatek')) {
      return 'MediaTek (perkiraan)';
    }
    if (combined.contains('kirin')) return 'HiSilicon Kirin (perkiraan)';
    return 'Tidak diketahui';
  }

  /// Skor performa 0-100. HEURISTIK internal, bukan hasil benchmark resmi.
  int _computeHeuristicScore({required int ramMb, required int cores, required int sdkInt}) {
    double score = 0;
    score += (ramMb / 8192).clamp(0, 1) * 45; // bobot RAM
    score += (cores / 8).clamp(0, 1) * 35; // bobot jumlah core
    score += (sdkInt / 34).clamp(0, 1) * 20; // bobot versi Android
    return score.clamp(0, 100).round();
  }
}
