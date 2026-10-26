// End-to-end scoring as done in ForestDetector's home.component.ts (MIT).
// See THIRD_PARTY_NOTICES.md.

import 'forest.dart';
import 'forest_assembler.dart';
import 'prediction.dart';

/// Input for one player: their assembled forest plus cards in the cave.
class PlayerForest {
  final String name;
  final List<ForestCard> cards;
  final int caveCount;

  const PlayerForest({
    required this.name,
    required this.cards,
    this.caveCount = 0,
  });

  /// Assembles the forest from detector output, see
  /// [ForestAssembler.assembleForest] for the exceptions thrown.
  factory PlayerForest.fromPredictions(
    String name,
    List<Prediction> predictions, {
    int caveCount = 0,
  }) =>
      PlayerForest(
        name: name,
        cards: ForestAssembler.assembleForest(predictions),
        caveCount: caveCount,
      );
}

/// Count and points of one glaures card type in a forest.
class CardScore {
  final String name;
  final int count;
  final int points;

  const CardScore(this.name, this.count, this.points);

  @override
  String toString() => 'CardScore($name, $count, $points)';
}

class ForestScore {
  final String playerName;
  final int total;

  /// Trees and shrubs.
  final int trees;

  /// Cards on top of trees, including [butterflies].
  final int top;
  final int bottom;

  /// Cards left and right of trees.
  final int side;
  final int cave;

  /// Points for butterfly sets (already part of [top]).
  final int butterflies;

  final int treeCount;
  final int topCount;
  final int bottomCount;
  final int sideCount;

  /// Every card type that is in the forest or scores points.
  final List<CardScore> cards;

  const ForestScore({
    required this.playerName,
    required this.total,
    required this.trees,
    required this.top,
    required this.bottom,
    required this.side,
    required this.cave,
    required this.butterflies,
    required this.treeCount,
    required this.topCount,
    required this.bottomCount,
    required this.sideCount,
    required this.cards,
  });
}

/// Scores all players together, since some cards (linden, great spotted
/// woodpecker) compare forests. Results are in the order of [players].
List<ForestScore> scoreForests(List<PlayerForest> players) {
  final all = <Forest>[];
  for (final player in players) {
    final forest = Forest(player.name, all);
    all.add(forest);
    forest.setCards(player.cards);
    forest.caveCount = player.caveCount;
  }
  for (final forest in all) {
    forest.updatePoints();
  }
  return [
    for (final f in all)
      ForestScore(
        playerName: f.playerName,
        total: f.points,
        trees: f.treePoints(),
        top: f.topPoints(),
        bottom: f.bottomPoints(),
        side: f.sidePoints(),
        cave: f.caveCount,
        butterflies: f.butterflyPoints,
        treeCount: f.treeCardsCount(),
        topCount: f.topCount(),
        bottomCount: f.bottomCount(),
        sideCount: f.sideCount(),
        cards: List.unmodifiable([
          for (final c in f.cards)
            if (c.count > 0 || c.points != 0)
              CardScore(c.name, c.count, c.points),
        ]),
      ),
  ];
}
