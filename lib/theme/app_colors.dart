import 'package:flutter/material.dart';

/// Palet warna resmi Game Turbo X.
/// Semua warna didefinisikan di satu tempat agar konsisten di seluruh app
/// dan mudah diganti saat custom theme premium ditambahkan.
class AppColors {
  AppColors._();

  /// Warna latar utama aplikasi (dark, premium).
  static const Color background = Color(0xFF0B0F19);

  /// Warna dasar untuk card / panel dengan efek glassmorphism.
  static const Color card = Color(0xFF161B26);

  /// Warna utama (hijau neon) untuk aksi utama seperti tombol Boost.
  static const Color primary = Color(0xFF00FF66);

  /// Warna aksen (cyan) untuk elemen sekunder, grafik, highlight.
  static const Color accent = Color(0xFF00E0FF);

  /// Warna teks utama.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Warna teks sekunder (lebih redup, untuk sub-label).
  static const Color textSecondary = Color(0xFFAEB4C2);

  /// Warna border tipis pada card glassmorphism.
  static const Color borderGlass = Color(0x33FFFFFF);

  /// Warna status bahaya / suhu tinggi / peringatan.
  static const Color danger = Color(0xFFFF4757);

  /// Warna status waspada (medium).
  static const Color warning = Color(0xFFFFA500);

  /// Warna status aman / optimal.
  static const Color success = Color(0xFF00FF66);

  /// Gradient utama untuk tombol Boost & elemen hero.
  static const List<Color> primaryGradient = [
    Color(0xFF00FF66),
    Color(0xFF00E0FF),
  ];

  /// Gradient background untuk efek glow di splash / home.
  static const List<Color> glowGradient = [
    Color(0x3300FF66),
    Color(0x0000FF66),
  ];
}
