/// Tree symbol in a card corner. [label] is the detector's colour name,
/// [glSymbol] the matching glaures symbol (used for `<symbol>Count`).
enum CardColor {
  none('', 'NONE'), // tree sapling
  linden('Yellow', 'linden'),
  oak('Brown', 'oak'),
  silverFir('Blue', 'silverFir'),
  birch('LightGreen', 'birch'),
  beech('Green', 'beech'),
  sycamore('Red', 'sycamore'),
  douglasFir('Grey', 'douglasFir'),
  horseChestnut('Orange', 'horseChestnut'),
  larix('Lila', 'europeanLarch'),
  pinus('Pink', 'stonePine');

  const CardColor(this.label, this.glSymbol);

  final String label;
  final String glSymbol;

  static CardColor fromLabel(String label) =>
      values.firstWhere((c) => c.label == label,
          orElse: () => throw ArgumentError.value(label, 'label'));
}
