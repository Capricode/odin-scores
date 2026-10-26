import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/js_sort.dart';

import 'fixtures.dart';

// v8_sort_cases.json was produced by Node's Array.prototype.sort with this
// (non-transitive) comparator, which mirrors the forest assembler's one.
num _compare(List a, List b) {
  final pa = a[0] as int, pb = b[0] as int;
  if (pa != pb) return pa - pb;
  final ax = a[1] as int, ay = a[2] as int, ah = a[3] as int;
  final bx = b[1] as int, by = b[2] as int;
  if (pa == 0) return (ay - by).abs() < ah / 2 ? ax - bx : ay - by;
  return pa.isOdd ? bx - ax : ay - by;
}

void main() {
  final cases = loadJson('v8_sort_cases.json') as List;

  test('matches V8 Array.prototype.sort', () {
    for (final c in cases) {
      final items = (c['items'] as List).cast<List>();
      final indices = List.generate(items.length, (i) => i);
      jsSort<int>(indices, (i, j) => _compare(items[i], items[j]));
      expect(indices, c['sorted'], reason: '${items.length} items');
    }
  });

  test('is stable', () {
    final list = List.generate(100, (i) => [i % 3, i]);
    jsSort<List<int>>(list, (a, b) => a[0] - b[0]);
    for (var i = 1; i < list.length; i++) {
      if (list[i][0] == list[i - 1][0]) {
        expect(list[i][1], greaterThan(list[i - 1][1]));
      }
    }
  });
}
