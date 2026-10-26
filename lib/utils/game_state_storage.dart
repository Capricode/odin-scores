import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../games/game_type.dart';

/// A game in progress as saved by its game screen.
class SavedSession {
  final GameType game;
  final Map<String, dynamic> state;

  const SavedSession(this.game, this.state);
}

/// Persists the game in progress (browser localStorage on web). Only one game
/// is in progress at a time; each game screen defines its own [state] format.
class GameStateStorage {
  static const String _key = 'current_game';

  static Future<SavedSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      // Saves from before multi-game support are Odin state without a wrapper.
      if (!json.containsKey('game')) return SavedSession(GameType.odin, json);
      return SavedSession(
        GameType.fromId(json['game'] as String),
        json['state'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(GameType game, Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({'game': game.id, 'state': state}));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
