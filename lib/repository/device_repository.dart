import '../models/device_info_model.dart';
import '../services/device_info_service.dart';

/// Repository sebagai satu pintu akses data device untuk seluruh layer UI.
/// Mengikuti pola MVVM: Repository -> Service -> platform API.
class DeviceRepository {
  final DeviceInfoService _service;

  DeviceRepository({DeviceInfoService? service}) : _service = service ?? DeviceInfoService();

  Future<DeviceInfoModel> fetchDeviceInfo() => _service.getDeviceInfo();
}
