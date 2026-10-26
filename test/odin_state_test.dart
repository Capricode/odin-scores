import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/models/player.dart';
import 'package:odin_score_keeper/games/odin/odin_game_screen.dart';
import 'package:odin_score_keeper/games/game_type.dart';
import 'package:odin_score_keeper/games/games.dart';
import 'package:odin_score_keeper/games/odin/odin_saved_game.dart';
import 'package:odin_score_keeper/utils/game_state_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a game in progress is saved and can be resumed', (tester) async {
    final players = [
      Player(id: 'a', name: 'Anna'),
      Player(id: 'b', name: 'Ben'),
    ];
    await tester.pumpWidget(MaterialApp(home: OdinGameScreen(initialPlayers: players)));
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

    final session = (await tester.runAsync(GameStateStorage.load))!;
    expect(session.game, GameType.odin);
    final saved = SavedGame.fromJson(session.state);
    expect(saved.currentRound, 2);
    expect(saved.players.map((p) => p.totalScore), [3, 5]);
    expect(saved.currentRoundScores, {'a': 7, 'b': null});
    expect(saved.roundHistory.single.scores, {'a': 3, 'b': 5});

    // "Restart" the app with the saved game.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MaterialApp(home: resumeScreen(session)));
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

  test('a game saved before multi-game support resumes as Odin', () async {
    final legacy = SavedGame(
      players: [Player(id: 'a', name: 'Anna'), Player(id: 'b', name: 'Ben')],
      leftPlayers: [],
      leavingIds: {},
      currentRoundScores: {'a': null, 'b': null},
      gameEnded: false,
      currentRound: 1,
      startPlayerIndex: 0,
      roundHistory: [],
    );
    SharedPreferences.setMockInitialValues({'current_game': jsonEncode(legacy.toJson())});
    final session = (await GameStateStorage.load())!;
    expect(session.game, GameType.odin);
    expect(resumeScreen(session), isA<OdinGameScreen>());
  });
}
