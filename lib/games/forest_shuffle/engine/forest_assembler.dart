// Translated to Dart from ForestDetector src/model/forest-assembler.ts (MIT).
// See THIRD_PARTY_NOTICES.md.
//
// Reconstructs the forest by assigning the detected cards to the BASE
// (tree/shrub) cards.

import 'card_position.dart';
import 'detector_cards.dart';
import 'forest.dart';
import 'js_sort.dart';
import 'prediction.dart';

/// Thrown when detections can't be turned into a forest.
class ForestAssemblyException implements Exception {
  final String message;

  const ForestAssemblyException(this.message);

  @override
  String toString() => 'ForestAssemblyException: $message';
}

class _PredictionCard {
  final Prediction prediction;
  final DetectorCard card;
  int? baseIndex;

  _PredictionCard(this.prediction, this.card);

  double get x => prediction.x;
  double get y => prediction.y;
  CardPosition get position => card.position;
}

const _positionOrder = {
  CardPosition.base: 0,
  CardPosition.left: 1,
  CardPosition.right: 2,
  CardPosition.top: 3,
  CardPosition.bottom: 4,
};

class ForestAssembler {
  const ForestAssembler._();

  static num _compareCards(_PredictionCard a, _PredictionCard b) {
    if (a.position != b.position) {
      return _positionOrder[a.position]! - _positionOrder[b.position]!;
    }
    switch (a.position) {
      case CardPosition.base:
        // Row by row, then by column; allow a slight variation in y.
        if ((a.y - b.y).abs() < a.prediction.height / 2) return a.x - b.x;
        return a.y - b.y;
      case CardPosition.left:
        return b.x - a.x; // highest x first
      case CardPosition.right:
        return a.x - b.x; // lowest x first
      case CardPosition.top:
        return b.y - a.y; // highest y first
      case CardPosition.bottom:
        return a.y - b.y; // lowest y first
    }
  }

  /// Nearest base, or nearest card of the same position on the side facing
  /// the tree (cards can be stacked, e.g. two toads).
  static _PredictionCard? _findNearestCard(
    _PredictionCard card,
    List<_PredictionCard> cards,
  ) {
    _PredictionCard? nearest;
    var minDistance = double.infinity;

    for (final other in cards) {
      if (identical(other, card)) continue;
      if (other.position != CardPosition.base &&
          other.position != card.position) {
        continue;
      }

      switch (card.position) {
        case CardPosition.left:
          if (other.x <= card.x) continue;
        case CardPosition.right:
          if (other.x >= card.x) continue;
        case CardPosition.top:
          if (other.y <= card.y) continue;
        case CardPosition.bottom:
          if (other.y >= card.y) continue;
        case CardPosition.base:
          break;
      }

      final dx = card.x - other.x;
      final dy = card.y - other.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared < minDistance) {
        minDistance = distanceSquared;
        nearest = other;
      }
    }
    return nearest;
  }

  /// Turns detector output into cards attached to their tree/shrub.
  ///
  /// Throws [ArgumentError] for unknown labels and
  /// [ForestAssemblyException] when a card can't be attached to any tree.
  static List<ForestCard> assembleForest(List<Prediction> predictions) {
    for (final p in predictions) {
      if (!detectorCards.containsKey(p.label)) {
        throw ArgumentError.value(p.label, 'label', 'Unknown card');
      }
    }
    final result = assemble(predictions);
    if (result.unattached.isNotEmpty) {
      final card = result.unattached.first;
      throw ForestAssemblyException(
          'No nearest card found for card at position (${card.x}, ${card.y})');
    }
    return result.cards;
  }

  /// Like [assembleForest], but skips unknown labels and cards that can't be
  /// attached to a tree instead of throwing; they end up in
  /// [ForestAssembly.unattached].
  static ForestAssembly assemble(List<Prediction> predictions) {
    final unattached = <Prediction>[];
    final cards = <_PredictionCard>[];
    for (final p in predictions) {
      final card = detectorCards[p.label];
      if (card == null) {
        unattached.add(p);
      } else {
        cards.add(_PredictionCard(p, card));
      }
    }

    jsSort(cards, _compareCards);

    var baseIndex = 0;
    for (final card in cards) {
      if (card.position == CardPosition.base) {
        card.baseIndex = baseIndex++;
        continue;
      }
      final nearest = _findNearestCard(card, cards);
      if (nearest?.baseIndex == null) {
        unattached.add(card.prediction);
        continue;
      }
      card.baseIndex = nearest!.baseIndex;
    }

    return ForestAssembly(
      [
        for (final card in cards)
          if (card.baseIndex != null)
            ForestCard(card.prediction.label, card.card.color, card.baseIndex!),
      ],
      unattached,
    );
  }
}

class ForestAssembly {
  final List<ForestCard> cards;

  /// Detections with an unknown label or no tree to attach to.
  final List<Prediction> unattached;

  const ForestAssembly(this.cards, this.unattached);
}
