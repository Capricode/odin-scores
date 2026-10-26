import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/forest_editor_screen.dart';
import 'package:odin_score_keeper/games/forest_shuffle/forest_shuffle_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('every card is listed once; its tree symbols come second', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ForestEditorScreen(playerName: 'Anna', initial: ForestEntry()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add tree or shrub'));
    await tester.pumpAndSettle();

    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => ((t.title as Text).data!))
        .toList();
    expect(titles.where((t) => t == 'Blackthorn'), hasLength(1));
    expect(titles.toSet(), hasLength(titles.length), reason: 'duplicates: $titles');

    await tester.tap(find.widgetWithText(ListTile, 'Blackthorn'));
    await tester.pumpAndSettle();
    expect(find.text('Which tree symbol is in the corner?'), findsOneWidget);
    for (final symbol in ['Douglas Fir', 'Birch', 'Silver Fir', 'Sycamore']) {
      expect(find.widgetWithText(ListTile, symbol), findsOneWidget);
    }
  });
}
