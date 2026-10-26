import '../../models/player.dart';
import 'engine/forest_shuffle_engine.dart';

/// One player's forest as entered so far: detected and/or hand-picked cards.
class ForestEntry {
  final List<ForestCard> cards;
  final int caveCount;

  const ForestEntry({this.cards = const [], this.caveCount = 0});

  /// Base indices of the trees and shrubs, in order.
  List<int> get baseIndices => {
        for (final c in cards)
          if (c.card.position == CardPosition.base) c.baseIndex,
      }.toList()
        ..sort();

  ForestEntry copyWith({List<ForestCard>? cards, int? caveCount}) => ForestEntry(
        cards: cards ?? this.cards,
        caveCount: caveCount ?? this.caveCount,
      );

  Map<String, dynamic> toJson() => {
        'c': [
          for (final c in cards) {'l': c.label, 'b': c.baseIndex},
        ],
        'v': caveCount,
      };

  factory ForestEntry.fromJson(Map<String, dynamic> json) => ForestEntry(
        cards: [
          for (final c in json['c'] as List)
            forestCard(c['l'] as String, c['b'] as int),
        ],
        caveCount: json['v'] as int,
      );
}

/// A [ForestCard] for [label]; the colour comes from the card catalogue.
ForestCard forestCard(String label, int baseIndex) {
  final card = detectorCards[label];
  if (card == null) throw ArgumentError.value(label, 'label', 'Unknown card');
  return ForestCard(label, card.color, baseIndex);
}

/// Everything needed to resume a Forest Shuffle game.
class ForestShuffleSavedGame {
  final List<Player> players;

  /// Forests by player id; players without an entry haven't been scored yet.
  final Map<String, ForestEntry> forests;
  final bool finished;

  /// When the game was finished; identifies its record in the statistics so
  /// a correction replaces it.
  final DateTime? finishedAt;

  const ForestShuffleSavedGame({
    required this.players,
    required this.forests,
    required this.finished,
    this.finishedAt,
  });

  Map<String, dynamic> toJson() => {
        'p': players.map((p) => p.toJson()).toList(),
        'f': forests.map((id, f) => MapEntry(id, f.toJson())),
        'e': finished,
        if (finishedAt != null) 't': finishedAt!.toIso8601String(),
      };

  factory ForestShuffleSavedGame.fromJson(Map<String, dynamic> json) => ForestShuffleSavedGame(
        players: [
          for (final p in json['p'] as List) Player.fromJson(p as Map<String, dynamic>),
        ],
        forests: (json['f'] as Map).map(
          (id, f) => MapEntry(id as String, ForestEntry.fromJson(f as Map<String, dynamic>)),
        ),
        finished: json['e'] as bool,
        finishedAt: json['t'] == null ? null : DateTime.parse(json['t'] as String),
      );
}

/// Scores the forests of [players] together (some cards compare forests).
/// Players without a forest count as an empty forest.
Map<String, ForestScore> scorePlayers(List<Player> players, Map<String, ForestEntry> forests) {
  final scores = scoreForests([
    for (final p in players)
      PlayerForest(
        name: p.name,
        cards: forests[p.id]?.cards ?? const [],
        caveCount: forests[p.id]?.caveCount ?? 0,
      ),
  ]);
  return {for (var i = 0; i < players.length; i++) players[i].id: scores[i]};
}
