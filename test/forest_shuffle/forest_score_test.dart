import 'package:flutter_test/flutter_test.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest.dart';
import 'package:odin_score_keeper/games/forest_shuffle/engine/forest_shuffle_engine.dart';

// Port of ForestDetector src/app/forest-score.spec.ts.
void main() {
  int score(List<ForestCard> cards) {
    final all = <Forest>[];
    final forest = Forest('Player1', all);
    all.add(forest);
    forest.setCards(cards);
    forest.caveCount = 0;
    forest.updatePoints();
    return forest.points;
  }

  test('should calculate the score of 238 points', () {
    expect(score(_forest238), 238);
  });

  test('should calculate the score of 161 points', () {
    expect(score(_forest161), 161);
  });
}

const _forest238 = [
  ForestCard('Buche', CardColor.beech, 0),
  ForestCard('Linde', CardColor.linden, 1),
  ForestCard('Birke', CardColor.birch, 2),
  ForestCard('Buche', CardColor.beech, 3),
  ForestCard('Linde', CardColor.linden, 4),
  ForestCard('Buche', CardColor.beech, 5),
  ForestCard('Buche', CardColor.beech, 6),
  ForestCard('Birke', CardColor.birch, 7),
  ForestCard('Feldhase_Left_LightGreen', CardColor.birch, 7),
  ForestCard('Feldhase_Left_Green', CardColor.beech, 1),
  ForestCard('Feldhase_Left_Brown', CardColor.oak, 7),
  ForestCard('Waschbaer_Left_Blue', CardColor.silverFir, 4),
  ForestCard('Feldhase_Left_Yellow', CardColor.linden, 0),
  ForestCard('Steinmarder_Left_Green', CardColor.beech, 6),
  ForestCard('Steinmarder_Left_Red', CardColor.sycamore, 2),
  ForestCard('Braunbaer_Right_Green', CardColor.beech, 5),
  ForestCard('Feldhase_Right_Blue', CardColor.silverFir, 2),
  ForestCard('Feldhase_Right_LightGreen', CardColor.birch, 6),
  ForestCard('Steinmarder_Right_Orange', CardColor.horseChestnut, 0),
  ForestCard('Feldhase_Right_Red', CardColor.sycamore, 4),
  ForestCard('Feldhase_Right_Red', CardColor.sycamore, 1),
  ForestCard('Fuchs_Right_Brown', CardColor.oak, 7),
  ForestCard('Waldkauz_Green', CardColor.beech, 7),
  ForestCard('Schillerfalter_Yellow', CardColor.linden, 4),
  ForestCard('Kaisermantel_Brown', CardColor.oak, 2),
  ForestCard('Trauermantel_Red', CardColor.sycamore, 1),
  ForestCard('Tagpfauenauge_Orange', CardColor.horseChestnut, 0),
  ForestCard('Parasol_Orange', CardColor.horseChestnut, 0),
  ForestCard('Igel_Green', CardColor.beech, 1),
  ForestCard('Waldameise_Green', CardColor.beech, 2),
  ForestCard('Erdkroete_Red', CardColor.sycamore, 4),
  ForestCard('Erdkroete_Grey', CardColor.douglasFir, 4),
  ForestCard('Igel_Orange', CardColor.horseChestnut, 7),
];

const _forest161 = [
  ForestCard('Kastanie', CardColor.horseChestnut, 0),
  ForestCard('Birke', CardColor.birch, 1),
  ForestCard('Ahorn', CardColor.sycamore, 2),
  ForestCard('Birke', CardColor.birch, 3),
  ForestCard('Kastanie', CardColor.horseChestnut, 4),
  ForestCard('Eiche', CardColor.oak, 5),
  ForestCard('Linde', CardColor.linden, 6),
  ForestCard('Kastanie', CardColor.horseChestnut, 7),
  ForestCard('Tanne', CardColor.silverFir, 8),
  ForestCard('Linde', CardColor.linden, 9),
  ForestCard('Linde', CardColor.linden, 10),
  ForestCard('Birke', CardColor.birch, 11),
  ForestCard('Kastanie', CardColor.horseChestnut, 12),
  ForestCard('Kastanie', CardColor.horseChestnut, 13),
  ForestCard('Luchs_Left_Orange', CardColor.horseChestnut, 8),
  ForestCard('Frischling_Left_Brown', CardColor.oak, 2),
  ForestCard('Holzbiene_Left_Grey', CardColor.douglasFir, 7),
  ForestCard('Holzbiene_Right_Grey', CardColor.douglasFir, 7),
  ForestCard('Wildschwein_Right_Brown', CardColor.oak, 8),
  ForestCard('Trauermantel_Red', CardColor.sycamore, 7),
  ForestCard('Buntspecht_Yellow', CardColor.linden, 8),
  ForestCard('Tagpfauenauge_Yellow', CardColor.linden, 6),
  ForestCard('Eichhoernchen_Grey', CardColor.douglasFir, 5),
  ForestCard('Buntspecht_Yellow', CardColor.linden, 1),
  ForestCard('Groser-Fuchs_Red', CardColor.sycamore, 2),
  ForestCard('Kaisermantel_Brown', CardColor.oak, 0),
  ForestCard('Moos_Yellow', CardColor.linden, 3),
  ForestCard('Moos_Grey', CardColor.douglasFir, 8),
  ForestCard('Moos_Yellow', CardColor.linden, 7),
];
