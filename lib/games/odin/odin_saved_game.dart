import '../../models/player.dart';

/// One finished round, kept so it can be undone.
class RoundSnapshot {
  final Map<String, int> scores; // Round scores by player id
  final int startPlayerIndex; // Start player for that round
  final int roundNumber;

  RoundSnapshot({
    required this.scores,
    required this.startPlayerIndex,
    required this.roundNumber,
  });

  Map<String, dynamic> toJson() => {'s': scores, 'sp': startPlayerIndex, 'r': roundNumber};

  factory RoundSnapshot.fromJson(Map<String, dynamic> json) => RoundSnapshot(
        scores: (json['s'] as Map).map((k, v) => MapEntry(k as String, v as int)),
        startPlayerIndex: json['sp'] as int,
        roundNumber: json['r'] as int,
      );
}

/// Everything needed to resume an Odin game after the app was closed or
/// crashed.
class SavedGame {
  final List<Player> players;
  final List<Player> leftPlayers;
  final Set<String> leavingIds;
  final Map<String, int?> currentRoundScores;
  final bool gameEnded;
  final int currentRound;
  final int startPlayerIndex;
  final List<RoundSnapshot> roundHistory;

  const SavedGame({
    required this.players,
    required this.leftPlayers,
    required this.leavingIds,
    required this.currentRoundScores,
    required this.gameEnded,
    required this.currentRound,
    required this.startPlayerIndex,
    required this.roundHistory,
  });

  Map<String, dynamic> toJson() => {
        'p': players.map((p) => p.toJson()).toList(),
        'l': leftPlayers.map((p) => p.toJson()).toList(),
        'li': leavingIds.toList(),
        'c': currentRoundScores,
        'e': gameEnded,
        'r': currentRound,
        'sp': startPlayerIndex,
        'h': roundHistory.map((r) => r.toJson()).toList(),
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    List<Player> players(String key) => (json[key] as List)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();
    return SavedGame(
      players: players('p'),
      leftPlayers: players('l'),
      leavingIds: (json['li'] as List).map((e) => e as String).toSet(),
      currentRoundScores:
          (json['c'] as Map).map((k, v) => MapEntry(k as String, v as int?)),
      gameEnded: json['e'] as bool,
      currentRound: json['r'] as int,
      startPlayerIndex: json['sp'] as int,
      roundHistory: (json['h'] as List)
          .map((e) => RoundSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
