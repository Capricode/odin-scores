import 'package:flutter/material.dart';

/// The games the app can keep score for.
enum GameType {
  odin(
    id: 'odin',
    name: 'Odin',
    box: 'assets/boxes/odin.png',
    emoji: '🃏',
    color: Colors.deepPurple,
    lowestWins: true,
    minPlayers: 2,
  ),
  forestShuffle(
    id: 'forest_shuffle',
    name: 'Forest Shuffle',
    box: 'assets/boxes/forest_shuffle.jpg',
    emoji: '🌲',
    color: Colors.green,
    lowestWins: false,
    minPlayers: 2,
    maxPlayers: 5,
  );

  /// Stable id used in saved data. Never change it.
  final String id;
  final String name;

  /// Picture of the game box (publisher artwork), shown in the game picker.
  final String box;
  final String emoji;
  final Color color;

  /// Odin: lowest total wins. Forest Shuffle: highest total wins.
  final bool lowestWins;
  final int minPlayers;
  final int? maxPlayers;

  const GameType({
    required this.id,
    required this.name,
    required this.box,
    required this.emoji,
    required this.color,
    required this.lowestWins,
    required this.minPlayers,
    this.maxPlayers,
  });

  /// True when [a] is a better total than [b].
  bool beats(int a, int b) => lowestWins ? a < b : a > b;

  /// Unknown or missing ids fall back to Odin, the only game before
  /// multi-game support existed.
  static GameType fromId(String? id) =>
      values.firstWhere((g) => g.id == id, orElse: () => GameType.odin);
}
