import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

/// Splash screen: animasi logo + proses pengecekan device NYATA (bukan delay
/// artifisial semata). Selama animasi berjalan, [deviceInfoProvider] benar-benar
/// membaca RAM/CPU/Storage/Android version dari device via API resmi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final List<String> _checks = [
    'Memeriksa RAM...',
    'Memeriksa CPU...',
    'Memeriksa Storage...',
    'Memeriksa Suhu Baterai...',
  ];
  int _currentCheck = 0;

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    // Memicu pembacaan device info NYATA lebih awal agar Home langsung siap.
    final deviceInfoFuture = ref.read(deviceInfoProvider.future);

    for (var i = 0; i < _checks.length; i++) {
      if (!mounted) return;
      setState(() => _currentCheck = i);
      await Future.delayed(const Duration(milliseconds: 450));
    }

    await deviceInfoFuture;
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 50, spreadRadius: 6),
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.black),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  duration: 1200.ms,
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1.06, 1.06),
                ),
            const SizedBox(height: 28),
            const Text(
              'GAME TURBO X',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _checks[_currentCheck],
              key: ValueKey(_currentCheck),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ).animate(key: ValueKey(_currentCheck)).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
