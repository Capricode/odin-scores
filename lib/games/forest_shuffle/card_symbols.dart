import 'package:flutter/material.dart';

import 'card_names.dart';
import 'engine/forest_shuffle_engine.dart';

/// The tree symbol in a card's corner, drawn in the colour the card uses for
/// it, e.g. yellow for linden.
Color symbolColor(CardColor symbol) => switch (symbol) {
      CardColor.none => Colors.transparent,
      CardColor.linden => Colors.amber,
      CardColor.oak => Colors.brown,
      CardColor.silverFir => Colors.blue,
      CardColor.birch => Colors.lightGreen,
      CardColor.beech => Colors.green.shade800,
      CardColor.sycamore => Colors.red,
      CardColor.douglasFir => Colors.blueGrey,
      CardColor.horseChestnut => Colors.orange,
      CardColor.larix => Colors.purple.shade300,
      CardColor.pinus => Colors.pink.shade200,
    };

/// "Linden", "Silver Fir", ...; empty for tree saplings (no symbol).
String symbolName(CardColor symbol) =>
    symbol == CardColor.none ? '' : cardName(symbol.glSymbol);

/// A small coloured dot for a tree symbol.
class SymbolDot extends StatelessWidget {
  final CardColor symbol;
  final double size;

  const SymbolDot(this.symbol, {super.key, this.size = 12});

  @override
  Widget build(BuildContext context) {
    if (symbol == CardColor.none) return SizedBox(width: size, height: size);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: symbolColor(symbol),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54),
      ),
    );
  }
}
