import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player.dart';
import '../stats/game_record.dart';
import '../stats/stats_calculator.dart';
import '../stats/stats_storage.dart';
import '../utils/avatar_text.dart';
import '../utils/game_state_storage.dart';
import 'start_screen.dart';
import 'stats_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player>? initialPlayers;

  /// A game restored after the app was closed; takes precedence over [initialPlayers].
  final SavedGame? savedGame;

  const GameScreen({super.key, this.initialPlayers, this.savedGame});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// Everything needed to put a removed player back.
class _RemovalBackup {
  final List<Player> players;
  final List<Player> leftPlayers;
  final Map<String, int?> currentRoundScores;
  final int startPlayerIndex;
  final List<RoundSnapshot> roundHistory;

  _RemovalBackup({
    required this.players,
    required this.leftPlayers,
    required this.currentRoundScores,
    required this.startPlayerIndex,
    required this.roundHistory,
  });
}

class _GameScreenState extends State<GameScreen> {
  static const int _winScoreLimit = 15;

  List<Player> players = [];
  // Players removed mid-game; kept for statistics only (DNF).
  List<Player> leftPlayers = [];
  // Players removed on the game-over screen; dropped on the next game.
  final Set<String> leavingIds = {};
  Map<String, int?> currentRoundScores = {};
  bool gameEnded = false;
  int currentRound = 1;
  int startPlayerIndex = 0;
  late ConfettiController _confettiController;
  late ConfettiController _rocketController;

  // Round history tracking for undo functionality
  List<RoundSnapshot> roundHistory = [];

  List<Award> awards = [];
  // Set when leaving for the start screen, so the game is no longer resumed.
  bool _discarded = false;
  Map<String, int> streaks = {};

  // Predefined vibrant colors for player avatars
  final List<Color> _avatarColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.purple,
  ];

  Color _getPlayerColor(int playerIndex) {
    return _avatarColors[playerIndex % _avatarColors.length];
  }

  String _getPlayerAvatarText(int playerIndex) {
    return buildAvatarText(players, playerIndex);
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _rocketController = ConfettiController(duration: const Duration(seconds: 3));
    final saved = widget.savedGame;
    if (saved != null) {
      players = List.of(saved.players);
      leftPlayers = List.of(saved.leftPlayers);
      leavingIds.addAll(saved.leavingIds);
      currentRoundScores = Map.of(saved.currentRoundScores);
      gameEnded = saved.gameEnded;
      currentRound = saved.currentRound;
      startPlayerIndex = saved.startPlayerIndex;
      roundHistory = List.of(saved.roundHistory);
      if (gameEnded) awards = StatsCalculator.awards(_buildRecord());
    } else if (widget.initialPlayers != null) {
      players = List.from(widget.initialPlayers!);
      currentRoundScores = {for (var p in players) p.id: null};
      // Randomly select first start player
      startPlayerIndex = DateTime.now().millisecondsSinceEpoch % players.length;
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
    GameStateStorage.save(SavedGame(
      players: players,
      leftPlayers: leftPlayers,
      leavingIds: leavingIds,
      currentRoundScores: currentRoundScores,
      gameEnded: gameEnded,
      currentRound: currentRound,
      startPlayerIndex: startPlayerIndex,
      roundHistory: roundHistory,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _rocketController.dispose();
    super.dispose();
  }

  Future<void> _loadStreaks() async {
    final games = await StatsStorage.load();
    if (!mounted) return;
    setState(() {
      streaks = StatsCalculator.currentStreaks(games);
    });
  }

  void _setCurrentScore(String playerId, int score) {
    setState(() {
      currentRoundScores[playerId] = score;
    });
  }

  bool _canProceedToNextRound() {
    if (players.isEmpty) return false;
    return currentRoundScores.values.every((score) => score != null);
  }

  void _nextRound() {
    if (!_canProceedToNextRound()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter scores for all players'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      // Save current round to history before proceeding
      roundHistory.add(RoundSnapshot(
        scores: {for (final p in players) p.id: currentRoundScores[p.id] ?? 0},
        startPlayerIndex: startPlayerIndex,
        roundNumber: currentRound,
      ));

      // Add scores to each player
      for (var i = 0; i < players.length; i++) {
        final score = currentRoundScores[players[i].id];
        if (score != null) {
          players[i] = players[i].addScore(score);
        }
      }

      // Clear current round scores
      currentRoundScores = {for (var p in players) p.id: null};

      // Check if game ended
      _checkGameEnd();

      // Increment round if game hasn't ended
      if (!gameEnded) {
        currentRound++;
        // Move to next player as start player
        startPlayerIndex = (startPlayerIndex + 1) % players.length;
      }
    });
  }

  void _checkGameEnd() {
    if (players.isEmpty) {
      gameEnded = false;
      return;
    }

    bool wasEnded = gameEnded;
    gameEnded = players.any((player) => player.totalScore >= _winScoreLimit);

    if (gameEnded) {
      _sortPlayersByScore();
    }

    // Trigger celebration and save stats when game just ended
    if (!wasEnded && gameEnded) {
      final record = _buildRecord();
      awards = StatsCalculator.awards(record);
      StatsStorage.saveGame(record).then((_) => _loadStreaks());

      final celebrateRocket = _getWinners().any((w) {
        final name = w.name.toUpperCase();
        return name == 'KASIA' || name == 'K';
      });
      if (celebrateRocket) {
        _rocketController.play();
      } else {
        _confettiController.play();
      }
    }
  }

  GameRecord _buildRecord() {
    PlayerResult toResult(Player p, bool dnf) =>
        PlayerResult(name: p.name, scores: List.of(p.scores), dnf: dnf);
    return GameRecord(
      playedAt: DateTime.now(),
      players: [
        ...players.map((p) => toResult(p, false)),
        ...leftPlayers.where((p) => p.scores.isNotEmpty).map((p) => toResult(p, true)),
      ],
    );
  }

  /// Lowest score wins; ties share the win.
  List<Player> _getWinners() {
    if (!gameEnded || players.isEmpty) return [];
    final best = players.map((p) => p.totalScore).reduce((a, b) => a < b ? a : b);
    return players.where((p) => p.totalScore == best).toList();
  }

  void _sortPlayersByScore() {
    players.sort((a, b) {
      final scoreCompare = a.totalScore.compareTo(b.totalScore);
      if (scoreCompare != 0) return scoreCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  bool get _hasProgress =>
      !gameEnded && (currentRound > 1 || currentRoundScores.values.any((s) => s != null));

  Future<void> _newGame() async {
    if (_hasProgress) {
      final ok = await _confirm(
        title: 'Start a new game?',
        message: 'The unfinished game will be discarded and not saved to the statistics.',
        confirmLabel: 'New game',
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() {
      players = players
          .where((p) => !leavingIds.contains(p.id))
          .map((player) => player.resetScores())
          .toList();
      leftPlayers = [];
      leavingIds.clear();
      currentRoundScores = {for (var p in players) p.id: null};
      gameEnded = false;
      awards = [];
      currentRound = 1;
      roundHistory.clear(); // Clear round history for new game
      // Move to next player as start player for new game
      startPlayerIndex = (startPlayerIndex + 1) % players.length;
    });
  }

  // ------------------------------------------------------------ navigation

  Future<void> _changePlayers({bool skipConfirm = false}) async {
    if (_hasProgress && !skipConfirm) {
      final ok = await _confirm(
        title: 'Change players?',
        message: 'The unfinished game will be discarded and not saved to the statistics.',
        confirmLabel: 'Change players',
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    _discarded = true;
    GameStateStorage.clear();
    final keep = [
      for (final p in players)
        if (!leavingIds.contains(p.id)) p.resetScores(),
    ];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => StartScreen(initialPlayers: keep)),
    );
  }

  Future<void> _showNewGameSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.replay, color: Colors.white),
              title: const Text('New game · same players',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Scores reset, same names. Start player rotates.',
                  style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context, 'same'),
            ),
            ListTile(
              leading: const Icon(Icons.group_add, color: Colors.white),
              title: const Text('New game · new players',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                  'Back to setup. Current names are prefilled so you can edit them.',
                  style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context, 'new'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'same') _newGame();
    if (choice == 'new') _changePlayers();
  }

  void _openStats() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatsScreen()));
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

  // ------------------------------------------------------- player removal

  Future<void> _onPlayerLongPress(Player player) async {
    // On the game-over screen a long-press on a leaving player brings them back.
    if (gameEnded && leavingIds.contains(player.id)) {
      setState(() => leavingIds.remove(player.id));
      return;
    }

    final remaining = players.where((p) => !leavingIds.contains(p.id)).length - 1;
    if (remaining < 2) {
      final ok = await _confirm(
        title: 'Not enough players',
        message: 'Only $remaining player${remaining == 1 ? '' : 's'} would be left. '
            'End this game and go back to the start screen?',
        confirmLabel: 'End game',
      );
      if (ok == true) _changePlayers(skipConfirm: true);
      return;
    }

    final ok = await _confirm(
      title: 'Remove ${player.name}?',
      message: gameEnded
          ? '${player.name} will be left out of the next game.'
          : '${player.name} leaves the game. Earlier rounds can no longer be undone.',
      confirmLabel: 'Remove',
    );
    if (ok == true) _removePlayer(player);
  }

  void _removePlayer(Player player) {
    if (gameEnded) {
      setState(() => leavingIds.add(player.id));
      return;
    }

    final backup = _RemovalBackup(
      players: List.of(players),
      leftPlayers: List.of(leftPlayers),
      currentRoundScores: Map.of(currentRoundScores),
      startPlayerIndex: startPlayerIndex,
      roundHistory: List.of(roundHistory),
    );

    setState(() {
      final index = players.indexWhere((p) => p.id == player.id);
      if (index == -1) return;
      players.removeAt(index);
      leftPlayers.add(player);
      currentRoundScores.remove(player.id);
      roundHistory.clear(); // Undo can't go back past a removal.
      if (index < startPlayerIndex) startPlayerIndex--;
      startPlayerIndex %= players.length; // Star moves to the next player.
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${player.name} removed'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() {
                players = backup.players;
                leftPlayers = backup.leftPlayers;
                currentRoundScores = backup.currentRoundScores;
                startPlayerIndex = backup.startPlayerIndex;
                roundHistory = backup.roundHistory;
              });
            },
          ),
        ),
      );
  }

  // ------------------------------------------------------------------ undo

  void _undoLastRound() {
    if (roundHistory.isEmpty) return;

    final lastRoundSnapshot = roundHistory.last;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Undo Round ${lastRoundSnapshot.roundNumber}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scores to remove:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...players.map((p) {
              int lastScore = lastRoundSnapshot.scores[p.id] ?? 0;
              int newTotal = p.totalScore - lastScore;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${p.name}: -$lastScore (${p.totalScore} → $newTotal)',
                  style: TextStyle(color: Colors.orange.shade300, fontSize: 14),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text(
              'You can re-enter correct scores for this round.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performUndo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Undo Round'),
          ),
        ],
      ),
    );
  }

  void _performUndo() {
    setState(() {
      // Get last round's snapshot
      RoundSnapshot lastRoundSnapshot = roundHistory.removeLast();

      // Subtract scores from player totals
      for (int i = 0; i < players.length; i++) {
        players[i] = players[i].copyWith(
          scores: [...players[i].scores]..removeLast(),
        );
      }

      // Restore last round's scores to currentRoundScores
      for (final p in players) {
        currentRoundScores[p.id] = lastRoundSnapshot.scores[p.id];
      }

      // Restore start player index
      startPlayerIndex = lastRoundSnapshot.startPlayerIndex;

      // Decrement round
      currentRound = lastRoundSnapshot.roundNumber;

      // Reset game end status and recheck
      gameEnded = false;
      _checkGameEnd();
    });
  }

  // ----------------------------------------------------------- score input

  void _showScoreInput(Player player) {
    final currentScore = currentRoundScores[player.id];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            currentScore != null
                ? 'Edit score for ${player.name}'
                : 'Score for ${player.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show current score indicator at top
                if (currentScore != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Current: $currentScore',
                      style: TextStyle(
                        color: Colors.orange.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ),
                // 0 on top
                _buildScoreButton(0, player.id, currentScore),
                const SizedBox(height: 12),
                // 1-9 in 3x3 grid (3 rows)
                _buildNumberRow([1, 2, 3], player.id, currentScore),
                const SizedBox(height: 8),
                _buildNumberRow([4, 5, 6], player.id, currentScore),
                const SizedBox(height: 8),
                _buildNumberRow([7, 8, 9], player.id, currentScore),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreButton(int score, String playerId, int? currentScore) {
    final isCurrentScore = score == currentScore;

    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentScore
              ? Colors.orange.shade700 // Highlight current score
              : Colors.deepPurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _setCurrentScore(playerId, score);
        },
        child: Text('$score'),
      ),
    );
  }

  Widget _buildNumberRow(List<int> numbers, String playerId, int? currentScore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((number) {
        final isCurrentScore = number == currentScore;

        return SizedBox(
          width: 60,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentScore
                  ? Colors.orange.shade700 // Highlight current score
                  : Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              textStyle:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context);
              _setCurrentScore(playerId, number);
            },
            child: Text('$number'),
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------------------- build

  AppBar _buildAppBar() {
    final canUndo = !gameEnded && roundHistory.isNotEmpty;
    return AppBar(
      toolbarHeight: 44,
      title: Text(
        gameEnded ? 'Game over' : 'Round $currentRound',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: true,
      backgroundColor: Colors.grey[900],
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (canUndo)
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoLastRound,
            tooltip: 'Undo Round ${currentRound - 1}',
          ),
        if (players.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showNewGameSheet,
            tooltip: 'New game',
          ),
        PopupMenuButton<String>(
          tooltip: 'More',
          color: Colors.grey[850],
          onSelected: (value) {
            if (value == 'stats') _openStats();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'stats',
              child: Text('Statistics', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWinnerBanner(List<Player> winners) {
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
              '$names ${winners.length > 1 ? 'win' : 'wins'}! · ${winners.first.totalScore}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = players.length;
        const minCardHeight = 56.0;
        final cardHeight = constraints.maxHeight / n;

        // Fits: share the height evenly. Too many players: scroll.
        if (cardHeight >= minCardHeight) {
          return Column(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(child: _buildPlayerCard(i, cardHeight)),
            ],
          );
        }
        return ListView.builder(
          itemCount: n,
          itemExtent: 72,
          itemBuilder: (context, i) => _buildPlayerCard(i, 72),
        );
      },
    );
  }

  Widget _buildPlayerCard(int index, double height) {
    final player = players[index];
    final winners = _getWinners();
    final isWinner = gameEnded && winners.any((w) => w.id == player.id);
    final isLeaving = leavingIds.contains(player.id);
    final isOver15 = player.totalScore >= _winScoreLimit;
    final currentScore = currentRoundScores[player.id];
    final hasCurrentScore = currentScore != null;
    final streak = streaks[nameKey(player.name)] ?? 0;

    final scoreSize = (height * 0.55).clamp(32.0, 56.0);
    final avatarRadius = ((height - 16) / 2).clamp(16.0, 30.0);

    final Color cardColor = isLeaving
        ? Colors.grey[850]!
        : isWinner
            ? Colors.green.shade900
            : isOver15
                ? Colors.red.shade900
                : Colors.grey[900]!;

    final Widget content;
    if (gameEnded) {
      content = Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLeaving
                    ? Colors.white38
                    : isWinner
                        ? Colors.amber
                        : Colors.white,
                decoration: isLeaving ? TextDecoration.lineThrough : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLeaving)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('leaving', style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          if (isWinner && !isLeaving)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '${player.totalScore}',
              style: TextStyle(
                fontSize: scoreSize,
                fontWeight: FontWeight.bold,
                color: isLeaving ? Colors.white38 : Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      final avatarText = _getPlayerAvatarText(index);
      content = Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isOver15 ? Colors.red : _getPlayerColor(index),
                child: Text(
                  avatarText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: avatarRadius * (avatarText.length > 1 ? 0.67 : 0.93),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (index == startPlayerIndex)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 13),
                  ),
                ),
              if (streak >= 2)
                Positioned(
                  bottom: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🔥$streak', style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasCurrentScore)
            Text(
              '+$currentScore',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green.shade300,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              currentRound == 1 ? 'tap' : '',
              style: TextStyle(fontSize: 14, color: Colors.orange.shade300),
            ),
          const SizedBox(width: 12),
          Text(
            '${player.totalScore}',
            style: TextStyle(
              fontSize: scoreSize,
              fontWeight: FontWeight.bold,
              color: isOver15 ? Colors.red.shade300 : Colors.white,
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: gameEnded ? null : () => _showScoreInput(player),
        onLongPress: () => _onPlayerLongPress(player),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: content,
        ),
      ),
    );
  }

  Widget _buildAwards() {
    if (awards.isEmpty) return const SizedBox.shrink();
    final chipWidth = (MediaQuery.of(context).size.width - 16 - 8) / 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in awards)
            Container(
              width: chipWidth.clamp(140.0, 400.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '${a.emoji} ${a.title}\n',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(text: a.detail, style: const TextStyle(color: Colors.white70)),
                ]),
                style: const TextStyle(fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverFooter() {
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
              icon: const Icon(Icons.group_add),
              label: const Text('New players'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _newGame,
              icon: const Icon(Icons.replay),
              label: const Text('Play again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextRoundButton() {
    final canProceed = _canProceedToNextRound();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canProceed ? _nextRound : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: canProceed ? Theme.of(context).colorScheme.primary : null,
            foregroundColor: canProceed ? Colors.white : null,
          ),
          child: Text(
            canProceed ? 'Next Round' : 'Enter all scores to continue',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final winners = _getWinners();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(),
          body: players.isEmpty
              ? const Center(
                  child: Text(
                    'No players',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    if (gameEnded && winners.isNotEmpty) _buildWinnerBanner(winners),
                    Expanded(child: _buildPlayerList()),
                    if (gameEnded) ...[
                      _buildAwards(),
                      _buildGameOverFooter(),
                    ] else
                      _buildNextRoundButton(),
                  ],
                ),
        ),
        // Confetti for regular winners
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
        // Rockets for Kasia/K
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _rocketController,
            blastDirection: -3.14 / 2, // Up
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.orange,
              Colors.yellow,
            ],
            createParticlePath: (size) {
              // Create rocket shape
              final path = Path();
              path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
              return path;
            },
          ),
        ),
      ],
    );
  }
}
