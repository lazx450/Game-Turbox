import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../services/game_detector_service.dart';

/// Repository game: menggabungkan hasil scan nyata dari [GameDetectorService]
/// dengan data lokal (favorit, histori Quick Launch) yang disimpan di
/// SharedPreferences -- data lokal ini NYATA (tersimpan di device), bukan
/// data sistem yang dipalsukan.
class GameRepository {
  final GameDetectorService _detector;
  static const _favoritesKey = 'favorite_games';
  static const _lastPlayedPrefix = 'last_played_';
  static const _playCountPrefix = 'play_count_';

  GameRepository({GameDetectorService? detector}) : _detector = detector ?? GameDetectorService();

  Future<List<GameModel>> getAllGames({GameSortMode sortMode = GameSortMode.installedDate}) async {
    final games = await _detector.scanInstalledGames();
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    final enriched = games.map((g) {
      final lastPlayedMillis = prefs.getInt('$_lastPlayedPrefix${g.packageName}');
      final playCount = prefs.getInt('$_playCountPrefix${g.packageName}');
      return g.copyWith(
        lastPlayed: lastPlayedMillis != null ? DateTime.fromMillisecondsSinceEpoch(lastPlayedMillis) : null,
        playCount: playCount,
        isFavorite: favorites.contains(g.packageName),
      );
    }).toList();

    return _sort(enriched, sortMode);
  }

  List<GameModel> _sort(List<GameModel> games, GameSortMode mode) {
    final list = [...games];
    switch (mode) {
      case GameSortMode.lastPlayed:
        list.sort((a, b) => (b.lastPlayed ?? DateTime(0)).compareTo(a.lastPlayed ?? DateTime(0)));
        break;
      case GameSortMode.mostPlayed:
        list.sort((a, b) => (b.playCount ?? 0).compareTo(a.playCount ?? 0));
        break;
      case GameSortMode.installedDate:
        list.sort((a, b) => b.installDate.compareTo(a.installDate));
        break;
      case GameSortMode.favorite:
        list.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
        break;
      case GameSortMode.alphabetical:
        list.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
        break;
    }
    return list;
  }

  /// Dipanggil saat pengguna menekan "Quick Launch" dari dalam Game Turbo X.
  /// Ini SATU-SATUNYA cara app ini mengetahui "terakhir dimain" secara legal,
  /// karena tidak membaca UsageStatsManager sistem.
  Future<void> recordLaunch(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final key = '$_lastPlayedPrefix$packageName';
    final countKey = '$_playCountPrefix$packageName';
    await prefs.setInt(key, now);
    await prefs.setInt(countKey, (prefs.getInt(countKey) ?? 0) + 1);
  }

  Future<void> toggleFavorite(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (favorites.contains(packageName)) {
      favorites.remove(packageName);
    } else {
      favorites.add(packageName);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }
}
