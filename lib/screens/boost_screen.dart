import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/glass_card.dart';
import '../providers/boost_providers.dart';
import '../theme/app_colors.dart';

/// Boost Screen — menjalankan [BoostNotifier.runBoost] (nyata) dan menampilkan
/// hasil dengan label tegas "Nyata" / "Estimasi" per item, agar pengguna
/// tidak tertipu dan aplikasi tetap jujur sesuai kebijakan Play Store terkait
/// klaim performa.
class BoostScreen extends ConsumerStatefulWidget {
  const BoostScreen({super.key});

  @override
  ConsumerState<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends ConsumerState<BoostScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boostProvider.notifier).runBoost();
    });
  }

  @override
  Widget build(BuildContext context) {
    final boostState = ref.watch(boostProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Boost Engine')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: switch (boostState.status) {
              BoostStatus.idle || BoostStatus.running => _RunningView(),
              BoostStatus.done => _ResultView(result: boostState.result!),
            },
          ),
        ),
      ),
    );
  }
}

class _RunningView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
          child: const Icon(Icons.bolt_rounded, size: 60, color: Colors.black),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1200.ms),
        const SizedBox(height: 24),
        const Text('Membersihkan cache & menganalisis sistem...',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        const SizedBox(height: 8),
        const Text('Proses ini nyata: cache aplikasi ini benar-benar dibersihkan.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  final dynamic result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 72)
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          const Text('Boost Selesai', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _ResultTile(
            icon: Icons.cleaning_services_rounded,
            title: 'Cache Dibersihkan',
            value: '${result.ownCacheClearedMb} MB',
            tag: 'Nyata',
            tagColor: AppColors.success,
          ),
          _ResultTile(
            icon: Icons.storage_rounded,
            title: 'Storage Bebas Bertambah',
            value: '${result.freeRamAfterMb - result.freeRamBeforeMb} MB',
            tag: 'Nyata',
            tagColor: AppColors.success,
          ),
          _ResultTile(
            icon: Icons.speed_rounded,
            title: 'Estimasi Peningkatan FPS',
            value: '+${result.estimatedFpsImprovementPercent.toStringAsFixed(1)}%',
            tag: 'Estimasi',
            tagColor: AppColors.warning,
          ),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Catatan Transparansi', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(
                  'Android tidak mengizinkan aplikasi biasa menghapus cache aplikasi lain '
                  'atau mematikan proses aplikasi lain tanpa root. Angka "Estimasi FPS" adalah '
                  'perkiraan berdasarkan kondisi sistem, bukan pengukuran FPS game secara langsung.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Selesai'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String tag;
  final Color tagColor;

  const _ResultTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(tag, style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
