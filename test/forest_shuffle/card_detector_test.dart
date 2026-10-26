import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/detector/card_detector.dart';

Detection box(String label, double confidence, double x) => Detection(
      label: label,
      confidence: confidence,
      x: x,
      y: 0.5,
      width: 0.1,
      height: 0.2,
    );

void main() {
  test('overlapping boxes keep the most confident one, of any class', () {
    final kept = CardDetector.nonMaxSuppression([
      box('Buche', 0.6, 0.5),
      box('Eiche', 0.9, 0.501),
      box('Linde', 0.8, 0.8),
    ]);
    expect(kept.map((d) => d.label), ['Eiche', 'Linde']);
  });
}
