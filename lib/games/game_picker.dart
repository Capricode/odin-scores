import 'package:flutter/material.dart';

import 'game_type.dart';

/// The box of [game], [height] high. Boxes are portrait; the width is
/// fixed so names line up in lists.
class GameBox extends StatelessWidget {
  final GameType game;
  final double height;

  const GameBox(this.game, {super.key, this.height = 72});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 0.75,
      child: Image.asset(
        game.box,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(child: Text(game.emoji, style: TextStyle(fontSize: height / 2))),
      ),
    );
  }
}

/// Box and name of a game.
class _GameLabel extends StatelessWidget {
  final GameType game;
  final double boxHeight;

  const _GameLabel(this.game, {required this.boxHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GameBox(game, height: boxHeight),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            game.name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Shows the selected game; tapping it opens [showGamePicker]. Takes the same
/// space however many games there are.
class GamePickerButton extends StatelessWidget {
  final GameType game;
  final ValueChanged<GameType> onChanged;

  const GamePickerButton({super.key, required this.game, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: game.color, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final picked = await showGamePicker(context, game);
          if (picked != null && picked != game) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(child: _GameLabel(game, boxHeight: 72)),
              const Text('Change', style: TextStyle(color: Colors.white70)),
              const Icon(Icons.expand_more, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets the user pick one of all games; null when dismissed.
Future<GameType?> showGamePicker(BuildContext context, GameType current) {
  return showModalBottomSheet<GameType>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[900],
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Choose a game',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (final g in GameType.values)
              InkWell(
                onTap: () => Navigator.pop(context, g),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: _GameLabel(g, boxHeight: 88)),
                      if (g == current) Icon(Icons.check_circle, color: g.color, size: 28),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
