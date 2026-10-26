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

/// One line in the Records section of the statistics screen.
class RecordLine {
  final String title;
  final String value;

  const RecordLine(this.title, this.value);
}

class NemesisInfo {
  final String player;
  final List<String> nemeses;
  final int losses;
  final int sharedGames;

  const NemesisInfo(this.player, this.nemeses, this.losses, this.sharedGames);
}

/// Statistics that work the same for every game.
class StatsCalculator {
  static const int minGamesForNemesis = 3;

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

  // -------------------------------------------------------------- nemesis

  /// Nemesis = the opponent who finished ahead of you most often, considering
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
          if (game.game.beats(b.total, a.total)) {
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
