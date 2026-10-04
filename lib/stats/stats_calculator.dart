import 'game_record.dart';

class Award {
  final String emoji;
  final String title;
  final String detail;

  const Award(this.emoji, this.title, this.detail);
}

class PlayerStats {
  final String name;
  int wins = 0;
  int games = 0;
  int currentStreak = 0;
  int bestStreak = 0;

  PlayerStats(this.name);

  double get winRate => games == 0 ? 0 : wins / games;
}

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

class NemesisInfo {
  final String player;
  final List<String> nemeses;
  final int losses;
  final int sharedGames;

  const NemesisInfo(this.player, this.nemeses, this.losses, this.sharedGames);
}

class StatsCalculator {
  static const int minGamesForNemesis = 3;
  static const int disasterThreshold = 7;

  static String _join(Iterable<String> names) => names.join(' & ');

  static String _times(int n) => n > 1 ? ' (${n}×)' : '';

  // ---------------------------------------------------------------- awards

  static List<Award> awards(GameRecord game) {
    final result = <Award>[];

    // Ice Cold: most rounds with 0.
    final zeros = {
      for (final p in game.players) p.name: p.scores.where((s) => s == 0).length
    };
    final maxZeros = zeros.values.fold(0, (m, v) => v > m ? v : m);
    if (maxZeros > 0) {
      final names = zeros.entries.where((e) => e.value == maxZeros).map((e) => e.key);
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
          for (final p in present) p: p.scores.take(r).fold(0, (a, b) => a + b)
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

  // ---------------------------------------------------------- leaderboard

  /// [games] must be in chronological order (oldest first).
  static List<PlayerStats> playerStats(List<GameRecord> games) {
    final map = <String, PlayerStats>{};
    for (final game in games) {
      final winnerKeys = game.winners.map((w) => nameKey(w.name)).toSet();
      for (final p in game.finishers) {
        final key = nameKey(p.name);
        final s = map.putIfAbsent(key, () => PlayerStats(p.name));
        final isWinner = winnerKeys.contains(key);
        s.games++;
        if (isWinner) {
          s.wins++;
          s.currentStreak++;
          if (s.currentStreak > s.bestStreak) s.bestStreak = s.currentStreak;
        } else {
          s.currentStreak = 0;
        }
      }
    }
    final list = map.values.toList()
      ..sort((a, b) {
        final byWins = b.wins.compareTo(a.wins);
        if (byWins != 0) return byWins;
        final byRate = b.winRate.compareTo(a.winRate);
        if (byRate != 0) return byRate;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return list;
  }

  /// Current win streak per [nameKey].
  static Map<String, int> currentStreaks(List<GameRecord> games) => {
        for (final s in playerStats(games)) nameKey(s.name): s.currentStreak,
      };

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
      longestGame:
          longest == null ? null : RecordEntry(longest, longestLabel),
      worstRound:
          worst == 0 ? null : RecordEntry(worst, worstNames.join(' & ')),
    );
  }

  // -------------------------------------------------------------- nemesis

  /// Nemesis = the opponent who finished below you most often, considering
  /// only opponents you shared at least [minGamesForNemesis] finished games with.
  static List<NemesisInfo> nemeses(List<GameRecord> games) {
    final names = <String, String>{};
    final shared = <String, Map<String, int>>{};
    final lost = <String, Map<String, int>>{};

    for (final game in games) {
      final f = game.finishers;
      for (final a in f) {
        final ka = nameKey(a.name);
        names[ka] = a.name;
        for (final b in f) {
          if (identical(a, b)) continue;
          final kb = nameKey(b.name);
          shared.putIfAbsent(ka, () => {}).update(kb, (v) => v + 1, ifAbsent: () => 1);
          if (b.total < a.total) {
            lost.putIfAbsent(ka, () => {}).update(kb, (v) => v + 1, ifAbsent: () => 1);
          }
        }
      }
    }

    final result = <NemesisInfo>[];
    for (final ka in lost.keys) {
      final candidates = lost[ka]!
          .entries
          .where((e) => (shared[ka]![e.key] ?? 0) >= minGamesForNemesis)
          .toList();
      if (candidates.isEmpty) continue;
      final most = candidates.map((e) => e.value).reduce((a, b) => a > b ? a : b);
      final top = candidates.where((e) => e.value == most).toList();
      result.add(NemesisInfo(
        names[ka]!,
        top.map((e) => names[e.key]!).toList(),
        most,
        shared[ka]![top.first.key]!,
      ));
    }
    result.sort((a, b) => a.player.toLowerCase().compareTo(b.player.toLowerCase()));
    return result;
  }
}
