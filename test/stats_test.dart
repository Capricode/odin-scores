import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/stats/game_record.dart';
import 'package:odin_score_keeper/stats/stats_calculator.dart';

GameRecord game(Map<String, List<int>> players, {Set<String> dnf = const {}, int day = 1}) {
  return GameRecord(
    playedAt: DateTime(2026, 1, day),
    players: [
      for (final e in players.entries)
        PlayerResult(name: e.key, scores: e.value, dnf: dnf.contains(e.key)),
    ],
  );
}

void main() {
  group('winners', () {
    test('lowest total wins and ties share', () {
      final g = game({'Anna': [5, 5, 5], 'Ben': [1, 1, 1], 'Cy': [1, 1, 1]});
      expect(g.winners.map((w) => w.name), ['Ben', 'Cy']);
    });

    test('players who left cannot win', () {
      final g = game({'Anna': [0, 0], 'Ben': [4, 4, 8]}, dnf: {'Anna'});
      expect(g.winners.map((w) => w.name), ['Ben']);
    });
  });

  group('awards', () {
    String? detail(List<Award> a, String title) =>
        a.where((x) => x.title == title).map((x) => x.detail).firstOrNull;

    test('ice cold lists most zeros, hidden when nobody has a zero', () {
      final a = StatsCalculator.awards(game({'A': [0, 0, 9, 7], 'B': [0, 3, 3, 9]}));
      expect(detail(a, 'Ice Cold'), 'A (2×)');
      final none = StatsCalculator.awards(game({'A': [1, 2], 'B': [3, 4]}));
      expect(detail(none, 'Ice Cold'), isNull);
    });

    test('disaster round needs 7 or more', () {
      expect(detail(StatsCalculator.awards(game({'A': [6, 1], 'B': [2, 2]})), 'Disaster Round'), isNull);
      expect(detail(StatsCalculator.awards(game({'A': [7, 1], 'B': [2, 2]})), 'Disaster Round'), 'A (7)');
    });

    test('close call is a finisher on exactly 14', () {
      final a = StatsCalculator.awards(game({'A': [7, 7], 'B': [1, 1, 1, 1]}));
      expect(detail(a, 'Close Call'), 'A');
    });

    test('comeback: winner alone in last place after round 2+', () {
      // After round 2: A=9, B=2 -> A alone last. A finishes lowest.
      final a = StatsCalculator.awards(game({
        'A': [5, 4, 0, 0, 0, 0, 0, 0],
        'B': [1, 1, 5, 5, 5, 5, 5, 5],
      }));
      expect(detail(a, 'Comeback'), 'A');
    });

    test('no comeback when last place was only in round 1 or shared', () {
      final round1Only = StatsCalculator.awards(game({
        'A': [5, 0, 0, 0],
        'B': [0, 5, 5, 5],
      }));
      expect(detail(round1Only, 'Comeback'), isNull);

      final shared = StatsCalculator.awards(game({'A': [3, 3, 0, 0, 0], 'B': [3, 3, 9, 9, 9]}));
      expect(detail(shared, 'Comeback'), isNull);
    });
  });

  group('leaderboard and streaks', () {
    final games = [
      game({'Anna': [1, 1], 'ben': [9, 9]}, day: 1),
      game({'Anna': [1, 1], 'Ben': [9, 9]}, day: 2),
      game({'Anna': [9, 9], 'Ben': [1, 1]}, day: 3),
    ];

    test('names merge case-insensitively and win rate is computed', () {
      final stats = StatsCalculator.playerStats(games);
      final anna = stats.firstWhere((s) => s.name == 'Anna');
      final ben = stats.firstWhere((s) => nameKey(s.name) == 'ben');
      expect([anna.wins, anna.games], [2, 3]);
      expect([ben.wins, ben.games], [1, 3]);
    });

    test('streaks track current and best', () {
      final stats = StatsCalculator.playerStats(games);
      final anna = stats.firstWhere((s) => s.name == 'Anna');
      expect([anna.bestStreak, anna.currentStreak], [2, 0]);
      expect(StatsCalculator.currentStreaks(games)['ben'], 1);
    });

    test('a game left early counts neither as played nor as a streak break', () {
      final withDnf = [
        game({'A': [1, 1], 'B': [9, 9]}, day: 1),
        game({'A': [1, 1], 'B': [9, 9], 'C': [3]}, dnf: {'A'}, day: 2),
        game({'A': [1, 1], 'B': [9, 9]}, day: 3),
      ];
      final a = StatsCalculator.playerStats(withDnf).firstWhere((s) => s.name == 'A');
      expect([a.games, a.wins, a.currentStreak], [2, 2, 2]);
    });
  });

  group('records', () {
    test('lowest win, longest game and worst round (DNF rounds count)', () {
      final games = [
        game({'A': [2, 2, 2], 'B': [9, 9]}),
        game({'A': [1, 1, 1, 1, 1], 'B': [5, 5, 8], 'C': [9]}, dnf: {'C'}),
      ];
      final r = StatsCalculator.records(games);
      expect(r.lowestWin!.value, 5);
      expect(r.lowestWin!.label, 'A');
      expect(r.longestGame!.value, 5);
      expect(r.worstRound!.value, 9);
      expect(r.worstRound!.label, 'B & C');
    });

    test('empty history has no records', () {
      final r = StatsCalculator.records([]);
      expect(r.lowestWin, isNull);
      expect(r.worstRound, isNull);
    });
  });

  group('nemesis', () {
    GameRecord g(int a, int b, int day) =>
        game({'Anna': [a], 'Ben': [b]}, day: day);

    test('needs at least 3 shared games', () {
      final n = StatsCalculator.nemeses([g(5, 1, 1), g(5, 1, 2)]);
      expect(n, isEmpty);
    });

    test('opponent who finished below you most often', () {
      final n = StatsCalculator.nemeses([g(5, 1, 1), g(5, 1, 2), g(5, 1, 3), g(1, 5, 4)]);
      final anna = n.firstWhere((x) => x.player == 'Anna');
      expect(anna.nemeses, ['Ben']);
      expect(anna.losses, 3);
      final ben = n.firstWhere((x) => x.player == 'Ben');
      expect(ben.nemeses, ['Anna']);
      expect(ben.losses, 1);
    });
  });

  test('records survive a JSON round trip', () {
    final g = game({'A': [1, 2], 'B': [3]}, dnf: {'B'});
    final copy = GameRecord.fromJson(g.toJson());
    expect(copy.players[1].dnf, true);
    expect(copy.players[0].scores, [1, 2]);
    expect(copy.playedAt, g.playedAt);
  });
}
