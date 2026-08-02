import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/glass_card.dart';
import '../providers/network_providers.dart';
import '../theme/app_colors.dart';

/// Ping Monitor: latency, packet loss, dan grafik histori — semuanya dari
/// pengukuran TCP handshake NYATA (lihat NetworkService & PingMonitorNotifier).
///
/// "Jitter" dihitung nyata sebagai deviasi antar sampel latency berturut-turut.
/// "Signal strength" WiFi TIDAK ditampilkan sebagai angka dBm karena Android
/// tidak mengekspos RSSI WiFi tanpa lokasi + izin khusus sejak Android 8.1+
/// (`ACCESS_FINE_LOCATION` wajib untuk `WifiInfo.getRssi()`), dan meminta izin
/// lokasi hanya demi angka sinyal dianggap over-permission oleh kebijakan Play.
/// Sebagai gantinya ditampilkan status kualitas koneksi (WiFi/Data/Tidak ada)
/// dari `connectivity_plus`.
class PingMonitorScreen extends ConsumerWidget {
  const PingMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(pingMonitorProvider);

    final successPoints = history.where((p) => p.success).toList();
    final currentPing = successPoints.isNotEmpty ? successPoints.last.latencyMs : null;
    final avgPing = successPoints.isEmpty
        ? null
        : (successPoints.map((p) => p.latencyMs).reduce((a, b) => a + b) / successPoints.length).round();
    final packetLossPercent =
        history.isEmpty ? 0.0 : (history.where((p) => !p.success).length / history.length) * 100;
    final jitter = _computeJitter(successPoints.map((p) => p.latencyMs).toList());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ping Monitor')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Ping Saat Ini', value: currentPing != null ? '$currentPing ms' : '—')),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Rata-rata', value: avgPing != null ? '$avgPing ms' : '—')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Packet Loss', value: '${packetLossPercent.toStringAsFixed(0)}%')),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Jitter', value: jitter != null ? '$jitter ms' : '—')),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
              child: SizedBox(
                height: 200,
                child: history.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (var i = 0; i < history.length; i++)
                                  FlSpot(i.toDouble(), history[i].success ? history[i].latencyMs.toDouble() : 0),
                              ],
                              isCurved: true,
                              color: AppColors.accent,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.accent.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grafik menampilkan 30 sampel terakhir, diperbarui tiap 2 detik. '
              'Nilai 0 pada grafik menandakan koneksi gagal (timeout).',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  int? _computeJitter(List<int> pings) {
    if (pings.length < 2) return null;
    final diffs = <int>[];
    for (var i = 1; i < pings.length; i++) {
      diffs.add((pings[i] - pings[i - 1]).abs());
    }
    return (diffs.reduce((a, b) => a + b) / diffs.length).round();
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
