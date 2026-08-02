/// Satu titik data ping untuk ditampilkan di grafik histori.
/// Semua nilai NYATA — hasil pengukuran TCP handshake langsung
/// (lihat NetworkService.pingHost), bukan simulasi angka acak.
class PingHistoryPoint {
  final DateTime time;
  final int latencyMs;
  final bool success;

  const PingHistoryPoint({required this.time, required this.latencyMs, required this.success});
}
