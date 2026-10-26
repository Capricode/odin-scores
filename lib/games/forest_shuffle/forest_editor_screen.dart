import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'card_names.dart';
import 'card_symbols.dart';
import 'detector/card_detector.dart';
import 'engine/forest_shuffle_engine.dart';
import 'forest_shuffle_game.dart';

/// Enter one player's forest: take a photo to detect the cards, then fix
/// what the detector got wrong and add the cards in the cave.
class ForestEditorScreen extends StatefulWidget {
  final String playerName;
  final ForestEntry initial;

  /// The other players' forests, so the preview includes bonuses that
  /// compare forests (most lindens, most trees).
  final List<PlayerForest> otherForests;

  /// Off while the game runs, so the scores stay secret until the game is
  /// finished; on when correcting a forest afterwards.
  final bool showScore;

  const ForestEditorScreen({
    super.key,
    required this.playerName,
    required this.initial,
    this.otherForests = const [],
    this.showScore = false,
  });

  @override
  State<ForestEditorScreen> createState() => _ForestEditorScreenState();
}

class _ForestEditorScreenState extends State<ForestEditorScreen> {
  late ForestEntry _entry = widget.initial;

  Uint8List? _photo;
  Size? _photoSize;
  int _quarterTurns = 0;
  List<Detection> _detections = [];
  List<Prediction> _unattached = [];
  String? _status;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Start loading the model while the player takes the photo.
    CardDetector.instance.warmUp().catchError((_) {});
  }

  ForestScore get _score => scoreForests([
        PlayerForest(name: widget.playerName, cards: _entry.cards, caveCount: _entry.caveCount),
        ...widget.otherForests,
      ]).first;

  // ----------------------------------------------------------------- photo

  Future<void> _pickPhoto(ImageSource source) async {
    if (_entry.cards.isNotEmpty) {
      final ok = await _confirm(
        'Replace the cards?',
        'The cards found on the new photo replace the ${_entry.cards.length} cards entered now.',
        'Replace',
      );
      if (ok != true) return;
    }
    final XFile? file;
    try {
      // Phone photos (12 MP+) are scaled down to keep memory low; the model
      // only looks at 640x640 anyway.
      file = await ImagePicker().pickImage(source: source, maxWidth: 2048, maxHeight: 2048);
    } catch (e) {
      setState(() => _error = 'Could not open the ${source == ImageSource.camera ? 'camera' : 'photos'}: $e');
      return;
    }
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    if (!mounted) return;
    setState(() {
      _photo = bytes;
      _photoSize = Size(image.width.toDouble(), image.height.toDouble());
      _quarterTurns = 0;
    });
    image.dispose();
    await _detect();
  }

  Future<void> _rotate() async {
    setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
    await _detect();
  }

  Future<void> _detect() async {
    final photo = _photo;
    if (photo == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Loading the card detector (38 MB, first time only)…';
    });
    try {
      await CardDetector.instance.warmUp();
      if (!mounted) return;
      setState(() => _status = 'Finding cards…');
      final detections = await CardDetector.instance.detect(photo, quarterTurns: _quarterTurns);
      final assembly = ForestAssembler.assemble([
        for (final d in detections)
          Prediction(
            label: d.label,
            confidence: d.confidence,
            x: d.x,
            y: d.y,
            width: d.width,
            height: d.height,
          ),
      ]);
      if (!mounted) return;
      setState(() {
        _detections = detections;
        _unattached = assembly.unattached;
        _entry = _entry.copyWith(cards: assembly.cards);
        _status = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = null;
        _error = 'Card detection failed: $e\nYou can still add the cards by hand.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ----------------------------------------------------------------- cards

  void _removeCard(ForestCard card) {
    setState(() {
      final cards = [..._entry.cards];
      if (card.card.position == CardPosition.base) {
        cards.removeWhere((c) => c.baseIndex == card.baseIndex);
      } else {
        cards.remove(card);
      }
      _entry = _entry.copyWith(cards: cards);
    });
  }

  Future<void> _addCard({int? baseIndex}) async {
    final label = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (_) => _CardPicker(trees: baseIndex == null),
    );
    if (label == null) return;
    setState(() {
      final index = baseIndex ??
          (_entry.cards.isEmpty
              ? 0
              : _entry.cards.map((c) => c.baseIndex).reduce((a, b) => a > b ? a : b) + 1);
      _entry = _entry.copyWith(cards: [..._entry.cards, forestCard(label, index)]);
    });
  }

  Future<bool?> _confirm(String title, String message, String confirmLabel) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- build

  Widget _buildPhoto() {
    final photo = _photo;
    final size = _photoSize;
    if (photo == null || size == null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Lay out the forest so every card is visible, then take a photo from above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Take photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final rotated = _quarterTurns.isOdd ? size.flipped : size;
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: AspectRatio(
            aspectRatio: rotated.width / rotated.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotatedBox(
                  quarterTurns: _quarterTurns,
                  child: Image.memory(photo, fit: BoxFit.fill, cacheWidth: 1000),
                ),
                CustomPaint(painter: _DetectionPainter(_detections)),
                if (_busy) const ColoredBox(color: Colors.black54),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _busy ? null : _rotate,
              icon: const Icon(Icons.rotate_right),
              label: const Text('Rotate'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
            ),
            TextButton.icon(
              onPressed: _busy ? null : () => _pickPhoto(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Retake'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
            ),
            TextButton.icon(
              onPressed: _busy ? null : () => _pickPhoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Other photo'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_status != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_status!, style: const TextStyle(color: Colors.white70))),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_error!, style: TextStyle(color: Colors.red.shade300)),
          ),
        if (_unattached.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Not placed (no tree next to it): '
              '${_unattached.map((p) => _labelName(p.label)).join(', ')}. '
              'Add them to the right tree by hand if they are real.',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 13),
            ),
          ),
        if (_photo != null && _status == null && _error == null)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Check the cards below against the forest. Remove wrong ones and add missing ones.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildCave() {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            const Expanded(
              child: Text('Cards in the cave', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            IconButton(
              onPressed: _entry.caveCount == 0
                  ? null
                  : () => setState(() => _entry = _entry.copyWith(caveCount: _entry.caveCount - 1)),
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white,
              tooltip: 'One card less',
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${_entry.caveCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _entry = _entry.copyWith(caveCount: _entry.caveCount + 1)),
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.white,
              tooltip: 'One card more',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree(int baseIndex, int number) {
    final cards = _entry.cards.where((c) => c.baseIndex == baseIndex).toList();
    final base = cards.firstWhere((c) => c.card.position == CardPosition.base);
    const order = [CardPosition.top, CardPosition.left, CardPosition.right, CardPosition.bottom];
    final attached = cards.where((c) => c != base).toList()
      ..sort((a, b) => order.indexOf(a.card.position).compareTo(order.indexOf(b.card.position)));

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SymbolDot(base.color, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$number · ${_labelName(base.label)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _addCard(baseIndex: baseIndex),
                  icon: const Icon(Icons.add, color: Colors.white70),
                  tooltip: 'Add a card to this tree',
                ),
                IconButton(
                  onPressed: () => _removeCard(base),
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  tooltip: 'Remove the tree and its cards',
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in attached)
                  InputChip(
                    avatar: SymbolDot(c.color, size: 14),
                    label: Text(
                      '${_positionName(c.card.position)}: ${_labelName(c.label)}'
                      '${c.color == CardColor.none ? '' : ' · ${symbolName(c.color)}'}',
                    ),
                    onDeleted: () => _removeCard(c),
                    backgroundColor: Colors.grey[850],
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
                    deleteIconColor: Colors.white54,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.showScore ? _score : null;
    final bases = _entry.baseIndices;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 44,
        title: Text(widget.playerName, style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context, _entry),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildPhoto(),
          _buildMessages(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              [
                if (score != null) '${score.total} points',
                '${_entry.cards.length} cards on ${bases.length} trees',
              ].join(' · '),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
            child: Text(
              score == null
                  ? 'Points are revealed when the game is finished.'
                  : 'Trees ${score.trees} · Top ${score.top} · Bottom ${score.bottom} · '
                      'Sides ${score.side} · Cave ${score.cave}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          _buildCave(),
          for (var i = 0; i < bases.length; i++) _buildTree(bases[i], i + 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: OutlinedButton.icon(
              onPressed: () => _addCard(),
              icon: const Icon(Icons.park),
              label: const Text('Add tree or shrub'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _positionName(CardPosition p) => switch (p) {
      CardPosition.base => 'Tree',
      CardPosition.top => 'Top',
      CardPosition.bottom => 'Bottom',
      CardPosition.left => 'Left',
      CardPosition.right => 'Right',
    };

String _labelName(String label) {
  final card = detectorCards[label];
  return card == null ? label : cardName(card.glCardName);
}

/// One card type to pick in the first step: a species at a position. Its
/// variants (detector labels) differ in the tree symbol.
class _CardChoice {
  final String name;
  final CardPosition position;
  final List<MapEntry<String, DetectorCard>> variants;

  _CardChoice(this.name, this.position, this.variants);
}

/// Picks a card type: trees and shrubs, or the cards attached to them.
/// First the card, then (if it comes with several) its tree symbol.
class _CardPicker extends StatefulWidget {
  final bool trees;

  const _CardPicker({required this.trees});

  @override
  State<_CardPicker> createState() => _CardPickerState();
}

class _CardPickerState extends State<_CardPicker> {
  String _query = '';
  _CardChoice? _choice;

  static List<_CardChoice> _choices(bool trees) {
    final byKey = <String, _CardChoice>{};
    for (final e in detectorCards.entries) {
      final card = e.value;
      if ((card.position == CardPosition.base) != trees) continue;
      // Grouped by display name: roe deer, squeaker and chamois have one
      // rules card per symbol but are the same card to the player.
      final name = cardName(card.glCardName);
      byKey
          .putIfAbsent('$name/${card.position.name}', () => _CardChoice(name, card.position, []))
          .variants
          .add(e);
    }
    final list = byKey.values.toList()
      ..sort((a, b) {
        final byName = a.name.compareTo(b.name);
        return byName != 0 ? byName : a.position.index.compareTo(b.position.index);
      });
    for (final c in list) {
      c.variants.sort((a, b) => symbolName(a.value.color).compareTo(symbolName(b.value.color)));
    }
    return list;
  }

  void _pick(_CardChoice choice) {
    if (choice.variants.length == 1) {
      Navigator.pop(context, choice.variants.single.key);
    } else {
      setState(() => _choice = choice);
    }
  }

  Widget _buildCardStep() {
    final q = _query.trim().toLowerCase();
    final choices = _choices(widget.trees)
        .where((c) => q.isEmpty || c.name.toLowerCase().contains(q))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.trees ? 'Search trees and shrubs' : 'Search cards',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: choices.length,
            itemBuilder: (context, i) {
              final c = choices[i];
              return ListTile(
                dense: true,
                title: Text(c.name, style: const TextStyle(color: Colors.white)),
                subtitle: c.position == CardPosition.base
                    ? null
                    : Text(_positionName(c.position), style: const TextStyle(color: Colors.white60)),
                trailing: c.variants.length > 1
                    ? const Icon(Icons.chevron_right, color: Colors.white54)
                    : null,
                onTap: () => _pick(c),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolStep(_CardChoice choice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: IconButton(
            onPressed: () => setState(() => _choice = null),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Back',
          ),
          title: Text(
            '${choice.name}${choice.position == CardPosition.base ? '' : ' · ${_positionName(choice.position).toLowerCase()}'}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Which tree symbol is in the corner?', style: TextStyle(color: Colors.white60)),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final v in choice.variants)
                ListTile(
                  leading: SymbolDot(v.value.color, size: 24),
                  title: Text(
                    [
                      v.value.color == CardColor.none ? 'No symbol' : symbolName(v.value.color),
                      // Same symbol as a base game squeaker.
                      if (v.value.glCardName == 'squeakerWE') 'Woodland Edge',
                    ].join(' · '),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, v.key),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final choice = _choice;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: choice == null ? _buildCardStep() : _buildSymbolStep(choice),
      ),
    );
  }
}

class _DetectionPainter extends CustomPainter {
  final List<Detection> detections;

  _DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.lightGreenAccent;
    for (final d in detections) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(d.x * size.width, d.y * size.height),
          width: d.width * size.width,
          height: d.height * size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DetectionPainter old) => old.detections != detections;
}
