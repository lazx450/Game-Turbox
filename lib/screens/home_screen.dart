import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/glass_card.dart';
import '../components/boost_button.dart';
import '../providers/device_providers.dart';
import '../theme/app_colors.dart';

/// Home screen: menampilkan ringkasan status device NYATA (RAM, storage, versi
/// Android) yang diambil dari [deviceInfoProvider], plus tombol Boost besar.
///
/// Catatan jujur: "FPS realtime" dan "Ping realtime" untuk GAME LAIN tidak bisa
/// ditampilkan di sini karena app ini tidak berjalan di dalam proses game
/// tersebut. Nilai-nilai itu baru bisa diukur lewat FPS HUD (floating overlay,
/// lihat bagian selanjutnya) yang mengukur frame overlay-nya SENDIRI sebagai
/// proxy, atau ping ke server game (lihat NetworkService) -- bukan FPS asli
/// game tersebut, dan ini dijelaskan ke user di dalam HUD.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfoAsync = ref.watch(deviceInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Game Turbo X')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(deviceInfoProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              deviceInfoAsync.when(
                data: (info) => GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${info.manufacturer} ${info.model}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Android ${info.androidVersion} (SDK ${info.sdkInt})',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatChip(
                            label: 'RAM',
                            value: info.totalRamMb > 0 ? '${(info.totalRamMb / 1024).toStringAsFixed(1)} GB' : 'N/A',
                          ),
                          const SizedBox(width: 8),
                          _StatChip(label: 'CPU Core', value: '${info.cpuCoreCount}'),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Storage',
                            value: '${((info.totalStorageMb - info.freeStorageMb) / 1024).toStringAsFixed(1)} / ${(info.totalStorageMb / 1024).toStringAsFixed(1)} GB',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const GlassCard(
                  child: SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                ),
                error: (e, _) => GlassCard(
                  child: Text('Gagal membaca info device: $e', style: const TextStyle(color: AppColors.danger)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: BoostButton(
                  isBoosting: false,
                  onPressed: () {
                    // Navigasi ke alur boost sesungguhnya ditangani di
                    // BoostScreen (bagian berikutnya) yang memanggil
                    // BoostService.runBoost() secara nyata.
                    Navigator.pushNamed(context, '/boost');
                  },
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                onTap: () => Navigator.pushNamed(context, '/ping'),
                child: const Row(
                  children: [
                    Icon(Icons.network_ping_rounded, color: AppColors.accent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Buka Ping Monitor', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Performa & Estimasi',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              deviceInfoAsync.maybeWhen(
                data: (info) => GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Skor Performa', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            Text('${info.performanceScore}/100',
                                style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800)),
                            const Text('* Estimasi heuristik internal, bukan benchmark resmi',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(info.chipsetGuess, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                          const Text('* Perkiraan dari nama hardware', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
