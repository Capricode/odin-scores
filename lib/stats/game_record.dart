/// Case-insensitive identity used to recognise a player across games.
String nameKey(String name) => name.trim().toLowerCase();

class PlayerResult {
  final String name;

  /// One entry per round the player took part in (index 0 = round 1).
  final List<int> scores;

  /// True when the player left before the game finished.
  final bool dnf;

  const PlayerResult({
    required this.name,
    required this.scores,
    this.dnf = false,
  });

  int get total => scores.fold(0, (sum, s) => sum + s);

  Map<String, dynamic> toJson() => {'n': name, 's': scores, 'd': dnf};

  factory PlayerResult.fromJson(Map<String, dynamic> json) => PlayerResult(
        name: json['n'] as String,
        scores: (json['s'] as List).map((e) => e as int).toList(),
        dnf: json['d'] as bool? ?? false,
      );
}

class GameRecord {
  final DateTime playedAt;
  final List<PlayerResult> players;

  const GameRecord({required this.playedAt, required this.players});

  List<PlayerResult> get finishers => players.where((p) => !p.dnf).toList();

  /// Lowest total among finishers; ties share the win.
  List<PlayerResult> get winners {
    final f = finishers;
    if (f.isEmpty) return [];
    final best = f.map((p) => p.total).reduce((a, b) => a < b ? a : b);
    return f.where((p) => p.total == best).toList();
  }

  int get rounds => players.fold(
        0,
        (max, p) => p.scores.length > max ? p.scores.length : max,
      );

  Map<String, dynamic> toJson() => {
        't': playedAt.toIso8601String(),
        'p': players.map((p) => p.toJson()).toList(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        playedAt: DateTime.parse(json['t'] as String),
        players: (json['p'] as List)
            .map((e) => PlayerResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
