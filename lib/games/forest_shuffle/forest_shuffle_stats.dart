import '../../stats/game_record.dart';
import '../../stats/stats_calculator.dart';

/// Forest Shuffle is scored once at the end. A [PlayerResult] stores the
/// points per scoring category in [categories] order, so its total is the
/// final score. Highest total wins.
class ForestShuffleStats {
  static const List<String> categories = [
    'Trees',
    'Top',
    'Bottom',
    'Sides',
    'Cave'
  ];

  static List<RecordLine> recordLines(List<GameRecord> games) {
    RecordLine? best(String title, int Function(PlayerResult p) value) {
      var top = 0;
      final names = <String>{};
      for (final g in games) {
        for (final p in g.finishers) {
          final v = value(p);
          if (v > top) {
            top = v;
            names.clear();
          }
          if (v == top && v > 0) names.add(p.name);
        }
      }
      return top == 0 ? null : RecordLine(title, '$top · ${names.join(' & ')}');
    }

    int category(PlayerResult p, int i) =>
        i < p.scores.length ? p.scores[i] : 0;

    return [
      best('🏆 Highest score', (p) => p.total),
      for (var i = 0; i < categories.length; i++)
        best('${_emoji[i]} Most points from ${categories[i].toLowerCase()}',
            (p) => category(p, i)),
    ].whereType<RecordLine>().toList();
  }

  static const List<String> _emoji = ['🌳', '🐦', '🍄', '🦊', '🕳️'];
}
