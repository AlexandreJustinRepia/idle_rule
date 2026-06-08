import 'package:flutter/material.dart';
import '../game_state.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CURRENT STATS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Strength', stats.strength, Colors.redAccent),
          const SizedBox(height: 12),
          _buildStatRow('Speed', stats.speed, Colors.lightBlueAccent),
          const SizedBox(height: 12),
          _buildStatRow('Endurance', stats.endurance, Colors.greenAccent),
          const SizedBox(height: 12),
          _buildStatRow(
            'Intelligence',
            stats.intelligence,
            Colors.purpleAccent,
          ),
          const SizedBox(height: 12),
          _buildStatRow('Potential', stats.potential, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatRow(String name, double value, Color tierColor) {
    final tier = _rankFor(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${value.floor()} xp  ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            Text(
              tier,
              style: TextStyle(
                color: tierColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: tierColor.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _rankFor(double value) {
    if (value >= 100) return 'SSR';
    if (value >= 80) return 'S';
    if (value >= 60) return 'A';
    if (value >= 40) return 'B';
    if (value >= 25) return 'C';
    if (value >= 12) return 'D';
    if (value >= 5) return 'E';
    return 'F';
  }
}
