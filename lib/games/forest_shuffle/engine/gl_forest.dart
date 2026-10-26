// Translated to Dart from glaures/forestshuffle src/model/Forest.js
// (Apache 2.0). See THIRD_PARTY_NOTICES.md.

import 'gl_cards.dart';

/// One player's forest as glaures scores it: a count per card type plus
/// per-card params, with points computed by each card's rule.
class GlForest {
  final String playerName;

  /// All forests of the game (including this one), for "has most" rules.
  final List<GlForest> allForests;

  int butterflyPoints = 0;
  int caveCount = 0;
  int points = 0;

  /// `<symbol>Count` values (e.g. `beechCount`), keyed by symbol.
  final Map<String, int> _typeCounts = {};

  final List<GlCard> cards = [for (final def in glCards) GlCard(def)];
  late final Map<String, GlCard> _byName = {for (final c in cards) c.name: c};

  GlForest(this.playerName, this.allForests);

  int typeCount(String symbol) => _typeCounts[symbol] ?? 0;

  void incrementTypeCount(String symbol) =>
      _typeCounts[symbol] = typeCount(symbol) + 1;

  GlCard findCard(String cardName) {
    final card = _byName[cardName];
    if (card == null) throw ArgumentError.value(cardName, 'cardName');
    return card;
  }

  void updatePoints() {
    var sum = 0;
    for (final card in cards) {
      card.recalculatePoints(this);
      sum += card.points;
    }
    butterflyPoints = calculateButterflyPoints(this);
    points = sum + butterflyPoints + caveCount;
  }

  int countByName(String cardName) {
    var count = findCard(cardName).count;
    if (cardName == 'linden') {
      count += findCard('violetCarpenterBee').param('onALinden');
    }
    return count;
  }

  int countBySymbol(String symbol) => cards
      .where((c) => c.def.hasSymbol(symbol))
      .fold(0, (sum, c) => sum + c.count);

  int countTreesIncludingVioletCarpenterBee() =>
      countBySymbol('tree') +
      findCard('violetCarpenterBee').params.values.fold(0, (a, b) => a + b);

  int countByPosition(GlPosition position) => cards
      .where((c) => c.position == position)
      .fold(0, (sum, c) => sum + c.count);

  int countDistinctBySymbol(String symbol) =>
      cards.where((c) => c.def.hasSymbol(symbol) && c.count > 0).length;

  // The original filters the other forests by playerName, which drops all
  // forests sharing this player's name; we compare by identity instead.
  Iterable<GlForest> get _otherForests =>
      allForests.where((f) => !identical(f, this));

  bool hasMostOfName(String cardName) {
    final here = countByName(cardName);
    return _otherForests.every((f) => f.countByName(cardName) <= here);
  }

  bool hasMostOfSymbol(String symbol) {
    final here = countBySymbol(symbol);
    return _otherForests.every((f) => f.countBySymbol(symbol) <= here);
  }

  bool hasMostTrees() {
    final here = countTreesIncludingVioletCarpenterBee();
    return _otherForests
        .every((f) => f.countTreesIncludingVioletCarpenterBee() <= here);
  }

  int treeCount() => countBySymbol('tree');

  /// Trees and shrubs.
  int treeCardsCount() => cards
      .where((c) => c.def.hasSymbol('tree') || c.def.hasSymbol('shrub'))
      .fold(0, (sum, c) => sum + c.count);

  int topCount() => countByPosition(GlPosition.top);
  int bottomCount() => countByPosition(GlPosition.bottom);
  int sideCount() => countByPosition(GlPosition.side);

  int _sumPoints(bool Function(GlCard) test) =>
      cards.where(test).fold(0, (sum, c) => sum + c.points);

  /// Points of trees and shrubs.
  int treePoints() =>
      _sumPoints((c) => c.def.hasSymbol('tree') || c.def.hasSymbol('shrub'));

  int bottomPoints() => _sumPoints((c) => c.position == GlPosition.bottom);

  /// Includes the butterfly set points.
  int topPoints() =>
      _sumPoints((c) => c.position == GlPosition.top) + butterflyPoints;

  int sidePoints() => _sumPoints((c) => c.position == GlPosition.side);
}
