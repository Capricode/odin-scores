import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/game_type.dart';
import 'package:odin_score_keeper/stats/game_record.dart';
import 'package:odin_score_keeper/stats/stats_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameRecord record(GameType game, int day) => GameRecord(
      game: game,
      playedAt: DateTime(2026, 1, day),
      players: const [PlayerResult(name: 'A', scores: [1])],
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('each game sees and resets only its own history', () async {
    await StatsStorage.saveGame(record(GameType.odin, 1));
    await StatsStorage.saveGame(record(GameType.forestShuffle, 2));
    expect((await StatsStorage.load(GameType.odin)).length, 1);
    expect((await StatsStorage.load(GameType.forestShuffle)).length, 1);

    await StatsStorage.clear(GameType.odin);
    expect(await StatsStorage.load(GameType.odin), isEmpty);
    expect((await StatsStorage.load(GameType.forestShuffle)).length, 1);
  });

  test('export covers all games and a version 1 export imports as Odin', () async {
    await StatsStorage.saveGame(record(GameType.odin, 1));
    await StatsStorage.saveGame(record(GameType.forestShuffle, 2));
    final export = jsonDecode(await StatsStorage.exportJson()) as Map;
    expect((export['games'] as List).length, 2);

    final v1 = jsonEncode({
      'version': 1,
      'games': [record(GameType.odin, 3).toJson()..remove('g')],
    });
    expect(await StatsStorage.importJson(v1), 1);
    expect((await StatsStorage.load(GameType.odin)).length, 1);
    expect(await StatsStorage.load(GameType.forestShuffle), isEmpty);
  });
}
