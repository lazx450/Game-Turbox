import 'package:equatable/equatable.dart';

/// Model hasil analisis perangkat.
///
/// PENTING soal keaslian data (agar transparan ke pengguna & lolos review Play Store):
/// - [androidVersion], [sdkInt], [manufacturer], [model], [board], [hardware],
///   [supportedAbis], [isPhysicalDevice] -> NYATA, diambil dari `device_info_plus`
///   (membaca `android.os.Build` resmi). Tidak ada estimasi di sini.
/// - [totalRamMb] -> NYATA, dari `ActivityManager.MemoryInfo.totalMem` (API resmi).
/// - [totalStorageMb] / [freeStorageMb] -> NYATA, dari `StatFs` via `disk_space_plus`.
/// - [cpuCoreCount] -> NYATA, dari `Runtime.getRuntime().availableProcessors()`.
/// - [chipsetGuess] -> ESTIMASI. Android tidak menyediakan API publik resmi untuk
///   nama chipset/GPU. Nilai ini disimpulkan dari `hardware`/`board` string dan
///   ditandai jelas di UI sebagai "perkiraan", bukan fakta terverifikasi.
/// - [performanceScore] -> ESTIMASI/HEURISTIK internal aplikasi berdasarkan RAM,
///   jumlah core, dan versi Android. Bukan benchmark resmi pihak ketiga.
class DeviceInfoModel extends Equatable {
  final String manufacturer;
  final String model;
  final String board;
  final String hardware;
  final String androidVersion;
  final int sdkInt;
  final List<String> supportedAbis;
  final bool isPhysicalDevice;
  final int totalRamMb;
  final int cpuCoreCount;
  final int totalStorageMb;
  final int freeStorageMb;
  final String chipsetGuess;
  final bool chipsetIsEstimate;
  final int performanceScore;
  final bool performanceScoreIsEstimate;

  const DeviceInfoModel({
    required this.manufacturer,
    required this.model,
    required this.board,
    required this.hardware,
    required this.androidVersion,
    required this.sdkInt,
    required this.supportedAbis,
    required this.isPhysicalDevice,
    required this.totalRamMb,
    required this.cpuCoreCount,
    required this.totalStorageMb,
    required this.freeStorageMb,
    required this.chipsetGuess,
    this.chipsetIsEstimate = true,
    required this.performanceScore,
    this.performanceScoreIsEstimate = true,
  });

  double get storageUsedPercent =>
      totalStorageMb == 0 ? 0 : (totalStorageMb - freeStorageMb) / totalStorageMb;

  @override
  List<Object?> get props => [
        manufacturer,
        model,
        board,
        hardware,
        androidVersion,
        sdkInt,
        supportedAbis,
        isPhysicalDevice,
        totalRamMb,
        cpuCoreCount,
        totalStorageMb,
        freeStorageMb,
        chipsetGuess,
        performanceScore,
      ];
}
