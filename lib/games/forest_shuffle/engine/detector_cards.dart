// Generated from ForestDetector src/model/cards.ts (MIT, NINI1988).
// See THIRD_PARTY_NOTICES.md.

import 'card_color.dart';
import 'card_id.dart';
import 'card_position.dart';

/// What the detector knows about one class label.
class DetectorCard {
  final CardId speci;
  final CardColor color;
  final CardPosition position;

  /// Name of the matching card in [glCards].
  final String glCardName;

  const DetectorCard(this.speci, this.color, this.position, this.glCardName);
}

/// Detector class label -> card. Labels are `<Species>[_<Side>]_<Color>`.
const detectorCards = <String, DetectorCard>{
  'Baumsproessling': DetectorCard(
      CardId.sapling, CardColor.none, CardPosition.base, 'treeSaplings'),
  'Linde': DetectorCard(
      CardId.linden, CardColor.linden, CardPosition.base, 'linden'),
  'Eiche': DetectorCard(CardId.oak, CardColor.oak, CardPosition.base, 'oak'),
  'Tanne': DetectorCard(
      CardId.silverFir, CardColor.silverFir, CardPosition.base, 'silverFir'),
  'Birke':
      DetectorCard(CardId.birch, CardColor.birch, CardPosition.base, 'birch'),
  'Buche':
      DetectorCard(CardId.beech, CardColor.beech, CardPosition.base, 'beech'),
  'Ahorn': DetectorCard(
      CardId.sycamore, CardColor.sycamore, CardPosition.base, 'sycamore'),
  'Douglasie': DetectorCard(
      CardId.douglasFir, CardColor.douglasFir, CardPosition.base, 'douglasFir'),
  'Kastanie': DetectorCard(CardId.horseChestnut, CardColor.horseChestnut,
      CardPosition.base, 'horseChestnut'),
  'Feldhase_Left_Yellow': DetectorCard(
      CardId.europeanHare, CardColor.linden, CardPosition.left, 'europeanHare'),
  'Dachs_Right_Grey': DetectorCard(CardId.europeanBadger, CardColor.douglasFir,
      CardPosition.right, 'europeanBadger'),
  'Feldhase_Left_Brown': DetectorCard(
      CardId.europeanHare, CardColor.oak, CardPosition.left, 'europeanHare'),
  'Hufeisennase_Right_Yellow': DetectorCard(CardId.greaterHorseshoeBat,
      CardColor.linden, CardPosition.right, 'greaterHorseshoeBat'),
  'Feldhase_Left_Blue': DetectorCard(CardId.europeanHare, CardColor.silverFir,
      CardPosition.left, 'europeanHare'),
  'Fuchs_Right_Brown':
      DetectorCard(CardId.redFox, CardColor.oak, CardPosition.right, 'redFox'),
  'Waschbaer_Left_Grey': DetectorCard(
      CardId.raccoon, CardColor.douglasFir, CardPosition.left, 'raccoon'),
  'Feldhase_Right_Red': DetectorCard(CardId.europeanHare, CardColor.sycamore,
      CardPosition.right, 'europeanHare'),
  'Wildschwein_Left_Red': DetectorCard(
      CardId.wildBoar, CardColor.sycamore, CardPosition.left, 'wildBoar'),
  'Feldhase_Right_Blue': DetectorCard(CardId.europeanHare, CardColor.silverFir,
      CardPosition.right, 'europeanHare'),
  'Braunes-Langohr_Left_Red': DetectorCard(CardId.brownLongEaredBat,
      CardColor.sycamore, CardPosition.left, 'brownLongEaredBat'),
  'Feldhase_Right_Yellow': DetectorCard(CardId.europeanHare, CardColor.linden,
      CardPosition.right, 'europeanHare'),
  'Waschbaer_Left_Blue': DetectorCard(
      CardId.raccoon, CardColor.silverFir, CardPosition.left, 'raccoon'),
  'Reh_Right_Green': DetectorCard(
      CardId.roeDeer, CardColor.beech, CardPosition.right, 'roeDeerBeech'),
  'Mopsfledermaus_Left_Orange': DetectorCard(CardId.barbastelleBat,
      CardColor.horseChestnut, CardPosition.left, 'barbastelleBat'),
  'Wildschwein_Right_Brown': DetectorCard(
      CardId.wildBoar, CardColor.oak, CardPosition.right, 'wildBoar'),
  'Braunbaer_Left_Yellow': DetectorCard(
      CardId.brownBear, CardColor.linden, CardPosition.left, 'brownBear'),
  'Waschbaer_Right_Blue': DetectorCard(
      CardId.raccoon, CardColor.silverFir, CardPosition.right, 'raccoon'),
  'Steinmarder_Left_Red': DetectorCard(
      CardId.beechMarten, CardColor.sycamore, CardPosition.left, 'beechMarten'),
  'Braunbaer_Right_Orange': DetectorCard(CardId.brownBear,
      CardColor.horseChestnut, CardPosition.right, 'brownBear'),
  'Rothirsch_Left_Yellow': DetectorCard(
      CardId.redDeer, CardColor.linden, CardPosition.left, 'redDeer'),
  'Braunbaer_Right_Green': DetectorCard(
      CardId.brownBear, CardColor.beech, CardPosition.right, 'brownBear'),
  'Mopsfledermaus_Left_Blue': DetectorCard(CardId.barbastelleBat,
      CardColor.silverFir, CardPosition.left, 'barbastelleBat'),
  'Steinmarder_Right_Orange': DetectorCard(CardId.beechMarten,
      CardColor.horseChestnut, CardPosition.right, 'beechMarten'),
  'Luchs_Left_Grey': DetectorCard(
      CardId.lynx, CardColor.douglasFir, CardPosition.left, 'lynx'),
  'Feldhase_Right_LightGreen': DetectorCard(
      CardId.europeanHare, CardColor.birch, CardPosition.right, 'europeanHare'),
  'Wildschwein_Left_LightGreen': DetectorCard(
      CardId.wildBoar, CardColor.birch, CardPosition.left, 'wildBoar'),
  'Steinmarder_Right_Brown': DetectorCard(
      CardId.beechMarten, CardColor.oak, CardPosition.right, 'beechMarten'),
  'Dachs_Left_Orange': DetectorCard(CardId.europeanBadger,
      CardColor.horseChestnut, CardPosition.left, 'europeanBadger'),
  'Stechmuecke_Right_Brown':
      DetectorCard(CardId.gnat, CardColor.oak, CardPosition.right, 'gnat'),
  'Fuchs_Left_Yellow': DetectorCard(
      CardId.redFox, CardColor.linden, CardPosition.left, 'redFox'),
  'Holzbiene_Right_Grey': DetectorCard(CardId.violetCarpenterBee,
      CardColor.douglasFir, CardPosition.right, 'violetCarpenterBee'),
  'Reh_Right_Orange': DetectorCard(CardId.roeDeer, CardColor.horseChestnut,
      CardPosition.right, 'roeDeerHorseChestnut'),
  'Damhirsch_Left_Yellow': DetectorCard(
      CardId.fallowDeer, CardColor.linden, CardPosition.left, 'fallowDeer'),
  'Wildschwein_Right_Grey': DetectorCard(
      CardId.wildBoar, CardColor.douglasFir, CardPosition.right, 'wildBoar'),
  'Reh_Right_LightGreen': DetectorCard(
      CardId.roeDeer, CardColor.birch, CardPosition.right, 'roeDeerBirch'),
  'Rothirsch_Left_Blue': DetectorCard(
      CardId.redDeer, CardColor.silverFir, CardPosition.left, 'redDeer'),
  'Damhirsch_Right_Red': DetectorCard(
      CardId.fallowDeer, CardColor.sycamore, CardPosition.right, 'fallowDeer'),
  'Holzbiene_Left_Grey': DetectorCard(CardId.violetCarpenterBee,
      CardColor.douglasFir, CardPosition.left, 'violetCarpenterBee'),
  'Luchs_Right_Green':
      DetectorCard(CardId.lynx, CardColor.beech, CardPosition.right, 'lynx'),
  'Siebenschlaefer_Left_Green': DetectorCard(CardId.europeanFatDormouse,
      CardColor.beech, CardPosition.left, 'europeanFatDormouse'),
  'Mopsfledermaus_Right_Brown': DetectorCard(CardId.barbastelleBat,
      CardColor.oak, CardPosition.right, 'barbastelleBat'),
  'Hufeisennase_Left_Green': DetectorCard(CardId.greaterHorseshoeBat,
      CardColor.beech, CardPosition.left, 'greaterHorseshoeBat'),
  'Siebenschlaefer_Right_Grey': DetectorCard(CardId.europeanFatDormouse,
      CardColor.douglasFir, CardPosition.right, 'europeanFatDormouse'),
  'Wolf_Right_Blue': DetectorCard(
      CardId.wolf, CardColor.silverFir, CardPosition.right, 'wolf'),
  'Siebenschlaefer_Left_Blue': DetectorCard(CardId.europeanFatDormouse,
      CardColor.silverFir, CardPosition.left, 'europeanFatDormouse'),
  'Braunes-Langohr_Right_Green': DetectorCard(CardId.brownLongEaredBat,
      CardColor.beech, CardPosition.right, 'brownLongEaredBat'),
  'Bechsteinfledermaus_Left_Green': DetectorCard(
      CardId.bechstein, CardColor.beech, CardPosition.left, 'bechsteinsBat'),
  'Siebenschlaefer_Right_Brown': DetectorCard(CardId.europeanFatDormouse,
      CardColor.oak, CardPosition.right, 'europeanFatDormouse'),
  'Stechmuecke_Left_LightGreen':
      DetectorCard(CardId.gnat, CardColor.birch, CardPosition.left, 'gnat'),
  'Wolf_Left_Grey': DetectorCard(
      CardId.wolf, CardColor.douglasFir, CardPosition.left, 'wolf'),
  'Stechmuecke_Right_Orange': DetectorCard(
      CardId.gnat, CardColor.horseChestnut, CardPosition.right, 'gnat'),
  'Reh_Left_Yellow': DetectorCard(
      CardId.roeDeer, CardColor.linden, CardPosition.left, 'roeDeerLinden'),
  'Frischling_Right_Red': DetectorCard(
      CardId.squeaker, CardColor.sycamore, CardPosition.right, 'squeaker'),
  'Bechsteinfledermaus_Left_Brown': DetectorCard(
      CardId.bechstein, CardColor.oak, CardPosition.left, 'bechsteinsBat'),
  'Reh_Left_Blue': DetectorCard(CardId.roeDeer, CardColor.silverFir,
      CardPosition.left, 'roeDeerSilverFir'),
  'Luchs_Right_Yellow':
      DetectorCard(CardId.lynx, CardColor.linden, CardPosition.right, 'lynx'),
  'Steinmarder_Left_Green': DetectorCard(
      CardId.beechMarten, CardColor.beech, CardPosition.left, 'beechMarten'),
  'Bechsteinfledermaus_Right_LightGreen': DetectorCard(
      CardId.bechstein, CardColor.birch, CardPosition.right, 'bechsteinsBat'),
  'Feldhase_Left_Green': DetectorCard(
      CardId.europeanHare, CardColor.beech, CardPosition.left, 'europeanHare'),
  'Rothirsch_Right_Orange': DetectorCard(
      CardId.redDeer, CardColor.horseChestnut, CardPosition.right, 'redDeer'),
  'Wolf_Left_Red':
      DetectorCard(CardId.wolf, CardColor.sycamore, CardPosition.left, 'wolf'),
  'Frischling_Left_Orange': DetectorCard(
      CardId.squeaker, CardColor.horseChestnut, CardPosition.left, 'squeaker'),
  'Rothirsch_Right_Brown': DetectorCard(
      CardId.redDeer, CardColor.oak, CardPosition.right, 'redDeer'),
  'Fuchs_Left_Green':
      DetectorCard(CardId.redFox, CardColor.beech, CardPosition.left, 'redFox'),
  'Frischling_Right_Brown': DetectorCard(
      CardId.squeaker, CardColor.oak, CardPosition.right, 'squeaker'),
  'Waschbaer_Right_LightGreen': DetectorCard(
      CardId.raccoon, CardColor.birch, CardPosition.right, 'raccoon'),
  'Frischling_Left_Brown': DetectorCard(
      CardId.squeaker, CardColor.oak, CardPosition.left, 'squeaker'),
  'Luchs_Right_Blue': DetectorCard(
      CardId.lynx, CardColor.silverFir, CardPosition.right, 'lynx'),
  'Feldhase_Left_LightGreen': DetectorCard(
      CardId.europeanHare, CardColor.birch, CardPosition.left, 'europeanHare'),
  'Luchs_Left_Orange': DetectorCard(
      CardId.lynx, CardColor.horseChestnut, CardPosition.left, 'lynx'),
  'Fuchs_Right_Grey': DetectorCard(
      CardId.redFox, CardColor.douglasFir, CardPosition.right, 'redFox'),
  'Holzbiene_Left_Blue': DetectorCard(CardId.violetCarpenterBee,
      CardColor.silverFir, CardPosition.left, 'violetCarpenterBee'),
  'Damhirsch_Right_LightGreen': DetectorCard(
      CardId.fallowDeer, CardColor.birch, CardPosition.right, 'fallowDeer'),
  'Habicht_Grey': DetectorCard(
      CardId.goshawk, CardColor.douglasFir, CardPosition.top, 'goshawk'),
  'Moos_Yellow':
      DetectorCard(CardId.moss, CardColor.linden, CardPosition.bottom, 'moss'),
  'Buntspecht_Yellow': DetectorCard(CardId.greatSpottedWoodpecker,
      CardColor.linden, CardPosition.top, 'greatSpottedWoodpecker'),
  'Waldameise_LightGreen': DetectorCard(
      CardId.woodAnt, CardColor.birch, CardPosition.bottom, 'woodAnt'),
  'Buchfink_LightGreen': DetectorCard(
      CardId.chaffinch, CardColor.birch, CardPosition.top, 'chaffinch'),
  'Waldameise_Green': DetectorCard(
      CardId.woodAnt, CardColor.beech, CardPosition.bottom, 'woodAnt'),
  'Waldkauz_Green': DetectorCard(
      CardId.tawnyOwl, CardColor.beech, CardPosition.top, 'tawnyOwl'),
  'Hirschkaefer_Red': DetectorCard(
      CardId.stagBeetle, CardColor.sycamore, CardPosition.bottom, 'stagBeetle'),
  'Kaisermantel_Brown': DetectorCard(CardId.silverWashedFritillary,
      CardColor.oak, CardPosition.top, 'silverWashedFritillary'),
  'Feuersalamander_Orange': DetectorCard(CardId.fireSalamander,
      CardColor.horseChestnut, CardPosition.bottom, 'fireSalamander'),
  'Schillerfalter_Orange': DetectorCard(CardId.purpleEmperor,
      CardColor.horseChestnut, CardPosition.top, 'purpleEmperor'),
  'Sumpfschildkroete_Red': DetectorCard(
      CardId.pondTurtle, CardColor.sycamore, CardPosition.bottom, 'pondTurtle'),
  'Trauermantel_Red': DetectorCard(CardId.camberwellBeauty, CardColor.sycamore,
      CardPosition.top, 'camberwellBeauty'),
  'Sumpfschildkroete_LightGreen': DetectorCard(
      CardId.pondTurtle, CardColor.birch, CardPosition.bottom, 'pondTurtle'),
  'Groser-Fuchs_Blue': DetectorCard(CardId.largeTortoiseshell,
      CardColor.silverFir, CardPosition.top, 'largeTortoiseshell'),
  'Feuersalamander_Grey': DetectorCard(CardId.fireSalamander,
      CardColor.douglasFir, CardPosition.bottom, 'fireSalamander'),
  'Gimpel_Grey': DetectorCard(
      CardId.bullfinch, CardColor.douglasFir, CardPosition.top, 'bullfinch'),
  'Laubfrosch_Yellow': DetectorCard(
      CardId.treeFrog, CardColor.linden, CardPosition.bottom, 'treeFrog'),
  'Buchfink_Red': DetectorCard(
      CardId.chaffinch, CardColor.sycamore, CardPosition.top, 'chaffinch'),
  'Hirschkaefer_LightGreen': DetectorCard(
      CardId.stagBeetle, CardColor.birch, CardPosition.bottom, 'stagBeetle'),
  'Habicht_Blue': DetectorCard(
      CardId.goshawk, CardColor.silverFir, CardPosition.top, 'goshawk'),
  'Erdkroete_Brown': DetectorCard(
      CardId.commonToad, CardColor.oak, CardPosition.bottom, 'commonToad'),
  'Eichelhaeher_LightGreen': DetectorCard(
      CardId.eurasianJay, CardColor.birch, CardPosition.top, 'eurasianJay'),
  'Baumfarn_Orange': DetectorCard(CardId.treeFerns, CardColor.horseChestnut,
      CardPosition.bottom, 'treeFerns'),
  'Walderdbeeren_Red': DetectorCard(CardId.wildStrawberries, CardColor.sycamore,
      CardPosition.bottom, 'wildStrawberries'),
  'Brombeeren_Blue': DetectorCard(CardId.blackberries, CardColor.silverFir,
      CardPosition.bottom, 'blackberries'),
  'Moos_Grey': DetectorCard(
      CardId.moss, CardColor.douglasFir, CardPosition.bottom, 'moss'),
  'Gluehwuermchen_Yellow': DetectorCard(
      CardId.fireflies, CardColor.linden, CardPosition.bottom, 'fireflies'),
  'Brombeeren_LightGreen': DetectorCard(CardId.blackberries, CardColor.birch,
      CardPosition.bottom, 'blackberries'),
  'Igel_Green': DetectorCard(
      CardId.hedgehog, CardColor.beech, CardPosition.bottom, 'hedgehog'),
  'Tagpfauenauge_Blue': DetectorCard(CardId.peacockButterfly,
      CardColor.silverFir, CardPosition.top, 'peacockButterfly'),
  'Igel_Brown': DetectorCard(
      CardId.hedgehog, CardColor.oak, CardPosition.bottom, 'hedgehog'),
  'Eichhoernchen_Grey': DetectorCard(CardId.redSquirrel, CardColor.douglasFir,
      CardPosition.top, 'redSquirrel'),
  'Erdkroete_Orange': DetectorCard(CardId.commonToad, CardColor.horseChestnut,
      CardPosition.bottom, 'commonToad'),
  'Eichhoernchen_Orange': DetectorCard(CardId.redSquirrel,
      CardColor.horseChestnut, CardPosition.top, 'redSquirrel'),
  'Gluehwuermchen_Red': DetectorCard(
      CardId.fireflies, CardColor.sycamore, CardPosition.bottom, 'fireflies'),
  'Buchfink_Green': DetectorCard(
      CardId.chaffinch, CardColor.beech, CardPosition.top, 'chaffinch'),
  'Erdkroete_Blue': DetectorCard(CardId.commonToad, CardColor.silverFir,
      CardPosition.bottom, 'commonToad'),
  'Gluehwuermchen_Grey': DetectorCard(
      CardId.fireflies, CardColor.douglasFir, CardPosition.bottom, 'fireflies'),
  'Kaisermantel_Green': DetectorCard(CardId.silverWashedFritillary,
      CardColor.beech, CardPosition.top, 'silverWashedFritillary'),
  'Tagpfauenauge_Brown': DetectorCard(CardId.peacockButterfly, CardColor.oak,
      CardPosition.top, 'peacockButterfly'),
  'Pfifferling_Blue': DetectorCard(CardId.chanterelle, CardColor.silverFir,
      CardPosition.bottom, 'chanterelle'),
  'Tagpfauenauge_Orange': DetectorCard(CardId.peacockButterfly,
      CardColor.horseChestnut, CardPosition.top, 'peacockButterfly'),
  'Gluehwuermchen_Green': DetectorCard(
      CardId.fireflies, CardColor.beech, CardPosition.bottom, 'fireflies'),
  'Groser-Fuchs_Red': DetectorCard(CardId.largeTortoiseshell,
      CardColor.sycamore, CardPosition.top, 'largeTortoiseshell'),
  'Maulwurf_Brown':
      DetectorCard(CardId.mole, CardColor.oak, CardPosition.bottom, 'mole'),
  'Igel_Orange': DetectorCard(CardId.hedgehog, CardColor.horseChestnut,
      CardPosition.bottom, 'hedgehog'),
  'Buntspecht_Grey': DetectorCard(CardId.greatSpottedWoodpecker,
      CardColor.douglasFir, CardPosition.top, 'greatSpottedWoodpecker'),
  'Eichelhaeher_Red': DetectorCard(
      CardId.eurasianJay, CardColor.sycamore, CardPosition.top, 'eurasianJay'),
  'Fliegenpilz_Blue': DetectorCard(
      CardId.flyAgaric, CardColor.silverFir, CardPosition.bottom, 'flyagaric'),
  'Waldkauz_LightGreen': DetectorCard(
      CardId.tawnyOwl, CardColor.birch, CardPosition.top, 'tawnyOwl'),
  'Steinpilz_Grey': DetectorCard(
      CardId.pennyBun, CardColor.douglasFir, CardPosition.bottom, 'pennyBun'),
  'Eichhoernchen_Green': DetectorCard(
      CardId.redSquirrel, CardColor.beech, CardPosition.top, 'redSquirrel'),
  'Feuersalamander_Yellow': DetectorCard(CardId.fireSalamander,
      CardColor.linden, CardPosition.bottom, 'fireSalamander'),
  'Schillerfalter_LightGreen': DetectorCard(
      CardId.purpleEmperor, CardColor.birch, CardPosition.top, 'purpleEmperor'),
  'Laubfrosch_Brown': DetectorCard(
      CardId.treeFrog, CardColor.oak, CardPosition.bottom, 'treeFrog'),
  'Tagpfauenauge_Yellow': DetectorCard(CardId.peacockButterfly,
      CardColor.linden, CardPosition.top, 'peacockButterfly'),
  'Erdkroete_Green': DetectorCard(
      CardId.commonToad, CardColor.beech, CardPosition.bottom, 'commonToad'),
  'Trauermantel_LightGreen': DetectorCard(CardId.camberwellBeauty,
      CardColor.birch, CardPosition.top, 'camberwellBeauty'),
  'Parasol_Orange': DetectorCard(CardId.parasolMushroom,
      CardColor.horseChestnut, CardPosition.bottom, 'parasolMushroom'),
  'Habicht_Brown':
      DetectorCard(CardId.goshawk, CardColor.oak, CardPosition.top, 'goshawk'),
  'Erdkroete_Red': DetectorCard(
      CardId.commonToad, CardColor.sycamore, CardPosition.bottom, 'commonToad'),
  'Eichelhaeher_Orange': DetectorCard(CardId.eurasianJay,
      CardColor.horseChestnut, CardPosition.top, 'eurasianJay'),
  'Baumfarn_Blue': DetectorCard(
      CardId.treeFerns, CardColor.silverFir, CardPosition.bottom, 'treeFerns'),
  'Waldkauz_Red': DetectorCard(
      CardId.tawnyOwl, CardColor.sycamore, CardPosition.top, 'tawnyOwl'),
  'Erdkroete_Grey': DetectorCard(CardId.commonToad, CardColor.douglasFir,
      CardPosition.bottom, 'commonToad'),
  'Gimpel_Blue': DetectorCard(
      CardId.bullfinch, CardColor.silverFir, CardPosition.top, 'bullfinch'),
  'Baumfarn_Yellow': DetectorCard(
      CardId.treeFerns, CardColor.linden, CardPosition.bottom, 'treeFerns'),
  'Eichhoernchen_Brown': DetectorCard(
      CardId.redSquirrel, CardColor.oak, CardPosition.top, 'redSquirrel'),
  'Walderdbeeren_LightGreen': DetectorCard(CardId.wildStrawberries,
      CardColor.birch, CardPosition.bottom, 'wildStrawberries'),
  'Brombeeren_Green': DetectorCard(CardId.blackberries, CardColor.beech,
      CardPosition.bottom, 'blackberries'),
  'Schillerfalter_Yellow': DetectorCard(CardId.purpleEmperor, CardColor.linden,
      CardPosition.top, 'purpleEmperor'),
  'Fliegenpilz_Brown': DetectorCard(
      CardId.flyAgaric, CardColor.oak, CardPosition.bottom, 'flyagaric'),
  'Trauermantel_Orange': DetectorCard(CardId.camberwellBeauty,
      CardColor.horseChestnut, CardPosition.top, 'camberwellBeauty'),
  'Pfifferling_LightGreen': DetectorCard(
      CardId.chanterelle, CardColor.birch, CardPosition.bottom, 'chanterelle'),
  'Groser-Fuchs_Green': DetectorCard(CardId.largeTortoiseshell, CardColor.beech,
      CardPosition.top, 'largeTortoiseshell'),
  'Maulwurf_Red': DetectorCard(
      CardId.mole, CardColor.sycamore, CardPosition.bottom, 'mole'),
  'Parasol_Blue': DetectorCard(CardId.parasolMushroom, CardColor.silverFir,
      CardPosition.bottom, 'parasolMushroom'),
  'Europaeische-Laerche': DetectorCard(
      CardId.larix, CardColor.larix, CardPosition.base, 'europeanLarch'),
  'Zirbelkiefer': DetectorCard(
      CardId.pinus, CardColor.pinus, CardPosition.base, 'stonePine'),
  'Alpenmurmeltier_Left_Green': DetectorCard(CardId.marmotaMarmota,
      CardColor.beech, CardPosition.left, 'alpineMarmot'),
  'Gaemse_Right_Pink': DetectorCard(CardId.rupicapraRupicapra, CardColor.pinus,
      CardPosition.right, 'chamoisStonePine'),
  'Alpenmurmeltier_Left_Lila': DetectorCard(CardId.marmotaMarmota,
      CardColor.larix, CardPosition.left, 'alpineMarmot'),
  'Auerhuhn_Right_Grey': DetectorCard(CardId.tetraoUrogallus,
      CardColor.douglasFir, CardPosition.right, 'capercaillie'),
  'Schneehase_Left_Blue': DetectorCard(CardId.lepusTimidus, CardColor.silverFir,
      CardPosition.left, 'mountainHare'),
  'Alpenmurmeltier_Right_Pink': DetectorCard(CardId.marmotaMarmota,
      CardColor.pinus, CardPosition.right, 'alpineMarmot'),
  'Steinbock_Left_Lila': DetectorCard(
      CardId.capraIbex, CardColor.larix, CardPosition.left, 'steinbock'),
  'Alpenmurmeltier_Right_LightGreen': DetectorCard(CardId.marmotaMarmota,
      CardColor.birch, CardPosition.right, 'alpineMarmot'),
  'Gaemse_Left_Lila': DetectorCard(CardId.rupicapraRupicapra, CardColor.larix,
      CardPosition.left, 'chamoisEuropeanLarch'),
  'Auerhuhn_Right_Green': DetectorCard(CardId.tetraoUrogallus, CardColor.beech,
      CardPosition.right, 'capercaillie'),
  'Schneehase_Left_Lila': DetectorCard(
      CardId.lepusTimidus, CardColor.larix, CardPosition.left, 'mountainHare'),
  'Gaemse_Right_Grey': DetectorCard(CardId.rupicapraRupicapra,
      CardColor.douglasFir, CardPosition.right, 'chamoisDouglasFir'),
  'Alpenfledermaus_Left_Blue': DetectorCard(CardId.hypsugoSavii,
      CardColor.silverFir, CardPosition.left, 'savisPipistrelle'),
  'Steinbock_Right_Pink': DetectorCard(
      CardId.capraIbex, CardColor.pinus, CardPosition.right, 'steinbock'),
  'Auerhuhn_Left_Lila': DetectorCard(CardId.tetraoUrogallus, CardColor.larix,
      CardPosition.left, 'capercaillie'),
  'Alpenfledermaus_Right_Pink': DetectorCard(CardId.hypsugoSavii,
      CardColor.pinus, CardPosition.right, 'savisPipistrelle'),
  'Auerhuhn_Left_Pink': DetectorCard(CardId.tetraoUrogallus, CardColor.pinus,
      CardPosition.left, 'capercaillie'),
  'Steinbock_Right_Grey': DetectorCard(
      CardId.capraIbex, CardColor.douglasFir, CardPosition.right, 'steinbock'),
  'Alpen-Apollofalter_Pink': DetectorCard(CardId.parnassiusPhoebus,
      CardColor.pinus, CardPosition.top, 'phoebusApollo'),
  'Herbsttrompete_Lila': DetectorCard(CardId.craterellusCornucopiodes,
      CardColor.larix, CardPosition.bottom, 'blackTrumpet'),
  'Alpen-Apollofalter_Grey': DetectorCard(CardId.parnassiusPhoebus,
      CardColor.douglasFir, CardPosition.top, 'phoebusApollo'),
  'Edelweis_Pink': DetectorCard(CardId.leontopodiumNivale, CardColor.pinus,
      CardPosition.bottom, 'edelweiss'),
  'Alpen-Apollofalter_Lila': DetectorCard(CardId.parnassiusPhoebus,
      CardColor.larix, CardPosition.top, 'phoebusApollo'),
  'Heidelbeere_LightGreen': DetectorCard(CardId.vacciniumMyrtillus,
      CardColor.birch, CardPosition.bottom, 'blueberry'),
  'Alpen-Apollofalter_Blue': DetectorCard(CardId.parnassiusPhoebus,
      CardColor.silverFir, CardPosition.top, 'phoebusApollo'),
  'Bergmolch_Pink': DetectorCard(CardId.ichthyosauraAlpestris, CardColor.pinus,
      CardPosition.bottom, 'alpineNewt'),
  'Steinadler_Green': DetectorCard(CardId.aquilaChrysaetos, CardColor.beech,
      CardPosition.top, 'goldenEagle'),
  'Herbsttrompete_Pink': DetectorCard(CardId.craterellusCornucopiodes,
      CardColor.pinus, CardPosition.bottom, 'blackTrumpet'),
  'Bartgeier_Blue': DetectorCard(CardId.gypaetusBarbatus, CardColor.silverFir,
      CardPosition.top, 'beardedVulture'),
  'Enzian_Lila': DetectorCard(
      CardId.gentiana, CardColor.larix, CardPosition.bottom, 'gentian'),
  'Steinadler_Lila': DetectorCard(CardId.aquilaChrysaetos, CardColor.larix,
      CardPosition.top, 'goldenEagle'),
  'Bergmolch_Grey': DetectorCard(CardId.ichthyosauraAlpestris,
      CardColor.douglasFir, CardPosition.bottom, 'alpineNewt'),
  'Kolkrabe_Lila': DetectorCard(
      CardId.corvusCorax, CardColor.larix, CardPosition.top, 'commonRaven'),
  'Enzian_Green': DetectorCard(
      CardId.gentiana, CardColor.beech, CardPosition.bottom, 'gentian'),
  'Kolkrabe_Grey': DetectorCard(CardId.corvusCorax, CardColor.douglasFir,
      CardPosition.top, 'commonRaven'),
  'Heidelbeere_Pink': DetectorCard(CardId.vacciniumMyrtillus, CardColor.pinus,
      CardPosition.bottom, 'blueberry'),
  'Bartgeier_Lila': DetectorCard(CardId.gypaetusBarbatus, CardColor.larix,
      CardPosition.top, 'beardedVulture'),
  'Bergmolch_Blue': DetectorCard(CardId.ichthyosauraAlpestris,
      CardColor.silverFir, CardPosition.bottom, 'alpineNewt'),
  'Bartgeier_Pink': DetectorCard(CardId.gypaetusBarbatus, CardColor.pinus,
      CardPosition.top, 'beardedVulture'),
  'Edelweis_Lila': DetectorCard(CardId.leontopodiumNivale, CardColor.larix,
      CardPosition.bottom, 'edelweiss'),
  'Steinadler_Blue': DetectorCard(CardId.aquilaChrysaetos, CardColor.silverFir,
      CardPosition.top, 'goldenEagle'),
  'Enzian_Pink': DetectorCard(
      CardId.gentiana, CardColor.pinus, CardPosition.bottom, 'gentian'),
  'Alpenfledermaus_Left_Lila': DetectorCard(CardId.hypsugoSavii,
      CardColor.larix, CardPosition.left, 'savisPipistrelle'),
  'Schneehase_Right_Pink': DetectorCard(
      CardId.lepusTimidus, CardColor.pinus, CardPosition.right, 'mountainHare'),
  'Holunder_Yellow': DetectorCard(
      CardId.sambucus, CardColor.linden, CardPosition.base, 'elderberry'),
  'Holunder_Red': DetectorCard(
      CardId.sambucus, CardColor.sycamore, CardPosition.base, 'elderberry'),
  'Holunder_LightGreen': DetectorCard(
      CardId.sambucus, CardColor.birch, CardPosition.base, 'elderberry'),
  'Holunder_Brown': DetectorCard(
      CardId.sambucus, CardColor.oak, CardPosition.base, 'elderberry'),
  'Haselnuss_Orange': DetectorCard(CardId.commonHazel, CardColor.horseChestnut,
      CardPosition.base, 'commonHazel'),
  'Haselnuss_Brown': DetectorCard(
      CardId.commonHazel, CardColor.oak, CardPosition.base, 'commonHazel'),
  'Haselnuss_Green': DetectorCard(
      CardId.commonHazel, CardColor.beech, CardPosition.base, 'commonHazel'),
  'Haselnuss_LightGreen': DetectorCard(
      CardId.commonHazel, CardColor.birch, CardPosition.base, 'commonHazel'),
  'Schlehdorn_Grey': DetectorCard(
      CardId.blackthorn, CardColor.douglasFir, CardPosition.base, 'blackthorn'),
  'Schlehdorn_LightGreen': DetectorCard(
      CardId.blackthorn, CardColor.birch, CardPosition.base, 'blackthorn'),
  'Schlehdorn_Blue': DetectorCard(
      CardId.blackthorn, CardColor.silverFir, CardPosition.base, 'blackthorn'),
  'Schlehdorn_Red': DetectorCard(
      CardId.blackthorn, CardColor.sycamore, CardPosition.base, 'blackthorn'),
  'Landkaertchen_Yellow': DetectorCard(
      CardId.mapButterfly, CardColor.linden, CardPosition.top, 'mapButterfly'),
  'Fingerhut_Grey': DetectorCard(
      CardId.digitalis, CardColor.douglasFir, CardPosition.bottom, 'digitalis'),
  'Landkaertchen_Red': DetectorCard(CardId.mapButterfly, CardColor.sycamore,
      CardPosition.top, 'mapButterfly'),
  'Brennnessel_LightGreen': DetectorCard(
      CardId.urtica, CardColor.birch, CardPosition.bottom, 'stingingNettle'),
  'Landkaertchen_Brown': DetectorCard(
      CardId.mapButterfly, CardColor.oak, CardPosition.top, 'mapButterfly'),
  'Gruenes-Heupferd_Blue': DetectorCard(CardId.greatGreenBushCricket,
      CardColor.silverFir, CardPosition.bottom, 'greatGreenBushCricket'),
  'Landkaertchen_Blue': DetectorCard(CardId.mapButterfly, CardColor.silverFir,
      CardPosition.top, 'mapButterfly'),
  'Schermaus_Red': DetectorCard(CardId.europeanWaterVole, CardColor.sycamore,
      CardPosition.bottom, 'waterVole'),
  'Elster_Green': DetectorCard(CardId.eurasianMagpie, CardColor.beech,
      CardPosition.top, 'eurasianMagpie'),
  'Fingerhut_LightGreen': DetectorCard(
      CardId.digitalis, CardColor.birch, CardPosition.bottom, 'digitalis'),
  'Elster_Blue': DetectorCard(CardId.eurasianMagpie, CardColor.silverFir,
      CardPosition.top, 'eurasianMagpie'),
  'Brennnessel_Orange': DetectorCard(CardId.urtica, CardColor.horseChestnut,
      CardPosition.bottom, 'stingingNettle'),
  'Elster_LightGreen': DetectorCard(CardId.eurasianMagpie, CardColor.birch,
      CardPosition.top, 'eurasianMagpie'),
  'Gruenes-Heupferd_Green': DetectorCard(CardId.greatGreenBushCricket,
      CardColor.beech, CardPosition.bottom, 'greatGreenBushCricket'),
  'Nachtigall_Green': DetectorCard(CardId.commonNightingale, CardColor.beech,
      CardPosition.top, 'nightingale'),
  'Fingerhut_Red': DetectorCard(
      CardId.digitalis, CardColor.sycamore, CardPosition.bottom, 'digitalis'),
  'Nachtigall_Brown': DetectorCard(
      CardId.commonNightingale, CardColor.oak, CardPosition.top, 'nightingale'),
  'Brennnessel_Red': DetectorCard(
      CardId.urtica, CardColor.sycamore, CardPosition.bottom, 'stingingNettle'),
  'Nachtigall_Orange': DetectorCard(CardId.commonNightingale,
      CardColor.horseChestnut, CardPosition.top, 'nightingale'),
  'Schermaus_Green': DetectorCard(CardId.europeanWaterVole, CardColor.beech,
      CardPosition.bottom, 'waterVole'),
  'Schleiereule_LightGreen': DetectorCard(
      CardId.barnOwl, CardColor.birch, CardPosition.top, 'barnOwl'),
  'Fingerhut_Brown': DetectorCard(
      CardId.digitalis, CardColor.oak, CardPosition.bottom, 'digitalis'),
  'Schleiereule_Red': DetectorCard(
      CardId.barnOwl, CardColor.sycamore, CardPosition.top, 'barnOwl'),
  'Gruenes-Heupferd_Brown': DetectorCard(CardId.greatGreenBushCricket,
      CardColor.oak, CardPosition.bottom, 'greatGreenBushCricket'),
  'Bache_Left_LightGreen': DetectorCard(CardId.wildBoarFemale, CardColor.birch,
      CardPosition.left, 'wildBoarFemale'),
  'Bienenschwarm_Right_Red': DetectorCard(
      CardId.beehive, CardColor.sycamore, CardPosition.right, 'beeSwarm'),
  'Wisent_Left_Brown': DetectorCard(
      CardId.europeanBison, CardColor.oak, CardPosition.left, 'europeanBison'),
  'Bache_Right_Red': DetectorCard(CardId.wildBoarFemale, CardColor.sycamore,
      CardPosition.right, 'wildBoarFemale'),
  'Bache_Left_Blue': DetectorCard(CardId.wildBoarFemale, CardColor.silverFir,
      CardPosition.left, 'wildBoarFemale'),
  'Wildkatze_Right_Orange': DetectorCard(CardId.europeanWildcat,
      CardColor.horseChestnut, CardPosition.right, 'europeanWildcat'),
  'Zwergfledermaus_Left_Yellow': DetectorCard(CardId.commonPipistrelle,
      CardColor.linden, CardPosition.left, 'commonPipistrelle'),
  'Frischling-Waldrand_Right_Blue': DetectorCard(CardId.squeakerEdge,
      CardColor.silverFir, CardPosition.right, 'squeakerWE'),
  'Frischling-Waldrand_Left_Orange': DetectorCard(CardId.squeakerEdge,
      CardColor.horseChestnut, CardPosition.left, 'squeakerWE'),
  'Schnake_Right_Green': DetectorCard(
      CardId.mosquito, CardColor.beech, CardPosition.right, 'craneFly'),
  'Waldiltis_Left_Blue': DetectorCard(CardId.europeanPolecat,
      CardColor.silverFir, CardPosition.left, 'europeanPolecat'),
  'Frischling-Waldrand_Right_Grey': DetectorCard(CardId.squeakerEdge,
      CardColor.douglasFir, CardPosition.right, 'squeakerWE'),
  'Bienenschwarm_Left_Green': DetectorCard(
      CardId.beehive, CardColor.beech, CardPosition.left, 'beeSwarm'),
  'Zwergfledermaus_Right_Red': DetectorCard(CardId.commonPipistrelle,
      CardColor.sycamore, CardPosition.right, 'commonPipistrelle'),
  'Wildkatze_Left_Brown': DetectorCard(CardId.europeanWildcat, CardColor.oak,
      CardPosition.left, 'europeanWildcat'),
  'Bienenschwarm_Right_LightGreen': DetectorCard(
      CardId.beehive, CardColor.birch, CardPosition.right, 'beeSwarm'),
  'Zwergfledermaus_Left_LightGreen': DetectorCard(CardId.commonPipistrelle,
      CardColor.birch, CardPosition.left, 'commonPipistrelle'),
  'Wisent_Right_Green': DetectorCard(CardId.europeanBison, CardColor.beech,
      CardPosition.right, 'europeanBison'),
  'Wisent_Left_Green': DetectorCard(CardId.europeanBison, CardColor.beech,
      CardPosition.left, 'europeanBison'),
  'Waldiltis_Right_Red': DetectorCard(CardId.europeanPolecat,
      CardColor.sycamore, CardPosition.right, 'europeanPolecat'),
  'Schnake_Left_LightGreen': DetectorCard(
      CardId.mosquito, CardColor.birch, CardPosition.left, 'craneFly'),
  'Waldiltis_Right_Brown': DetectorCard(CardId.europeanPolecat, CardColor.oak,
      CardPosition.right, 'europeanPolecat'),
  'Wildkatze_Left_Red': DetectorCard(CardId.europeanWildcat, CardColor.sycamore,
      CardPosition.left, 'europeanWildcat'),
  'Schnake_Right_Brown': DetectorCard(
      CardId.mosquito, CardColor.oak, CardPosition.right, 'craneFly'),
};
