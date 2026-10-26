import 'package:flutter/material.dart';
import '../games/game_picker.dart';
import '../games/game_type.dart';
import '../games/games.dart';
import '../models/player.dart';
import 'stats_screen.dart';
import '../utils/last_game_storage.dart';
import '../utils/name_storage.dart';
import '../utils/avatar_text.dart';

class StartScreen extends StatefulWidget {
  final List<Player>? initialPlayers;

  /// Preselected game; defaults to the game picked last time.
  final GameType? game;

  const StartScreen({super.key, this.initialPlayers, this.game});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final List<Player> _players = [];
  late GameType _game = widget.game ?? GameType.odin;
  List<String> _recentNames = [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialPlayers != null) {
      _players.addAll(widget.initialPlayers!.map((p) => p.resetScores()));
    }
    _nameController.addListener(() {
      setState(() {});
    });
    _loadStoredNames();
    if (widget.game == null) _loadLastGame();
  }

  Future<void> _loadLastGame() async {
    final game = await LastGameStorage.load();
    if (!mounted) return;
    setState(() => _game = game);
  }

  void _selectGame(GameType game) {
    setState(() => _game = game);
    LastGameStorage.save(game);
  }

  /// Recently used names that aren't in the game yet.
  List<String> get _suggestedNames => _recentNames
      .where((n) => !_players.any((p) => p.name.toLowerCase() == n.toLowerCase()))
      .toList();

  int? get _maxPlayers => _game.maxPlayers;

  bool get _tooManyPlayers => _maxPlayers != null && _players.length > _maxPlayers!;

  bool get _canStart => _players.length >= _game.minPlayers && !_tooManyPlayers;

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final trimmedName = _nameController.text.trim();

    setState(() {
      _players.add(Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: trimmedName,
      ));
      _nameController.clear();
    });

    _focusNode.requestFocus();
    _persistName(trimmedName);
  }

  void _addPlayerFromStored(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final alreadyAdded = _players.any(
      (p) => p.name.toLowerCase() == trimmed.toLowerCase(),
    );

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$trimmed is already added'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _players.add(Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: trimmed,
      ));
    });

    _focusNode.requestFocus();
    _persistName(trimmed);
  }

  Future<void> _loadStoredNames() async {
    final names = await NameStorage.load();
    if (!mounted) return;
    setState(() {
      _recentNames = names;
    });
  }

  Future<void> _persistName(String name) async {
    final updated = await NameStorage.save(name);
    if (!mounted) return;
    setState(() {
      _recentNames = updated;
    });
  }

  void _removePlayer(String id) {
    setState(() {
      _players.removeWhere((player) => player.id == id);
    });
  }

  void _editPlayer(Player player) {
    final editController = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Edit Player Name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Player Name',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    final index = _players.indexWhere((p) => p.id == player.id);
                    if (index != -1) {
                      _players[index] = Player(
                        id: player.id,
                        name: editController.text.trim(),
                      );
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _startGame() {
    if (!_canStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_startHint),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    LastGameStorage.save(_game);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => gameScreen(_game, _players),
      ),
    );
  }

  String get _startHint {
    if (_tooManyPlayers) return '${_game.name} is for at most $_maxPlayers players';
    return 'Add at least ${_game.minPlayers} players';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.bar_chart, color: Colors.white70),
                      tooltip: 'Statistics',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StatsScreen(game: _game)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GamePickerButton(game: _game, onChanged: _selectGame),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add New Player',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter player names to begin',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Text input field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Player Name',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nameController.text.isEmpty ? null : _addPlayer,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Player'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[800],
                              disabledForegroundColor: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_suggestedNames.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recently used',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestedNames
                                .map(
                                  (name) => InputChip(
                                    label: Text(name),
                                    onPressed: () => _addPlayerFromStored(name),
                                    backgroundColor: Colors.grey[850],
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  if (_suggestedNames.isNotEmpty) const SizedBox(height: 20),
                  // Players list
                  if (_players.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Players (${_players.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _players.length,
                            itemBuilder: (context, index) {
                              final player = _players[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    buildAvatarText(_players, index),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  player.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editPlayer(player),
                                      tooltip: 'Edit player',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _removePlayer(player.id),
                                      tooltip: 'Remove player',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Start game button
                  if (_players.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canStart ? _startGame : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: _canStart ? _game.color : Colors.grey[800],
                            foregroundColor: _canStart ? Colors.white : Colors.grey[600],
                            disabledBackgroundColor: Colors.grey[800],
                            disabledForegroundColor: Colors.grey[600],
                          ),
                          child: Text(
                            _canStart ? 'Start ${_game.name}' : _startHint,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (_players.isNotEmpty && _game == GameType.odin)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.white54, size: 16),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Tip: during the game, long-press a player card to remove them',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
