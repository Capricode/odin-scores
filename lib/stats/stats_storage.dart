import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../games/game_type.dart';
import 'game_record.dart';

/// Persists finished games of all games in one list (browser localStorage on
/// web). All statistics are derived from this list.
class StatsStorage {
  static const String _key = 'game_history';
  static const int _maxGamesPerType = 1000;

  /// Finished games of [game], oldest first.
  static Future<List<GameRecord>> load(GameType game) async =>
      (await _loadAll()).where((g) => g.game == game).toList();

  static Future<void> saveGame(GameRecord record) async {
    final games = await _loadAll();
    games.add(record);
    final ofType = games.where((g) => g.game == record.game).toList();
    if (ofType.length > _maxGamesPerType) {
      final drop = ofType.take(ofType.length - _maxGamesPerType).toSet();
      games.removeWhere(drop.contains);
    }
    await _write(games);
  }

  /// Replaces the saved game of the same type played at the same time as
  /// [record] (after a score correction), or adds it if there is none.
  static Future<void> replaceGame(GameRecord record) async {
    final games = await _loadAll();
    final i = games.indexWhere((g) => g.game == record.game && g.playedAt == record.playedAt);
    if (i == -1) {
      games.add(record);
    } else {
      games[i] = record;
    }
    await _write(games);
  }

  /// Deletes the finished games of [game] only.
  static Future<void> clear(GameType game) async {
    final games = await _loadAll();
    games.removeWhere((g) => g.game == game);
    await _write(games);
  }

  /// Exports the games of all game types.
  static Future<String> exportJson() async {
    final games = await _loadAll();
    return jsonEncode({
      'version': 2,
      'games': games.map((g) => g.toJson()).toList(),
    });
  }

  /// Replaces the stored history of all game types. Version 1 exports only
  /// contain Odin games. Throws [FormatException] on invalid input.
  static Future<int> importJson(String text) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(text.trim());
    } catch (_) {
      throw const FormatException('Not valid JSON');
    }
    if (decoded is! Map || decoded['games'] is! List) {
      throw const FormatException('Not a stats export');
    }
    final games = <GameRecord>[];
    try {
      for (final g in decoded['games'] as List) {
        games.add(GameRecord.fromJson(g as Map<String, dynamic>));
      }
    } catch (_) {
      throw const FormatException('Export data is damaged');
    }
    await _write(games);
    return games.length;
  }

  static Future<List<GameRecord>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(List<GameRecord> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(games.map((g) => g.toJson()).toList()),
    );
  }
}
