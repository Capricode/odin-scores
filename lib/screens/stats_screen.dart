import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../stats/game_record.dart';
import '../stats/stats_calculator.dart';
import '../stats/stats_storage.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<GameRecord>? _games;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final games = await StatsStorage.load();
    if (!mounted) return;
    setState(() => _games = games);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _export() async {
    final json = await StatsStorage.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    _snack('Stats copied to clipboard. Paste them somewhere safe.');
  }

  Future<void> _import() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Import stats', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste an export here. This replaces the stats stored on this device.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: const OutlineInputBorder(),
              ),
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
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty) return;
    try {
      final count = await StatsStorage.importJson(text);
      await _reload();
      _snack('Imported $count games');
    } on FormatException catch (e) {
      _snack('Import failed: ${e.message}');
    }
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Reset all stats?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'All saved games on this device will be deleted. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await StatsStorage.clear();
    await _reload();
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _line(String left, String right, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(left, style: TextStyle(color: color ?? Colors.white, fontSize: 15)),
          ),
          Text(right, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = _games;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: games == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  children: [
                    if (games.isEmpty)
                      _section('No games yet', [
                        const Text(
                          'Finish a game and the stats will show up here.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ])
                    else
                      ..._content(games),
                    _section('Backup', [
                      const Text(
                        'Stats live in this browser only. Clearing site data erases them, and '
                        'iPhone Safari may delete them after about a week of not visiting. '
                        'Tip: use "Add to Home Screen" to avoid that, or export a backup.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: games.isEmpty ? null : _export,
                            icon: const Icon(Icons.copy),
                            label: const Text('Export'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _import,
                            icon: const Icon(Icons.paste),
                            label: const Text('Import'),
                          ),
                          OutlinedButton.icon(
                            onPressed: games.isEmpty ? null : _reset,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Reset all stats'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade300),
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _content(List<GameRecord> games) {
    final stats = StatsCalculator.playerStats(games);
    final records = StatsCalculator.records(games);
    final nemeses = StatsCalculator.nemeses(games);

    return [
      _section('Leaderboard (${games.length} games)', [
        for (var i = 0; i < stats.length; i++)
          _line(
            '${i == 0 && stats[i].wins > 0 ? '🏆 ' : ''}${stats[i].name}',
            '${stats[i].wins} wins · ${stats[i].games} games · '
                '${(stats[i].winRate * 100).round()}%',
          ),
      ]),
      _section('Streaks', [
        for (final s in stats)
          _line(
            s.name,
            '${s.currentStreak >= 2 ? '🔥 ' : ''}now ${s.currentStreak} · best ${s.bestStreak}',
          ),
      ]),
      _section('Records', [
        if (records.lowestWin != null)
          _line('🎯 Lowest winning score', '${records.lowestWin!.value} · ${records.lowestWin!.label}'),
        if (records.longestGame != null)
          _line('⏳ Longest game', '${records.longestGame!.value} rounds'),
        if (records.worstRound != null)
          _line('💥 Worst single round', '${records.worstRound!.value} · ${records.worstRound!.label}'),
      ]),
      _section('Nemesis 😈', [
        if (nemeses.isEmpty)
          const Text(
            'Needs at least ${StatsCalculator.minGamesForNemesis} games together.',
            style: TextStyle(color: Colors.white70),
          )
        else
          for (final n in nemeses)
            _line(n.player, '${n.nemeses.join(' & ')} (${n.losses}× ahead)'),
      ]),
    ];
  }
}
