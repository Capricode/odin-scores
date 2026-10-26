import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest_shuffle_engine.dart';

// Port of ForestDetector src/app/cards-fir-names.spec.ts.
void main() {
  test('all detector cards match a glaures card', () {
    final forest = Forest('', []);
    for (final card in detectorCards.values) {
      expect(forest.findCard(card.glCardName).name, card.glCardName);
    }
  });

  test('catalogue has every detector class', () {
    expect(detectorCards.length, 267);
  });
}
