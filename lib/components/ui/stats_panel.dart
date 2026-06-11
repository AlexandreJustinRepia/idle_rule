import 'package:flutter/material.dart';
import '../../game_state.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CURRENT STATS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatRow('Strength', stats.strength, Colors.redAccent),
            const SizedBox(height: 8),
            _buildStatRow('Speed', stats.speed, Colors.lightBlueAccent),
            const SizedBox(height: 8),
            _buildStatRow('Endurance', stats.endurance, Colors.greenAccent),
            const SizedBox(height: 8),
            _buildStatRow(
              'Intelligence',
              stats.intelligence,
              Colors.purpleAccent,
            ),
            const SizedBox(height: 8),
            _buildStatRow('Potential', stats.potential, Colors.orangeAccent),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white10),
            ),
            _buildStatRow('Reputation', stats.reputation, Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String name, double value, Color tierColor) {
    final tier = PlayerStats.getRankLabel(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
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
                fontSize: 11,
              ),
            ),
            Text(
              tier,
              style: TextStyle(
                color: tierColor,
                fontSize: 18,
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
}
