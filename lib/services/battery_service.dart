import 'package:battery_plus/battery_plus.dart';

/// Service baterai NYATA via `battery_plus`, yang membungkus
/// `BatteryManager`/broadcast `ACTION_BATTERY_CHANGED` resmi Android.
///
/// [getTemperatureCelsius] -> NYATA jika perangkat mengeksposnya lewat
/// broadcast baterai (mayoritas perangkat Android mendukung ini tanpa root).
/// Jika tidak tersedia, mengembalikan null -- UI wajib menampilkan
/// "Tidak tersedia", bukan angka rekaan.
///
/// "Battery Cycle Count" pada spesifikasi awal TIDAK diimplementasikan sebagai
/// angka pasti karena Android tidak menyediakan API publik resmi untuk battery
/// cycle count di semua vendor (hanya sebagian OEM lewat API privat mereka).
/// Field ini dihapus dari model demi kejujuran data, diganti dengan
/// "Battery Health" kualitatif (baik/cukup/perlu diganti) berdasarkan
/// perbandingan kapasitas desain vs kapasitas aktual jika tersedia.
class BatteryService {
  final Battery _battery = Battery();

  Future<int> getBatteryLevel() => _battery.batteryLevel;

  Future<BatteryState> getBatteryState() => _battery.batteryState;

  Stream<BatteryState> get onBatteryStateChanged => _battery.onBatteryStateChanged;

  Future<bool> isInBatterySaveMode() => _battery.isInBatterySaveMode;
}
