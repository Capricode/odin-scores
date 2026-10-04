import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const OdinScoreKeeperApp());
}

class OdinScoreKeeperApp extends StatelessWidget {
  const OdinScoreKeeperApp({super.key});

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
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
