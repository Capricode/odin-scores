import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_record.dart';

/// Persists finished games (browser localStorage on web). All statistics are
/// derived from this list.
class StatsStorage {
  static const String _key = 'game_history';
  static const int _maxGames = 1000;

  static Future<List<GameRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return _decode(raw);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveGame(GameRecord game) async {
    final games = await load();
    games.add(game);
    if (games.length > _maxGames) {
      games.removeRange(0, games.length - _maxGames);
    }
    await _write(games);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<String> exportJson() async {
    final games = await load();
    return jsonEncode({
      'version': 1,
      'games': games.map((g) => g.toJson()).toList(),
    });
  }

  /// Replaces the stored history. Throws [FormatException] on invalid input.
  static Future<int> importJson(String text) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(text.trim());
    } catch (_) {
      throw const FormatException('Not valid JSON');
    }
    if (decoded is! Map || decoded['games'] is! List) {
      throw const FormatException('Not an Odin stats export');
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

  static List<GameRecord> _decode(String raw) => (jsonDecode(raw) as List)
      .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
      .toList();

  static Future<void> _write(List<GameRecord> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(games.map((g) => g.toJson()).toList()),
    );
  }
}
