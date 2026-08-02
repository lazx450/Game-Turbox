import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ping_history_point.dart';
import '../services/network_service.dart';

final networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());

/// Target host yang di-ping. Default ke server publik stabil (Cloudflare)
/// sebagai representasi kualitas koneksi umum -- pengguna bisa mengganti
/// via Game Profile ke server spesifik game jika diketahui (opsional,
/// lihat GameProfile.pingTargetHost).
final pingTargetHostProvider = StateProvider<String>((ref) => '1.1.1.1');

/// Notifier yang melakukan ping NYATA setiap 2 detik selagi layar
/// Ping Monitor aktif, dan menyimpan histori untuk grafik.
class PingMonitorNotifier extends StateNotifier<List<PingHistoryPoint>> {
  final NetworkService _networkService;
  final String host;
  Timer? _timer;
  static const _maxHistory = 30;

  PingMonitorNotifier(this._networkService, this.host) : super([]) {
    _start();
  }

  void _start() {
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  Future<void> _tick() async {
    final result = await _networkService.pingHost(host);
    final point = PingHistoryPoint(
      time: result.timestamp,
      latencyMs: result.latencyMs,
      success: result.success,
    );
    final updated = [...state, point];
    state = updated.length > _maxHistory ? updated.sublist(updated.length - _maxHistory) : updated;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pingMonitorProvider = StateNotifierProvider.autoDispose<PingMonitorNotifier, List<PingHistoryPoint>>((ref) {
  final service = ref.watch(networkServiceProvider);
  final host = ref.watch(pingTargetHostProvider);
  return PingMonitorNotifier(service, host);
});
