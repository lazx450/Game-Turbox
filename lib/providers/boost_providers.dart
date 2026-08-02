import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boost_result_model.dart';
import '../services/boost_service.dart';
import 'device_providers.dart';

final boostServiceProvider = Provider<BoostService>((ref) => BoostService());

enum BoostStatus { idle, running, done }

class BoostState {
  final BoostStatus status;
  final BoostResultModel? result;
  const BoostState({this.status = BoostStatus.idle, this.result});
}

/// Menjalankan boost NYATA: bersihkan cache sendiri lalu baca ulang storage
/// bebas sebagai bukti perubahan nyata (RAM total Android tidak bisa dibaca
/// "sisa realtime" tanpa akses `/proc/meminfo` yang dibatasi sejak Android 8+
/// untuk app pihak ketiga -- sehingga indikator yang ditampilkan adalah
/// storage bebas sebelum/sesudah, yang 100% terukur nyata).
class BoostNotifier extends StateNotifier<BoostState> {
  final BoostService _boostService;
  final Ref _ref;

  BoostNotifier(this._boostService, this._ref) : super(const BoostState());

  Future<void> runBoost() async {
    state = const BoostState(status: BoostStatus.running);

    final deviceRepo = _ref.read(deviceRepositoryProvider);
    final before = await deviceRepo.fetchDeviceInfo();

    final result = await _boostService.runBoost(
      freeRamBeforeMb: before.freeStorageMb, // storage bebas sebagai proxy terukur
      foregroundRecentApps: const [],
    );

    final after = await deviceRepo.fetchDeviceInfo();

    final finalResult = BoostResultModel(
      ownCacheClearedMb: result.ownCacheClearedMb,
      freeRamBeforeMb: before.freeStorageMb,
      freeRamAfterMb: after.freeStorageMb,
      backgroundAppsSuggestedToClose: result.backgroundAppsSuggestedToClose,
      animationsDisabledSuggested: result.animationsDisabledSuggested,
      networkOptimizationApplied: result.networkOptimizationApplied,
      thermalWarningShown: result.thermalWarningShown,
      estimatedFpsImprovementPercent: result.estimatedFpsImprovementPercent,
      timestamp: result.timestamp,
    );

    state = BoostState(status: BoostStatus.done, result: finalResult);
  }

  void reset() => state = const BoostState();
}

final boostProvider = StateNotifierProvider.autoDispose<BoostNotifier, BoostState>((ref) {
  return BoostNotifier(ref.watch(boostServiceProvider), ref);
});
