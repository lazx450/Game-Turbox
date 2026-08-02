import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_model.dart';
import '../repository/game_repository.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) => GameRepository());

final gameSortModeProvider = StateProvider<GameSortMode>((ref) => GameSortMode.installedDate);

final gameListProvider = AsyncNotifierProvider<GameListNotifier, List<GameModel>>(
  GameListNotifier.new,
);

class GameListNotifier extends AsyncNotifier<List<GameModel>> {
  @override
  Future<List<GameModel>> build() async {
    final repo = ref.read(gameRepositoryProvider);
    final sortMode = ref.watch(gameSortModeProvider);
    return repo.getAllGames(sortMode: sortMode);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(gameRepositoryProvider);
    final sortMode = ref.read(gameSortModeProvider);
    state = await AsyncValue.guard(() => repo.getAllGames(sortMode: sortMode));
  }

  Future<void> toggleFavorite(String packageName) async {
    final repo = ref.read(gameRepositoryProvider);
    await repo.toggleFavorite(packageName);
    await refresh();
  }

  Future<void> recordLaunch(String packageName) async {
    final repo = ref.read(gameRepositoryProvider);
    await repo.recordLaunch(packageName);
    await refresh();
  }
}
