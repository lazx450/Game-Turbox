import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/boost_screen.dart';
import 'screens/ping_monitor_screen.dart';
import 'theme/app_theme.dart';

/// Entry point Game Turbo X.
///
/// Firebase.initializeApp(), MobileAds.instance.initialize(), dan Hive.initFlutter()
/// akan ditambahkan di sini pada bagian selanjutnya (setelah file konfigurasi
/// google-services.json milik Anda ditempatkan di android/app/, karena tanpa
/// kredensial asli, initializeApp() akan gagal saat runtime).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GameTurboXApp()));
}

class GameTurboXApp extends StatelessWidget {
  const GameTurboXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Turbo X',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      routes: {
        '/boost': (_) => const BoostScreen(),
        '/ping': (_) => const PingMonitorScreen(),
      },
    );
  }
}
