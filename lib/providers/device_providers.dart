import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_info_model.dart';
import '../repository/device_repository.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) => DeviceRepository());

/// State device info yang di-refresh berkala (dipakai Home & Device Analyzer).
final deviceInfoProvider = AsyncNotifierProvider<DeviceInfoNotifier, DeviceInfoModel>(
  DeviceInfoNotifier.new,
);

class DeviceInfoNotifier extends AsyncNotifier<DeviceInfoModel> {
  @override
  Future<DeviceInfoModel> build() async {
    final repo = ref.read(deviceRepositoryProvider);
    return repo.fetchDeviceInfo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(deviceRepositoryProvider);
    state = await AsyncValue.guard(() => repo.fetchDeviceInfo());
  }
}
