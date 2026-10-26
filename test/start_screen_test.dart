import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/screens/start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('recently used names already in the game are not suggested', (tester) async {
    SharedPreferences.setMockInitialValues({
      'used_player_names': ['Anna', 'Ben'],
    });
    await tester.pumpWidget(const MaterialApp(home: StartScreen()));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Anna'), findsOneWidget);

    await tester.tap(find.widgetWithText(InputChip, 'Anna'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Anna'), findsNothing);
    expect(find.widgetWithText(InputChip, 'Ben'), findsOneWidget);

    // Removing the player suggests the name again.
    await tester.tap(find.byTooltip('Remove player'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Anna'), findsOneWidget);
  });

  testWidgets('the game is picked from a list and remembered', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: StartScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Odin'), findsOneWidget);

    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a game'), findsOneWidget);
    await tester.tap(find.text('Forest Shuffle'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a game'), findsNothing);
    expect(find.text('Forest Shuffle'), findsOneWidget);
    expect(find.text('Start Forest Shuffle'), findsNothing); // no players yet

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_game'), 'forest_shuffle');
  });
}
