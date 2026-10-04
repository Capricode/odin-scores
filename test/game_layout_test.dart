import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/models/player.dart';
import 'package:odin_score_keeper/screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('6 players fit a 360x640 phone without scrolling, even at game over',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final players = [
      for (var i = 0; i < 6; i++) Player(id: '$i', name: 'Player${i + 1}'),
    ];
    await tester.pumpWidget(MaterialApp(home: GameScreen(initialPlayers: players)));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);

    // Long-press removes after confirmation.
    await tester.longPress(find.text('Player6').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Player6 removed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game over screen with awards fits without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final players = [
      for (var i = 0; i < 6; i++) Player(id: '$i', name: 'Player${i + 1}'),
    ];
    await tester.pumpWidget(MaterialApp(home: GameScreen(initialPlayers: players)));
    await tester.pumpAndSettle();

    // Enter 0 for player 1 and 9 for the others, until the game ends.
    for (var round = 0; round < 2; round++) {
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('Player${i + 1}').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(i == 0 ? '0' : '9').last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Next Round'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Game over'), findsOneWidget);
    expect(find.textContaining('wins!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
