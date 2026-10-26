import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest_shuffle_engine.dart';

import 'fixtures.dart';

// Port of ForestDetector src/app/forest-assembler.spec.ts. The expected cards
// were extracted verbatim from the spec into assembler_expected.json.
void main() {
  final expected = loadJson('assembler_expected.json') as Map<String, dynamic>;

  for (final entry in expected.entries) {
    test('should load ${entry.key} and validate output of assembleForest', () {
      final forestCards =
          ForestAssembler.assembleForest(loadPredictions(entry.key));
      final expectedCards = [
        for (final c in entry.value as List)
          ForestCard(
              c[0] as String, CardColor.fromLabel(c[1] as String), c[2] as int),
      ];
      expect(forestCards, unorderedEquals(expectedCards));
    });
  }

  test('unknown labels are rejected', () {
    expect(
      () => ForestAssembler.assembleForest(const [
        Prediction(label: 'Nope', x: 0, y: 0, width: 1, height: 1),
      ]),
      throwsArgumentError,
    );
  });

  test('a card without a tree cannot be assembled', () {
    expect(
      () => ForestAssembler.assembleForest(const [
        Prediction(label: 'Linde', x: 100, y: 100, width: 50, height: 80),
        // Top card below the tree: nothing to attach to.
        Prediction(
            label: 'Waldkauz_Green', x: 100, y: 300, width: 50, height: 40),
      ]),
      throwsA(isA<ForestAssemblyException>()),
    );
  });

  test('lenient assembly reports cards it cannot place', () {
    final result = ForestAssembler.assemble(const [
      Prediction(label: 'Linde', x: 100, y: 100, width: 50, height: 80),
      Prediction(label: 'Waldkauz_Green', x: 100, y: 300, width: 50, height: 40),
      Prediction(label: 'Nope', x: 0, y: 0, width: 1, height: 1),
    ]);
    expect(result.cards.map((c) => c.label), ['Linde']);
    expect(result.unattached.map((p) => p.label), unorderedEquals(['Waldkauz_Green', 'Nope']));
  });

  test('stacked cards attach to the same tree', () {
    final cards = ForestAssembler.assembleForest(const [
      Prediction(label: 'Linde', x: 100, y: 100, width: 50, height: 80),
      Prediction(label: 'Eiche', x: 300, y: 100, width: 50, height: 80),
      Prediction(label: 'Erdkroete_Red', x: 100, y: 160, width: 50, height: 40),
      Prediction(
          label: 'Erdkroete_Grey', x: 100, y: 175, width: 50, height: 40),
    ]);
    expect(cards.map((c) => c.baseIndex), [0, 1, 0, 0]);
  });
}
