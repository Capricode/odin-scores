import '../../stats/game_record.dart';
import '../../stats/stats_calculator.dart';

class RecordEntry {
  final int value;
  final String label;

  const RecordEntry(this.value, this.label);
}

class Records {
  final RecordEntry? lowestWin;
  final RecordEntry? longestGame;
  final RecordEntry? worstRound;

  const Records({this.lowestWin, this.longestGame, this.worstRound});
}

/// Odin awards and records. Odin is played in rounds of 0-9 points and the
/// lowest total wins.
class OdinStats {
  static const int disasterThreshold = 7;

  static String _join(Iterable<String> names) => names.join(' & ');

  static String _times(int n) => n > 1 ? ' ($n×)' : '';

  // ---------------------------------------------------------------- awards

  static List<Award> awards(GameRecord game) {
    final result = <Award>[];

    // Ice Cold: most rounds with 0.
    final zeros = {
      for (final p in game.players)
        p.name: p.scores.where((s) => s == 0).length,
    };
    final maxZeros = zeros.values.fold(0, (m, v) => v > m ? v : m);
    if (maxZeros > 0) {
      final names = zeros.entries
          .where((e) => e.value == maxZeros)
          .map((e) => e.key);
      result.add(Award('🧊', 'Ice Cold', '${_join(names)}${_times(maxZeros)}'));
    }

    // Disaster Round: highest single round (7+).
    var worst = 0;
    for (final p in game.players) {
      for (final s in p.scores) {
        if (s > worst) worst = s;
      }
    }
    if (worst >= disasterThreshold) {
      final names = game.players
          .where((p) => p.scores.contains(worst))
          .map((p) => p.name);
      result.add(Award('💥', 'Disaster Round', '${_join(names)} ($worst)'));
    }

    // Comeback: a winner who was alone in last place after round 2 or later.
    final comebackNames = <String>[];
    for (final w in game.winners) {
      for (var r = 2; r <= game.rounds; r++) {
        final present = game.players.where((p) => p.scores.length >= r);
        final totals = {
          for (final p in present) p: p.scores.take(r).fold(0, (a, b) => a + b),
        };
        if (totals.length < 2 || !totals.containsKey(w)) continue;
        final maxTotal = totals.values.reduce((a, b) => a > b ? a : b);
        final last = totals.entries.where((e) => e.value == maxTotal).toList();
        if (last.length == 1 && identical(last.first.key, w)) {
          comebackNames.add(w.name);
          break;
        }
      }
    }
    if (comebackNames.isNotEmpty) {
      result.add(Award('🚀', 'Comeback', _join(comebackNames)));
    }

    // Close Call: finished on exactly 14.
    final close = game.finishers.where((p) => p.total == 14).map((p) => p.name);
    if (close.isNotEmpty) {
      result.add(Award('😬', 'Close Call', _join(close)));
    }

    return result;
  }

  // -------------------------------------------------------------- records

  static Records records(List<GameRecord> games) {
    int? lowestWin;
    final lowestNames = <String>{};
    int? longest;
    String longestLabel = '';
    var worst = 0;
    final worstNames = <String>{};

    for (final game in games) {
      for (final w in game.winners) {
        if (lowestWin == null || w.total < lowestWin) {
          lowestWin = w.total;
          lowestNames.clear();
        }
        if (w.total == lowestWin) lowestNames.add(w.name);
      }

      if (longest == null || game.rounds >= longest) {
        longest = game.rounds;
        longestLabel = game.players.map((p) => p.name).join(', ');
      }

      for (final p in game.players) {
        for (final s in p.scores) {
          if (s > worst) {
            worst = s;
            worstNames.clear();
          }
          if (s == worst && worst > 0) worstNames.add(p.name);
        }
      }
    }

    return Records(
      lowestWin: lowestWin == null
          ? null
          : RecordEntry(lowestWin, lowestNames.join(' & ')),
      longestGame: longest == null ? null : RecordEntry(longest, longestLabel),
      worstRound: worst == 0
          ? null
          : RecordEntry(worst, worstNames.join(' & ')),
    );
  }

  static List<RecordLine> recordLines(List<GameRecord> games) {
    final r = records(games);
    return [
      if (r.lowestWin != null)
        RecordLine(
          '🎯 Lowest winning score',
          '${r.lowestWin!.value} · ${r.lowestWin!.label}',
        ),
      if (r.longestGame != null)
        RecordLine('⏳ Longest game', '${r.longestGame!.value} rounds'),
      if (r.worstRound != null)
        RecordLine(
          '💥 Worst single round',
          '${r.worstRound!.value} · ${r.worstRound!.label}',
        ),
    ];
  }
}
