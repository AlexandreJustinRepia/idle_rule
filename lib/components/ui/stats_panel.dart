import 'package:flutter/material.dart';
import '../../game_state.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D11),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE24B4A).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CURRENT STATS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white30,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildCompactStat('STR', stats.strength, Icons.fitness_center)),
              const SizedBox(width: 8),
              Expanded(child: _buildCompactStat('SPD', stats.speed, Icons.directions_run)),
              const SizedBox(width: 8),
              Expanded(child: _buildCompactStat('END', stats.endurance, Icons.shield)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildCompactStat('INT', stats.intelligence, Icons.psychology)),
              const SizedBox(width: 8),
              Expanded(child: _buildCompactStat('POT', stats.potential, Icons.star_border)),
              const SizedBox(width: 8),
              Expanded(child: _buildCompactStat('REP', stats.reputation, Icons.group)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, double value, IconData icon) {
    final rank = PlayerStats.getRank(value);
    final currentThresh = PlayerStats.getCurrentThreshold(value);
    final nextThresh = PlayerStats.getNextThreshold(value);

    double progress = 0.0;
    if (nextThresh > currentThresh) {
      progress = ((value - currentThresh) / (nextThresh - currentThresh)).clamp(0.0, 1.0);
    } else {
      progress = 1.0;
    }

    final isMax = value >= PlayerStats.maxGradeValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 11),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161C),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rank.glowColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  rank.label,
                  style: TextStyle(
                    color: rank.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(rank.color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isMax ? 'MAX' : '${nextThresh.toInt()} XP',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
