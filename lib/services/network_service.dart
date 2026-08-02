import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Hasil satu pengukuran ping NYATA (bukan simulasi).
class PingResult {
  final int latencyMs;
  final bool success;
  final DateTime timestamp;
  const PingResult({required this.latencyMs, required this.success, required this.timestamp});
}

/// Service jaringan NYATA.
///
/// [pingHost] mengukur latency sungguhan dengan membuka TCP socket ke host
/// tujuan (port 443) dan menghitung waktu tempuh -- ini pendekatan legal yang
/// dipakai banyak app karena Android app biasa (non-root) tidak diizinkan
/// mengirim raw ICMP echo request (butuh CAP_NET_RAW / root). Hasilnya adalah
/// latency TCP handshake nyata, secara praktik sangat mendekati ping ICMP.
///
/// [getWifiInfo] & [getConnectivityType] -> NYATA, dari `network_info_plus`
/// dan `connectivity_plus` (API resmi Android `ConnectivityManager`/`WifiManager`).
///
/// TIDAK diimplementasikan: mengubah DNS sistem atau routing table -- ini
/// butuh hak admin/VPN service. Sebagai gantinya, "DNS Optimizer" pada app ini
/// hanya MENGUKUR latency ke beberapa DNS publik (Cloudflare, Google, dst) dan
/// MEREKOMENDASIKAN yang tercepat, lalu memberi instruksi cara menggantinya
/// manual di Settings WiFi -- app ini tidak mengubah DNS device secara diam-diam.
class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();

  Future<PingResult> pingHost(String host, {int port = 443, Duration timeout = const Duration(seconds: 2)}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      stopwatch.stop();
      socket.destroy();
      return PingResult(latencyMs: stopwatch.elapsedMilliseconds, success: true, timestamp: DateTime.now());
    } catch (_) {
      stopwatch.stop();
      return PingResult(latencyMs: -1, success: false, timestamp: DateTime.now());
    }
  }

  /// Mengukur latency ke beberapa DNS publik dan mengurutkan dari tercepat.
  /// Data NYATA (bukan estimasi) -- hasil pengukuran TCP handshake langsung.
  Future<List<MapEntry<String, int>>> measureDnsLatencies() async {
    const dnsServers = {
      'Cloudflare (1.1.1.1)': '1.1.1.1',
      'Google (8.8.8.8)': '8.8.8.8',
      'Quad9 (9.9.9.9)': '9.9.9.9',
    };
    final results = <MapEntry<String, int>>[];
    for (final entry in dnsServers.entries) {
      final ping = await pingHost(entry.value, port: 53);
      results.add(MapEntry(entry.key, ping.success ? ping.latencyMs : 9999));
    }
    results.sort((a, b) => a.value.compareTo(b.value));
    return results;
  }

  Future<String?> getWifiName() => _networkInfo.getWifiName();

  Future<String?> getWifiIp() => _networkInfo.getWifiIP();

  Future<ConnectivityResult> getConnectivityType() async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty ? result.first : ConnectivityResult.none;
  }
}
