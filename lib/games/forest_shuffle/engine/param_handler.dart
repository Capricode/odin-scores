// Translated to Dart from ForestDetector src/model/param-handler.ts (MIT).
// See THIRD_PARTY_NOTICES.md.

import 'card_id.dart';
import 'card_position.dart';
import 'forest.dart';
import 'gl_cards.dart';

typedef _Handler = int Function(Forest forest);

/// Derives glaures card params (e.g. "chaffinches atop a beech") from where
/// the detected cards sit in the forest.
class ParamHandler {
  const ParamHandler();

  /// Adds the derived value for [param] of [card].
  void handleParam(GlCard card, String param, Forest forest) {
    final handler = _handlers[param];
    if (handler == null) {
      throw RangeError(
          "Parameter '$param' has no handler defined in ParamHandler");
    }
    card.params[param] = card.param(param) + handler(forest);
  }

  static int _nothingToDo(Forest forest) => 0;

  static final Map<String, _Handler> _handlers = {
    // Computed from all forests while scoring.
    'hasMostLindens': _nothingToDo,
    'hasMostTrees': _nothingToDo,

    'fullyOccupiedTrees': _fullyOccupiedTrees, // beechMarten
    'cardsAttachedToSilverFirs': _cardsAttachedToSilverFirs,
    'sharingACardSlot': _sharingACardSlot, // commonToad
    'europeanPolecatAloneOnTreeOrShrub': _europeanPolecatAlone,
    'chaffinchesAtopABeech': (f) =>
        _countCardsOnBase(f, CardId.chaffinch, const [CardId.beech]),
    // The original counts CHAFFINCH here, which can't be intended.
    'nightingalesAtopAShrub': (f) => _countCardsOnBase(
        f,
        CardId.commonNightingale,
        const [CardId.sambucus, CardId.commonHazel, CardId.blackthorn]),
    'redSquirrelsAtopAnOak': (f) =>
        _countCardsOnBase(f, CardId.redSquirrel, const [CardId.oak]),
    'batOnTheOtherSide': _batOnTheOtherSide,

    // violetCarpenterBee
    'onABeech': (f) =>
        _countCardsOnBase(f, CardId.violetCarpenterBee, const [CardId.beech]),
    'onAHorseChestnut': (f) => _countCardsOnBase(
        f, CardId.violetCarpenterBee, const [CardId.horseChestnut]),
    'onALinden': (f) =>
        _countCardsOnBase(f, CardId.violetCarpenterBee, const [CardId.linden]),

    // Tree symbol counts are filled in by Forest.setCards.
    'beechCount': _nothingToDo,
    'oakCount': _nothingToDo,
    'birchCount': _nothingToDo,
    'horseChestnutCount': _nothingToDo,
    'lindenCount': _nothingToDo,
    'silverFirCount': _nothingToDo,
    'stonePineCount': _nothingToDo,
    'europeanLarchCount': _nothingToDo,
    'douglasFirCount': _nothingToDo,
  };

  static Iterable<ForestCard> _bases(Forest f) =>
      f.forestCards.where((c) => c.card.position == CardPosition.base);

  static Iterable<ForestCard> _ofSpeci(Forest f, CardId speci) =>
      f.forestCards.where((c) => c.card.speci == speci);

  /// True when base, top, bottom, left and right are all taken.
  static bool _isFullyOccupied(Forest f, int baseIndex) {
    final occupied = f
        .getCardsOnBase(baseIndex, returnBase: true)
        .map((c) => c.card.position)
        .toSet();
    return occupied.length == CardPosition.values.length;
  }

  static int _fullyOccupiedTrees(Forest f) =>
      _bases(f).where((b) => _isFullyOccupied(f, b.baseIndex)).length;

  static int _cardsAttachedToSilverFirs(Forest f) =>
      _ofSpeci(f, CardId.silverFir)
          .fold(0, (sum, c) => sum + f.getCardsOnBase(c.baseIndex).length);

  static int _sharingACardSlot(Forest f) => _ofSpeci(f, CardId.commonToad)
      .where((c) =>
          f.getCardsOnBase(c.baseIndex, speci: CardId.commonToad).length > 1)
      .length;

  static int _europeanPolecatAlone(Forest f) =>
      _ofSpeci(f, CardId.europeanPolecat)
          .where((c) => f.getCardsOnBase(c.baseIndex).length == 1)
          .length;

  static int _countCardsOnBase(Forest f, CardId speci, List<CardId> baseIds) =>
      _ofSpeci(f, speci)
          .where((c) => baseIds.contains(f.getBase(c.baseIndex).card.speci))
          .length;

  // Counts every bat on the dormouse's tree, whichever side it is on.
  static int _batOnTheOtherSide(Forest f) {
    var count = 0;
    for (final dormouse in _ofSpeci(f, CardId.europeanFatDormouse)) {
      for (final c in f.getCardsOnBase(dormouse.baseIndex)) {
        if (f.findCard(c.card.glCardName).def.hasSymbol('bat')) count++;
      }
    }
    return count;
  }
}
