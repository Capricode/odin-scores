import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/start_screen.dart';
import 'utils/game_state_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedGame = await GameStateStorage.load();
  runApp(OdinScoreKeeperApp(savedGame: savedGame));
}

class OdinScoreKeeperApp extends StatelessWidget {
  final SavedGame? savedGame;

  const OdinScoreKeeperApp({super.key, this.savedGame});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odin Score Keeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        popupMenuTheme: const PopupMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: savedGame != null ? GameScreen(savedGame: savedGame) : const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
