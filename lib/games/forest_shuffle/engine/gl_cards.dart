// Card definitions and scoring rules translated to Dart from
// glaures/forestshuffle src/model/card-*.js (Apache 2.0).
// See THIRD_PARTY_NOTICES.md.

import 'dart:math';

import 'gl_forest.dart';

/// Placement as used by glaures. Trees have none, shrubs use [tree].
enum GlPosition { top, bottom, side, tree }

typedef PointsRule = int Function(GlCard card, GlForest forest);

int _noPoints(GlCard card, GlForest forest) => 0;

/// Static description of a glaures card.
class GlCardDef {
  final String name;
  final GlPosition? position;
  final List<String> symbols;

  /// Names of the card's params; all start at 0 and are filled in by
  /// the param handler.
  final List<String> params;
  final PointsRule rule;

  const GlCardDef(
    this.name, {
    this.position,
    required this.symbols,
    this.params = const [],
    this.rule = _noPoints,
  });

  bool hasSymbol(String symbol) => symbols.contains(symbol);
}

/// Per-forest state of one card: how many are played, their points and the
/// current param values.
class GlCard {
  final GlCardDef def;
  int count = 0;
  int points = 0;
  final Map<String, int> params;

  GlCard(this.def) : params = {for (final p in def.params) p: 0};

  String get name => def.name;
  GlPosition? get position => def.position;
  List<String> get symbols => def.symbols;

  int param(String name) => params[name]!;

  void recalculatePoints(GlForest forest) => points = def.rule(this, forest);
}

int _vcbParam(GlForest f, String name) =>
    f.findCard('violetCarpenterBee').param(name);

int _differentTreeTypes(GlForest f) => f.cards
    .where((c) =>
        c.def.hasSymbol('tree') && c.name != 'treeSaplings' && c.count > 0)
    .length;

int _batPoints(GlCard c, GlForest f) =>
    f.countDistinctBySymbol('bat') >= 3 ? f.countByName(c.name) * 5 : 0;

int _numberOfHare(GlForest f) =>
    f.countByName('europeanHare') + f.countByName('mountainHare');

int _squeakers(GlForest f) =>
    f.countByName('squeaker') + f.countByName('squeakerWE');

const _pointsForButterflySet = [0, 0, 3, 6, 12, 20, 35, 55];

/// Points for butterfly sets: repeatedly take one of each distinct butterfly.
int calculateButterflyPoints(GlForest forest) {
  var butterflies = forest.cards
      .where((c) => c.def.hasSymbol('butterfly') && c.count > 0)
      .map((c) => c.count)
      .toList();
  var points = 0;
  while (butterflies.isNotEmpty) {
    points += _pointsForButterflySet[butterflies.length];
    butterflies = butterflies.map((b) => b - 1).where((b) => b > 0).toList();
  }
  return points;
}

final List<GlCardDef> glCards = [
  // ---------------------------------------------------------------- trees
  GlCardDef('beech', symbols: const ['tree', 'beech'], rule: (c, f) {
    final addCount = _vcbParam(f, 'onABeech');
    return c.count + addCount >= 4 ? c.count * 5 : 0;
  }),
  GlCardDef('birch', symbols: const ['tree', 'birch'], rule: (c, f) => c.count),
  GlCardDef('douglasFir',
      symbols: const ['tree', 'douglasFir'], rule: (c, f) => c.count * 5),
  GlCardDef('horseChestnut', symbols: const ['tree', 'horseChestnut'],
      rule: (c, f) {
    final count = c.count + _vcbParam(f, 'onAHorseChestnut');
    return min(count * count, 49);
  }),
  GlCardDef('linden',
      symbols: const ['tree', 'linden'],
      params: const ['hasMostLindens'],
      rule: (c, f) => c.count * (f.hasMostOfName('linden') ? 3 : 1)),
  GlCardDef('oak',
      symbols: const ['tree', 'oak'],
      rule: (c, f) => _differentTreeTypes(f) >= 8 ? c.count * 10 : 0),
  GlCardDef('silverFir',
      symbols: const ['tree', 'silverFir'],
      params: const ['cardsAttachedToSilverFirs'],
      rule: (c, f) => c.param('cardsAttachedToSilverFirs') * 2),
  GlCardDef('sycamore',
      symbols: const ['tree', 'sycamore'],
      rule: (c, f) => f.countByName('sycamore') * f.countBySymbol('tree')),
  GlCardDef('europeanLarch',
      symbols: const ['tree', 'europeanLarch', 'alps'],
      rule: (c, f) => c.count * 3),
  GlCardDef('stonePine',
      symbols: const ['tree', 'stonePine', 'alps'],
      rule: (c, f) => c.count * f.countBySymbol('alps')),
  const GlCardDef('treeSaplings', symbols: ['tree']),
  GlCardDef('downyBirch', symbols: const ['tree'], rule: (c, f) => c.count),

  // ---------------------------------------------------------------- birds
  GlCardDef('bullfinch',
      position: GlPosition.top,
      symbols: const ['bird'],
      rule: (c, f) => c.count * f.countBySymbol('insect') * 2),
  GlCardDef('chaffinch',
      position: GlPosition.top,
      symbols: const ['bird'],
      params: const ['chaffinchesAtopABeech'],
      rule: (c, f) => c.param('chaffinchesAtopABeech') * 5),
  GlCardDef('eurasianJay',
      position: GlPosition.top,
      symbols: const ['bird'],
      rule: (c, f) => c.count * 3),
  GlCardDef('goshawk',
      position: GlPosition.top,
      symbols: const ['bird'],
      rule: (c, f) => c.count * f.countBySymbol('bird') * 3),
  GlCardDef('greatSpottedWoodpecker',
      position: GlPosition.top,
      symbols: const ['bird'],
      params: const ['hasMostTrees'],
      rule: (c, f) => f.hasMostTrees() ? c.count * 10 : 0),
  GlCardDef('tawnyOwl',
      position: GlPosition.top,
      symbols: const ['bird'],
      rule: (c, f) => c.count * 5),
  GlCardDef('capercaillie',
      position: GlPosition.side,
      symbols: const ['bird', 'alps'],
      rule: (c, f) => c.count * f.countBySymbol('plant')),
  GlCardDef('goldenEagle',
      position: GlPosition.top,
      symbols: const ['bird', 'alps'],
      rule: (c, f) =>
          c.count *
          (f.countBySymbol('pawedAnimal') + f.countBySymbol('amphibian'))),
  GlCardDef('beardedVulture',
      position: GlPosition.top,
      symbols: const ['bird', 'alps'],
      rule: (c, f) => c.count * f.caveCount),
  GlCardDef('commonRaven',
      position: GlPosition.top,
      symbols: const ['bird', 'alps'],
      rule: (c, f) => c.count * 5),
  GlCardDef('eurasianMagpie',
      position: GlPosition.top,
      symbols: const ['bird', 'woodlandEdge'],
      rule: (c, f) => c.count * 3),
  GlCardDef('nightingale',
      position: GlPosition.top,
      symbols: const ['bird', 'woodlandEdge'],
      params: const ['nightingalesAtopAShrub'],
      rule: (c, f) => c.param('nightingalesAtopAShrub') * 5),
  GlCardDef('barnOwl',
      position: GlPosition.top,
      symbols: const ['bird', 'woodlandEdge'],
      rule: (c, f) => 3 * c.count * f.countBySymbol('bat')),
  GlCardDef('whinchat',
      symbols: const ['bird'],
      rule: (c, f) => c.count * f.countBySymbol('plant')),

  // ----------------------------------------------------------- butterflies
  // Scored as sets by calculateButterflyPoints.
  for (final name in const [
    'camberwellBeauty',
    'peacockButterfly',
    'silverWashedFritillary',
    'purpleEmperor',
    'largeTortoiseshell',
  ])
    GlCardDef(name,
        position: GlPosition.top, symbols: const ['butterfly', 'insect']),
  const GlCardDef('phoebusApollo',
      position: GlPosition.top, symbols: ['butterfly', 'insect', 'alps']),
  const GlCardDef('mapButterfly',
      position: GlPosition.top,
      symbols: ['butterfly', 'insect', 'woodlandEdge']),

  // ---------------------------------------------------------- other (top)
  GlCardDef('redSquirrel',
      position: GlPosition.top,
      symbols: const ['pawedAnimal'],
      params: const ['redSquirrelsAtopAnOak'],
      rule: (c, f) => c.param('redSquirrelsAtopAnOak') * 5),

  // ---------------------------------------------------------------- plants
  GlCardDef('blackberries',
      position: GlPosition.bottom,
      symbols: const ['plant'],
      rule: (c, f) => c.count * f.countBySymbol('plant') * 2),
  GlCardDef('treeFerns',
      position: GlPosition.bottom,
      symbols: const ['plant'],
      rule: (c, f) => c.count * f.countBySymbol('amphibian') * 6),
  GlCardDef('wildStrawberries',
      position: GlPosition.bottom,
      symbols: const ['plant'],
      rule: (c, f) => _differentTreeTypes(f) >= 8 ? c.count * 10 : 0),
  GlCardDef('moss',
      position: GlPosition.bottom,
      symbols: const ['plant'],
      rule: (c, f) =>
          f.countTreesIncludingVioletCarpenterBee() >= 10 ? c.count * 10 : 0),
  GlCardDef('edelweiss',
      position: GlPosition.bottom,
      symbols: const ['plant', 'alps'],
      rule: (c, f) => c.count * 3),
  GlCardDef('blueberry',
      position: GlPosition.bottom,
      symbols: const ['plant', 'alps'],
      rule: (c, f) => c.count * 2 * f.countDistinctBySymbol('bird')),
  GlCardDef('gentian',
      position: GlPosition.bottom,
      symbols: const ['plant', 'alps'],
      rule: (c, f) => c.count * 3 * f.countBySymbol('butterfly')),
  GlCardDef('digitalis',
      position: GlPosition.bottom,
      symbols: const ['plant', 'woodlandEdge'], rule: (c, f) {
    const pointsByDistinctPlants = [0, 1, 3, 6, 10, 15];
    return c.count *
        pointsByDistinctPlants[min(5, f.countDistinctBySymbol('plant'))];
  }),
  GlCardDef('stingingNettle',
      position: GlPosition.bottom,
      symbols: const ['plant', 'woodlandEdge'],
      rule: (c, f) => 2 * c.count * f.countBySymbol('butterfly')),
  GlCardDef('maretak',
      position: GlPosition.top,
      symbols: const ['plant', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('plant')),
  GlCardDef('bostulp',
      position: GlPosition.bottom,
      symbols: const ['plant', 'woodlandEdge'],
      rule: (c, f) => 3 * c.count),

  // ------------------------------------------------------------- mushrooms
  // Mushrooms only score via the cave.
  for (final name in const [
    'chanterelle',
    'flyagaric',
    'parasolMushroom',
    'pennyBun',
  ])
    GlCardDef(name, position: GlPosition.bottom, symbols: const ['mushroom']),
  const GlCardDef('blackTrumpet',
      position: GlPosition.bottom, symbols: ['mushroom', 'alps']),

  // ------------------------------------------------------------ amphibians
  GlCardDef('commonToad',
      position: GlPosition.bottom,
      symbols: const ['amphibian'],
      params: const ['sharingACardSlot'],
      rule: (c, f) => c.param('sharingACardSlot') * 5),
  GlCardDef('pondTurtle',
      position: GlPosition.bottom,
      symbols: const ['amphibian'],
      rule: (c, f) => c.count * 5),
  GlCardDef('treeFrog',
      position: GlPosition.bottom,
      symbols: const ['amphibian'],
      rule: (c, f) => c.count * f.countByName('gnat') * 5),
  GlCardDef('fireSalamander',
      position: GlPosition.bottom,
      symbols: const ['amphibian'],
      rule: (c, f) => const [0, 5, 15, 25][min(3, c.count)]),
  GlCardDef('alpineNewt',
      position: GlPosition.bottom,
      symbols: const ['amphibian', 'alps'],
      rule: (c, f) => c.count * 2 * f.countBySymbol('insect')),

  // --------------------------------------------------------------- insects
  GlCardDef('gnat',
      position: GlPosition.side,
      symbols: const ['insect'],
      rule: (c, f) => f.countByName('gnat') * f.countBySymbol('bat')),
  GlCardDef('fireflies',
      position: GlPosition.bottom,
      symbols: const ['insect'],
      rule: (c, f) => const [0, 0, 10, 15, 20][min(4, c.count)]),
  GlCardDef('woodAnt',
      position: GlPosition.bottom,
      symbols: const ['insect'],
      rule: (c, f) => c.count * f.countByPosition(GlPosition.bottom) * 2),
  GlCardDef('stagBeetle',
      position: GlPosition.bottom,
      symbols: const ['insect'],
      rule: (c, f) => c.count * f.countBySymbol('pawedAnimal')),
  // Its params count as extra trees of that kind for other cards' rules.
  const GlCardDef('violetCarpenterBee',
      position: GlPosition.side,
      symbols: ['insect'],
      params: ['onABeech', 'onAHorseChestnut', 'onALinden']),
  GlCardDef('greatGreenBushCricket',
      position: GlPosition.bottom,
      symbols: const ['insect', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('insect')),
  GlCardDef('beeSwarm',
      position: GlPosition.side,
      symbols: const ['insect', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('plant')),
  GlCardDef('craneFly',
      position: GlPosition.side,
      symbols: const ['insect', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('bat')),

  // -------------------------------------------------------- pawed animals
  GlCardDef('hedgehog',
      position: GlPosition.bottom,
      symbols: const ['pawedAnimal'],
      rule: (c, f) => c.count * f.countBySymbol('butterfly') * 2),
  const GlCardDef('mole',
      position: GlPosition.bottom, symbols: ['pawedAnimal']),
  GlCardDef('beechMarten',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      params: const ['fullyOccupiedTrees'],
      rule: (c, f) => c.count * 5 * c.param('fullyOccupiedTrees')),
  const GlCardDef('brownBear',
      position: GlPosition.side, symbols: ['pawedAnimal']),
  GlCardDef('europeanBadger',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      rule: (c, f) => c.count * 2),
  GlCardDef('europeanFatDormouse',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      params: const ['batOnTheOtherSide'],
      rule: (c, f) => c.param('batOnTheOtherSide') * 15),
  GlCardDef('europeanHare',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      rule: (c, f) => c.count * _numberOfHare(f)),
  GlCardDef('lynx', position: GlPosition.side, symbols: const ['pawedAnimal'],
      rule: (c, f) {
    final roeDeer = f.countByName('roeDeerBeech') +
        f.countByName('roeDeerBirch') +
        f.countByName('roeDeerHorseChestnut') +
        f.countByName('roeDeerLinden') +
        f.countByName('roeDeerSilverFir');
    return roeDeer > 0 ? c.count * 10 : 0;
  }),
  const GlCardDef('raccoon',
      position: GlPosition.side, symbols: ['pawedAnimal']),
  GlCardDef('redFox',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      rule: (c, f) => c.count * _numberOfHare(f) * 2),
  GlCardDef('wolf',
      position: GlPosition.side,
      symbols: const ['pawedAnimal'],
      rule: (c, f) => c.count * 5 * f.countBySymbol('deer')),
  GlCardDef('alpineMarmot',
      position: GlPosition.side,
      symbols: const ['pawedAnimal', 'alps'],
      rule: (c, f) => c.count * 3 * f.countDistinctBySymbol('plant')),
  GlCardDef('mountainHare',
      position: GlPosition.side,
      symbols: const ['pawedAnimal', 'alps'],
      rule: (c, f) => c.count * _numberOfHare(f)),
  const GlCardDef('waterVole',
      position: GlPosition.bottom, symbols: ['pawedAnimal', 'woodlandEdge']),
  GlCardDef('europeanWildcat',
      position: GlPosition.side,
      symbols: const ['pawedAnimal', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('woodlandEdge')),
  GlCardDef('europeanPolecat',
      position: GlPosition.side,
      symbols: const ['pawedAnimal', 'woodlandEdge'],
      params: const ['europeanPolecatAloneOnTreeOrShrub'],
      rule: (c, f) => 10 * c.param('europeanPolecatAloneOnTreeOrShrub')),
  GlCardDef('meeps',
      position: GlPosition.side,
      symbols: const ['pawedAnimal', 'woodlandEdge'],
      rule: (c, f) => c.count * f.countBySymbol('woodlandEdge')),

  // ------------------------------------------------------------------ bats
  for (final name in const [
    'barbastelleBat',
    'bechsteinsBat',
    'brownLongEaredBat',
    'greaterHorseshoeBat',
  ])
    GlCardDef(name,
        position: GlPosition.side, symbols: const ['bat'], rule: _batPoints),
  const GlCardDef('savisPipistrelle',
      position: GlPosition.side, symbols: ['bat', 'alps'], rule: _batPoints),
  const GlCardDef('duererBat',
      position: GlPosition.side, symbols: ['bat'], rule: _batPoints),
  const GlCardDef('commonPipistrelle',
      position: GlPosition.side,
      symbols: ['bat', 'woodlandEdge'],
      rule: _batPoints),

  // ------------------------------------------------- deer & cloven-hoofed
  GlCardDef('fallowDeer',
      position: GlPosition.side,
      symbols: const ['deer', 'clovenHoofedAnimal'],
      rule: (c, f) =>
          f.countByName('fallowDeer') *
          3 *
          f.countBySymbol('clovenHoofedAnimal')),
  GlCardDef('redDeer',
      position: GlPosition.side,
      symbols: const ['deer', 'clovenHoofedAnimal'],
      rule: (c, f) =>
          f.countByName('redDeer') *
          (f.countBySymbol('plant') + f.countBySymbol('tree'))),
  for (final type in const [
    'beech',
    'linden',
    'silverFir',
    'horseChestnut',
    'birch',
  ])
    _roeDeer(type),
  GlCardDef('squeaker',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal'],
      rule: (c, f) => c.count),
  GlCardDef('squeakerWE',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal', 'woodlandEdge'],
      rule: (c, f) => c.count),
  GlCardDef('wildBoar',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal'],
      rule: (c, f) => c.count * 10 * (_squeakers(f) > 0 ? 1 : 0)),
  GlCardDef('wildBoarFemale',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal', 'woodlandEdge'],
      rule: (c, f) => c.count * 10 * _squeakers(f)),
  for (final type in const ['douglasFir', 'europeanLarch', 'stonePine'])
    GlCardDef('chamois${type[0].toUpperCase()}${type.substring(1)}',
        position: GlPosition.side,
        symbols: ['clovenHoofedAnimal', 'alps', type],
        params: ['${type}Count'],
        rule: (c, f) => c.count * f.typeCount(type) * 3),
  GlCardDef('steinbock',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal', 'alps'],
      rule: (c, f) => c.count * 10),
  GlCardDef('europeanBison',
      position: GlPosition.side,
      symbols: const ['clovenHoofedAnimal', 'woodlandEdge'],
      params: const ['beechCount', 'oakCount'],
      rule: (c, f) =>
          2 * c.count * (f.typeCount('beech') + f.typeCount('oak'))),

  // ---------------------------------------------------------------- shrubs
  for (final name in const ['elderberry', 'commonHazel', 'blackthorn'])
    GlCardDef(name,
        position: GlPosition.tree, symbols: const ['shrub', 'woodlandEdge']),
];

GlCardDef _roeDeer(String type) => GlCardDef(
      'roeDeer${type[0].toUpperCase()}${type.substring(1)}',
      position: GlPosition.side,
      symbols: const ['deer', 'clovenHoofedAnimal'],
      params: ['${type}Count'],
      rule: (c, f) => c.count * f.typeCount(type) * 3,
    );
