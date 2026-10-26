// Translated to Dart from ForestDetector src/model/forest.ts (MIT).
// See THIRD_PARTY_NOTICES.md.

import 'card_color.dart';
import 'card_id.dart';
import 'card_position.dart';
import 'detector_cards.dart';
import 'gl_forest.dart';
import 'param_handler.dart';

/// A detected card, attached to the tree/shrub with [baseIndex] (or being
/// that tree/shrub itself).
class ForestCard {
  /// Detector class label, a key of [detectorCards].
  final String label;
  final CardColor color;
  final int baseIndex;

  const ForestCard(this.label, this.color, this.baseIndex);

  DetectorCard get card {
    final card = detectorCards[label];
    if (card == null) throw ArgumentError.value(label, 'label', 'Unknown card');
    return card;
  }

  @override
  bool operator ==(Object other) =>
      other is ForestCard &&
      other.label == label &&
      other.color == color &&
      other.baseIndex == baseIndex;

  @override
  int get hashCode => Object.hash(label, color, baseIndex);

  @override
  String toString() => 'ForestCard($label, ${color.label}, $baseIndex)';
}

/// A glaures forest filled from detected [ForestCard]s.
class Forest extends GlForest {
  List<ForestCard> forestCards = const [];

  Forest(super.playerName, super.allForests);

  /// Cards attached to the base [baseIndex], optionally only of [speci].
  /// The base itself is only included when [returnBase] is set.
  List<ForestCard> getCardsOnBase(
    int baseIndex, {
    CardId? speci,
    bool returnBase = false,
  }) =>
      forestCards.where((c) {
        if (c.baseIndex != baseIndex) return false;
        final info = c.card;
        if (speci != null && speci != info.speci) return false;
        return returnBase || info.position != CardPosition.base;
      }).toList();

  ForestCard getBase(int baseIndex) => forestCards.firstWhere(
        (c) => c.baseIndex == baseIndex && c.card.position == CardPosition.base,
        orElse: () =>
            throw StateError("No base found with index: '$baseIndex'!"),
      );

  void setCards(List<ForestCard> cards) {
    forestCards = List.unmodifiable(cards);
    for (final card in cards) {
      final info = card.card;
      findCard(info.glCardName).count++;
      incrementTypeCount(info.color.glSymbol);
    }
    _handleParams();
  }

  void _handleParams() {
    const handler = ParamHandler();
    for (final card in cards) {
      for (final param in card.def.params) {
        handler.handleParam(card, param, this);
      }
    }
  }
}
