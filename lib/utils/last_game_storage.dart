import 'package:shared_preferences/shared_preferences.dart';

import '../games/game_type.dart';

/// Remembers the game picked on the start screen.
class LastGameStorage {
  static const String _key = 'last_game';

  static Future<GameType> load() async {
    final prefs = await SharedPreferences.getInstance();
    return GameType.fromId(prefs.getString(_key));
  }

  static Future<void> save(GameType game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, game.id);
  }
}
