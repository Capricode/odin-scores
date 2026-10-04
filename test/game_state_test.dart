import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/models/player.dart';
import 'package:odin_score_keeper/screens/game_screen.dart';
import 'package:odin_score_keeper/utils/game_state_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a game in progress is saved and can be resumed', (tester) async {
    final players = [
      Player(id: 'a', name: 'Anna'),
      Player(id: 'b', name: 'Ben'),
    ];
    await tester.pumpWidget(MaterialApp(home: GameScreen(initialPlayers: players)));
    await tester.pumpAndSettle();

    // Finish round 1 (Anna 3, Ben 5), then enter 7 for Anna in round 2.
    for (final (name, score) in [('Anna', '3'), ('Ben', '5')]) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(score).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Next Round'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anna'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7').last);
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(GameStateStorage.load))!;
    expect(saved.currentRound, 2);
    expect(saved.players.map((p) => p.totalScore), [3, 5]);
    expect(saved.currentRoundScores, {'a': 7, 'b': null});
    expect(saved.roundHistory.single.scores, {'a': 3, 'b': 5});

    // "Restart" the app with the saved game.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MaterialApp(home: GameScreen(savedGame: saved)));
    await tester.pumpAndSettle();

    expect(find.text('Round 2'), findsOneWidget);
    expect(find.text('+7'), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
  });

  test('missing or damaged state loads as no game', () async {
    expect(await GameStateStorage.load(), isNull);
    SharedPreferences.setMockInitialValues({'current_game': 'not json'});
    expect(await GameStateStorage.load(), isNull);
  });
}
