import 'package:flutter/material.dart';
import 'games/games.dart';
import 'screens/start_screen.dart';
import 'utils/game_state_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = await GameStateStorage.load();
  runApp(OdinScoreKeeperApp(resumed: session == null ? null : resumeScreen(session)));
}

class OdinScoreKeeperApp extends StatelessWidget {
  /// The screen of a game that was in progress when the app was closed.
  final Widget? resumed;

  const OdinScoreKeeperApp({super.key, this.resumed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odin Scores',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Menus are dark grey; Material 3 menu items use labelTextStyle.
        popupMenuTheme: const PopupMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
          labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ),
      home: resumed ?? const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
