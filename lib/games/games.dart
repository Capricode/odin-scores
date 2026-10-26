import 'package:flutter/material.dart';

import '../models/player.dart';
import '../stats/game_record.dart';
import '../stats/stats_calculator.dart';
import '../utils/game_state_storage.dart';
import 'forest_shuffle/forest_shuffle_screen.dart';
import 'forest_shuffle/forest_shuffle_stats.dart';
import 'game_type.dart';
import 'odin/odin_game_screen.dart';
import 'odin/odin_saved_game.dart';
import 'odin/odin_stats.dart';

/// Connects each [GameType] to its screens and game-specific statistics.

Widget gameScreen(GameType game, List<Player> players) => switch (game) {
      GameType.odin => OdinGameScreen(initialPlayers: players),
      GameType.forestShuffle => ForestShuffleScreen(initialPlayers: players),
    };

/// The screen for a game that was in progress when the app closed, or null
/// when the saved state can't be used.
Widget? resumeScreen(SavedSession session) {
  try {
    switch (session.game) {
      case GameType.odin:
        final saved = SavedGame.fromJson(session.state);
        return saved.players.length < 2 ? null : OdinGameScreen(savedGame: saved);
      case GameType.forestShuffle:
        final saved = ForestShuffleSavedGame.fromJson(session.state);
        return saved.players.length < 2
            ? null
            : ForestShuffleScreen(savedGame: saved);
    }
  } catch (_) {
    return null;
  }
}

List<RecordLine> recordLines(GameType game, List<GameRecord> games) =>
    switch (game) {
      GameType.odin => OdinStats.recordLines(games),
      GameType.forestShuffle => ForestShuffleStats.recordLines(games),
    };
