import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/forest_shuffle_screen.dart';
import 'package:odin_score_keeper/games/game_type.dart';
import 'package:odin_score_keeper/games/games.dart';
import 'package:odin_score_keeper/models/player.dart';
import 'package:odin_score_keeper/stats/stats_storage.dart';
import 'package:odin_score_keeper/utils/game_state_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> addTree(WidgetTester tester, String search, String name) async {
    await tester.tap(find.text('Add tree or shrub'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), search);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, name).first);
    await tester.pumpAndSettle();
  }

  testWidgets('forests entered by hand are scored, finished and saved', (tester) async {
    final players = [Player(id: 'a', name: 'Anna'), Player(id: 'b', name: 'Ben')];
    await tester.pumpWidget(MaterialApp(home: ForestShuffleScreen(initialPlayers: players)));
    await tester.pumpAndSettle();
    expect(find.text('Enter every forest to finish (0/2)'), findsOneWidget);

    // Anna: two lindens (most lindens: 3 points each).
    await tester.tap(find.text('Anna'));
    await tester.pumpAndSettle();
    await addTree(tester, 'linden', 'Linden');
    await addTree(tester, 'linden', 'Linden');
    // Points stay hidden until the game is finished.
    expect(find.textContaining('points'), findsNothing);
    expect(find.text('2 cards on 2 trees'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Ben: one oak and two cards in the cave.
    await tester.tap(find.text('Ben'));
    await tester.pumpAndSettle();
    await addTree(tester, 'oak', 'Oak');
    await tester.tap(find.byTooltip('One card more'));
    await tester.tap(find.byTooltip('One card more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // The game in progress can be resumed.
    final session = (await tester.runAsync(GameStateStorage.load))!;
    expect(session.game, GameType.forestShuffle);
    expect(resumeScreen(session), isA<ForestShuffleScreen>());

    expect(find.text('6'), findsNothing);
    await tester.tap(find.text('Finish game'));
    await tester.pumpAndSettle();
    expect(find.text('Anna wins! · 6'), findsOneWidget);

    var games = (await tester.runAsync(() => StatsStorage.load(GameType.forestShuffle)))!;
    expect(games.single.winners.single.name, 'Anna');
    expect(games.single.players.map((p) => p.total), [6, 2]);
    await tester.pump(const Duration(seconds: 5)); // let the confetti finish

    // Correct Ben's forest: three lindens (now the most: 3 points each) and a
    // squeaker on the left, picked by card first, then by tree symbol.
    await tester.tap(find.text('Ben'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Correct'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await addTree(tester, 'linden', 'Linden');
    }
    await tester.tap(find.byTooltip('Add a card to this tree').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'squeaker');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Left'));
    await tester.pumpAndSettle();
    expect(find.text('Which tree symbol is in the corner?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Oak'));
    await tester.pumpAndSettle();
    expect(find.text('Left: Squeaker · Oak'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Ben wins! · 12'), findsOneWidget);

    // The game in the statistics was replaced, not added.
    games = (await tester.runAsync(() => StatsStorage.load(GameType.forestShuffle)))!;
    expect(games.single.winners.single.name, 'Ben');
    expect(games.single.players.map((p) => p.total), [12, 2]);
    await tester.pump(const Duration(seconds: 5)); // let the snackbar go
  });
}
