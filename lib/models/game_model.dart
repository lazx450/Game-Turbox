import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Model satu game yang terdeteksi di perangkat.
///
/// [packageName], [appName], [icon], [installTimeMillis], [versionName] -> NYATA,
/// diambil dari `PackageManager` via package `device_apps` (API resmi Android,
/// tidak butuh root). Tidak ada data yang direkayasa di sini.
///
/// [lastPlayedMillis] dan [playCountEstimate] -> data ini TIDAK tersedia dari API
/// Android manapun tanpa root/Usage Access khusus. Nilai ini HANYA diisi dari
/// histori yang dicatat sendiri oleh Game Turbo X (mis. saat pengguna menekan
/// "Quick Launch" dari dalam app ini). Jika game belum pernah dibuka lewat
/// Game Turbo X, field ini bernilai null dan UI harus menampilkan
/// "Belum ada data" alih-alih angka palsu.
class GameModel extends Equatable {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final DateTime installDate;
  final String versionName;
  final DateTime? lastPlayed;
  final int? playCount;
  final bool isFavorite;

  const GameModel({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.installDate,
    required this.versionName,
    this.lastPlayed,
    this.playCount,
    this.isFavorite = false,
  });

  GameModel copyWith({
    DateTime? lastPlayed,
    int? playCount,
    bool? isFavorite,
  }) {
    return GameModel(
      packageName: packageName,
      appName: appName,
      icon: icon,
      installDate: installDate,
      versionName: versionName,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props =>
      [packageName, appName, installDate, versionName, lastPlayed, playCount, isFavorite];
}

enum GameSortMode { lastPlayed, mostPlayed, installedDate, favorite, alphabetical }
