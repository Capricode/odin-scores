import 'package:shared_preferences/shared_preferences.dart';

class NameStorage {
  static const String _key = 'used_player_names';
  static const int _maxEntries = 50;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  static Future<List<String>> save(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? <String>[];

    // Already known (case-insensitive): keep the existing order untouched.
    if (existing.any((entry) => entry.toLowerCase() == trimmed.toLowerCase())) {
      return existing;
    }

    // New names go first.
    existing.insert(0, trimmed);

    // Trim history to a reasonable size.
    if (existing.length > _maxEntries) {
      existing.removeRange(_maxEntries, existing.length);
    }

    await prefs.setStringList(_key, existing);
    return existing;
  }
}
