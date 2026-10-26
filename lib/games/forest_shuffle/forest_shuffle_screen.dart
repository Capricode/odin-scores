import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../screens/start_screen.dart';
import '../../screens/stats_screen.dart';
import '../../stats/game_record.dart';
import '../../stats/stats_calculator.dart';
import '../../stats/stats_storage.dart';
import '../../utils/avatar_text.dart';
import '../../utils/game_state_storage.dart';
import '../game_type.dart';
import 'card_names.dart';
import 'engine/forest_shuffle_engine.dart';
import 'forest_editor_screen.dart';
import 'forest_shuffle_game.dart';
import 'forest_shuffle_stats.dart';

export 'forest_shuffle_game.dart' show ForestShuffleSavedGame;

/// Forest Shuffle is scored once, at the end: every player enters their
/// forest (photo + corrections), then the game is finished and saved.
class ForestShuffleScreen extends StatefulWidget {
  final List<Player>? initialPlayers;

  /// A game restored after the app was closed; takes precedence over [initialPlayers].
  final ForestShuffleSavedGame? savedGame;

  const ForestShuffleScreen({super.key, this.initialPlayers, this.savedGame});

  @override
  State<ForestShuffleScreen> createState() => _ForestShuffleScreenState();
}

class _ForestShuffleScreenState extends State<ForestShuffleScreen> {
  List<Player> players = [];
  Map<String, ForestEntry> forests = {};
  bool finished = false;
  DateTime? finishedAt;
  Map<String, int> streaks = {};
  // Set when leaving for the start screen, so the game is no longer resumed.
  bool _discarded = false;
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    final saved = widget.savedGame;
    if (saved != null) {
      players = List.of(saved.players);
      forests = Map.of(saved.forests);
      finished = saved.finished;
      finishedAt = saved.finishedAt;
    } else if (widget.initialPlayers != null) {
      players = List.of(widget.initialPlayers!);
    }
    _loadStreaks();
    _persist();
  }

  /// Every state change is saved so the game survives an app crash or reload.
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _persist();
  }

  void _persist() {
    if (_discarded || players.isEmpty) return;
    GameStateStorage.save(
      GameType.forestShuffle,
      ForestShuffleSavedGame(
        players: players,
        forests: forests,
        finished: finished,
        finishedAt: finishedAt,
      ).toJson(),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadStreaks() async {
    final games = await StatsStorage.load(GameType.forestShuffle);
    if (!mounted) return;
    setState(() => streaks = StatsCalculator.currentStreaks(games));
  }

  Map<String, ForestScore> get _scores => scorePlayers(players, forests);

  bool get _allEntered => players.every((p) => forests.containsKey(p.id));

  /// Highest total wins; ties share the win.
  List<Player> _winners(Map<String, ForestScore> scores) {
    if (players.isEmpty) return [];
    final best = players.map((p) => scores[p.id]!.total).reduce((a, b) => a > b ? a : b);
    return players.where((p) => scores[p.id]!.total == best).toList();
  }

  // --------------------------------------------------------------- actions

  /// Returns true when the forest was changed.
  Future<bool> _editForest(Player player) async {
    final others = [
      for (final p in players)
        if (p.id != player.id)
          PlayerForest(
            name: p.name,
            cards: forests[p.id]?.cards ?? const [],
            caveCount: forests[p.id]?.caveCount ?? 0,
          ),
    ];
    final entry = await Navigator.of(context).push<ForestEntry>(
      MaterialPageRoute(
        builder: (_) => ForestEditorScreen(
          playerName: player.name,
          initial: forests[player.id] ?? const ForestEntry(),
          otherForests: others,
          showScore: finished,
        ),
      ),
    );
    if (entry == null || !mounted) return false;
    setState(() => forests[player.id] = entry);
    return true;
  }

  void _finish() {
    setState(() {
      finished = true;
      finishedAt = DateTime.now();
      _sortByScore();
    });
    StatsStorage.saveGame(_record()).then((_) => _loadStreaks());
    _confettiController.play();
  }

  /// Fixes a forest after the game was finished; the saved game in the
  /// statistics is replaced.
  Future<void> _correctForest(Player player) async {
    if (!await _editForest(player) || !mounted) return;
    setState(_sortByScore);
    StatsStorage.replaceGame(_record()).then((_) => _loadStreaks());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scores corrected, statistics updated')),
    );
  }

  void _sortByScore() {
    final scores = _scores;
    players.sort((a, b) {
      final byScore = scores[b.id]!.total.compareTo(scores[a.id]!.total);
      return byScore != 0 ? byScore : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  GameRecord _record() {
    final scores = _scores;
    return GameRecord(
      game: GameType.forestShuffle,
      // Games finished before corrections existed have no time; the record
      // is then added rather than replaced.
      playedAt: finishedAt ?? DateTime.now(),
      players: [
        for (final p in players) PlayerResult(name: p.name, scores: _categoryScores(scores[p.id]!)),
      ],
    );
  }

  /// In [ForestShuffleStats.categories] order; adds up to the total.
  static List<int> _categoryScores(ForestScore s) => [s.trees, s.top, s.bottom, s.side, s.cave];

  Future<void> _newGame() async {
    if (!finished && forests.isNotEmpty) {
      final ok = await _confirm(
        title: 'Start a new game?',
        message: 'The forests entered so far will be discarded and not saved to the statistics.',
        confirmLabel: 'New game',
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() {
      forests = {};
      finished = false;
      finishedAt = null;
    });
  }

  Future<void> _changePlayers() async {
    if (!finished && forests.isNotEmpty) {
      final ok = await _confirm(
        title: 'Change players?',
        message: 'The forests entered so far will be discarded and not saved to the statistics.',
        confirmLabel: 'Change players',
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    _discarded = true;
    GameStateStorage.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StartScreen(initialPlayers: players, game: GameType.forestShuffle),
      ),
    );
  }

  void _openStats() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatsScreen(game: GameType.forestShuffle)),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
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
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- build

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 44,
      title: Text(
        finished ? 'Game over' : 'Forest Shuffle',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: true,
      backgroundColor: Colors.grey[900],
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'More',
          color: Colors.grey[850],
          onSelected: (value) {
            if (value == 'new') _newGame();
            if (value == 'players') _changePlayers();
            if (value == 'stats') _openStats();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'new', child: Text('New game · same players')),
            PopupMenuItem(value: 'players', child: Text('New game · new players')),
            PopupMenuItem(value: 'stats', child: Text('Statistics')),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerCard(int index, Map<String, ForestScore> scores, Set<String> winnerIds) {
    final player = players[index];
    final entry = forests[player.id];
    final score = scores[player.id]!;
    final isWinner = finished && winnerIds.contains(player.id);
    final streak = streaks[nameKey(player.name)] ?? 0;

    final String subtitle;
    if (entry == null) {
      subtitle = 'Tap to scan the forest';
    } else if (finished) {
      subtitle = '🌳 ${score.trees}  🐦 ${score.top}  🍄 ${score.bottom}  🦊 ${score.side}  🕳️ ${score.cave}';
    } else {
      subtitle = '${entry.cards.length} cards · ${entry.caveCount} in the cave';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: isWinner ? Colors.green.shade900 : Colors.grey[900],
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => finished ? _showBreakdown(player, score) : _editForest(player),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: entry == null ? Colors.grey[700] : Colors.green.shade700,
                child: Text(
                  buildAvatarText(players, index),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${player.name}${streak >= 2 ? '  🔥$streak' : ''}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isWinner ? Colors.amber : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: entry == null ? Colors.orange.shade300 : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                ),
              // Scores stay hidden until the game is finished.
              if (finished)
                Text(
                  '${score.total}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                )
              else if (entry != null)
                const Icon(Icons.check_circle, color: Colors.lightGreen, size: 32)
              else
                const Icon(Icons.photo_camera, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  void _showBreakdown(Player player, ForestScore score) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${player.name} · ${score.total} points',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _correctForest(player);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Correct'),
                    style: TextButton.styleFrom(foregroundColor: Colors.lightGreenAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final (label, points) in [
                ('🌳 Trees and shrubs', score.trees),
                ('🐦 Top${score.butterflies > 0 ? ' (butterflies ${score.butterflies})' : ''}', score.top),
                ('🍄 Bottom', score.bottom),
                ('🦊 Sides', score.side),
                ('🕳️ Cave', score.cave),
              ])
                _line(label, '$points', bold: true),
              const Divider(color: Colors.white24),
              for (final c in [...score.cards]..sort((a, b) => b.points.compareTo(a.points)))
                if (c.count > 0) _line('${c.count}× ${cardName(c.name)}', '${c.points}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String left, String right, {bool bold = false}) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }

  Widget _buildWinnerBanner(List<Player> winners, int total) {
    final names = winners.map((w) => w.name).join(' & ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.green.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 28, color: Colors.amber),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$names ${winners.length > 1 ? 'win' : 'wins'}! · $total',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (finished) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              onPressed: _openStats,
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              tooltip: 'Statistics',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _changePlayers,
                icon: const Icon(Icons.add),
                label: const Text('New game'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
                            child: ElevatedButton.icon(
                onPressed: _newGame,
                icon: const Icon(Icons.replay),
                label: const Text('Play again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final entered = players.where((p) => forests.containsKey(p.id)).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _allEntered ? _finish : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: _allEntered ? Colors.green.shade700 : null,
            foregroundColor: _allEntered ? Colors.white : null,
          ),
          child: Text(
            _allEntered ? 'Finish game' : 'Enter every forest to finish ($entered/${players.length})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scores = _scores;
    final winners = finished ? _winners(scores) : <Player>[];
    final winnerIds = winners.map((w) => w.id).toSet();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              if (winners.isNotEmpty) _buildWinnerBanner(winners, scores[winners.first.id]!.total),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 4),
                  children: [
                    for (var i = 0; i < players.length; i++) _buildPlayerCard(i, scores, winnerIds),
                    if (!finished)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'At the end of the game, tap each player and take a photo of their forest. '
                          'The points stay secret until you tap "Finish game".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    if (finished)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Tap a player to see their points per card or to correct their forest.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.lightGreen, Colors.brown, Colors.amber, Colors.teal],
          ),
        ),
      ],
    );
  }
}
