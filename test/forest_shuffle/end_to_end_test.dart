import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest_shuffle_engine.dart';

import 'fixtures.dart';

// Expected values were produced by running ForestDetector's TypeScript
// (assembler + glaures scoring, as in home.component.ts) on the same fixtures.
void main() {
  ForestScore scoreOne(String file, {int cave = 0}) => scoreForests([
        PlayerForest.fromPredictions(file, loadPredictions(file),
            caveCount: cave),
      ]).single;

  void expectBreakdown(ForestScore s, List<int> totalTreesTopBottomSide) {
    expect(
      [s.total, s.trees, s.top, s.bottom, s.side],
      totalTreesTopBottomSide,
    );
  }

  test('238Points.json scores 238', () {
    final s = scoreOne('238Points.json');
    expectBreakdown(s, [238, 28, 17, 38, 155]);
    expect(s.butterflies, 12);
    expect(
      s.cards.map((c) => [c.name, c.count, c.points]),
      [
        ['beech', 4, 20],
        ['birch', 2, 2],
        ['linden', 2, 6],
        ['tawnyOwl', 1, 5],
        ['camberwellBeauty', 1, 0],
        ['peacockButterfly', 1, 0],
        ['silverWashedFritillary', 1, 0],
        ['purpleEmperor', 1, 0],
        ['parasolMushroom', 1, 0],
        ['commonToad', 2, 10],
        ['woodAnt', 1, 12],
        ['hedgehog', 2, 16],
        ['beechMarten', 3, 75],
        ['brownBear', 1, 0],
        ['europeanHare', 8, 64],
        ['raccoon', 1, 0],
        ['redFox', 1, 16],
      ],
    );
  });

  test('161Points.json scores 161', () {
    final s = scoreOne('161Points.json');
    expectBreakdown(s, [161, 83, 37, 30, 11]);
    expect(s.butterflies, 12);
  });

  test('2025-01-25 photos score 239', () {
    for (final file in [
      '2025-01-25 22.26.38.json',
      '2025-01-25 22.26.47.json'
    ]) {
      final s = scoreOne(file);
      expectBreakdown(s, [239, 10, 18, 65, 146]);
      expect(s.butterflies, 3);
    }
  });

  test('the score categories add up to the total', () {
    final scores = scoreForests([
      for (final f in ['238Points.json', '161Points.json', '2025-01-25 22.26.38.json'])
        PlayerForest.fromPredictions(f, loadPredictions(f), caveCount: 4),
    ]);
    for (final s in scores) {
      expect(s.trees + s.top + s.bottom + s.side + s.cave, s.total, reason: s.playerName);
    }
  });

  test('cave cards add one point each', () {
    final s = scoreOne('238Points.json', cave: 7);
    expect(s.cave, 7);
    expect(s.total, 245);
  });

  test('players are compared for most lindens / trees', () {
    final files = [
      '161Points.json',
      '2025-01-25 22.26.38.json',
      '2025-01-25 22.26.47.json',
      '238Points.json',
    ];
    final scores = scoreForests([
      for (final f in files)
        PlayerForest.fromPredictions(f, loadPredictions(f)),
    ]);
    expect(scores.map((s) => s.playerName), files);
    expect(scores.map((s) => s.total), [161, 239, 239, 234]);
    // 238Points loses the "most lindens" bonus: 2 lindens x 1 instead of x 3.
    expect(scores.last.trees, 24);
  });

  test('players with the same name are still compared', () {
    PlayerForest player(String file) =>
        PlayerForest.fromPredictions('Anna', loadPredictions(file));
    final scores =
        scoreForests([player('238Points.json'), player('161Points.json')]);
    expect(scores.first.total, 234);
  });

  test('params derived from card placement', () {
    // [label, base]; bases first.
    const layout = [
      ['Buche', 0],
      ['Tanne', 1],
      ['Holunder_Yellow', 2],
      ['Eiche', 3],
      ['Linde', 4],
      ['Birke', 5],
      ['Buchfink_Green', 0], // chaffinch atop a beech
      ['Holzbiene_Left_Grey', 0], // violet carpenter bee on a beech
      ['Siebenschlaefer_Left_Blue', 1], // dormouse with a bat opposite
      ['Mopsfledermaus_Right_Brown', 1],
      ['Schillerfalter_Orange', 1],
      ['Erdkroete_Red', 1], // two toads sharing a slot
      ['Erdkroete_Grey', 1], // -> silver fir fully occupied
      ['Nachtigall_Green', 2], // nightingale atop a shrub
      ['Eichhoernchen_Brown', 3], // red squirrel atop an oak
      ['Steinmarder_Left_Red', 3],
      ['Waldiltis_Right_Red', 4], // polecat alone
      ['Bartgeier_Blue', 5], // bearded vulture: 1 per cave card
    ];
    final cards = [
      for (final l in layout)
        ForestCard(l[0] as String, detectorCards[l[0]]!.color, l[1] as int),
    ];
    final s =
        scoreForests([PlayerForest(name: 'A', cards: cards, caveCount: 4)])
            .single;
    final points = {for (final c in s.cards) c.name: c.points};

    expect(points['chaffinch'], 5);
    expect(points['silverFir'], 10); // 5 cards attached x 2
    expect(points['redSquirrel'], 5);
    expect(points['commonToad'], 10);
    expect(points['beechMarten'], 5);
    expect(points['europeanFatDormouse'], 15);
    expect(points['europeanPolecat'], 10);
    expect(points['beardedVulture'], 4);
    // ForestDetector gives 0 here (it counts chaffinches), see param_handler.
    expect(points['nightingale'], 5);
    // ForestDetector: 72 total, 19 top -> 14 top without the nightingale fix.
    expectBreakdown(s, [77, 14, 19, 10, 30]);
    expect(s.cave, 4);
  });
}
