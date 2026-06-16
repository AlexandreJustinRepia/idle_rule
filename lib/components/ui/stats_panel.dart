import 'package:flutter/material.dart';
import '../../game_state.dart';

class StatsPanel extends StatelessWidget {
  final PlayerStats stats;

  const StatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D11),
        border: Border(top: BorderSide(color: const Color(0xFFE24B4A).withValues(alpha: 0.4), width: 1)),
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
                color: Colors.white30,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            _buildStatRow('Strength', stats.strength, Icons.fitness_center),
            _buildStatRow('Speed', stats.speed, Icons.directions_run),
            _buildStatRow('Endurance', stats.endurance, Icons.shield),
            _buildStatRow('Intelligence', stats.intelligence, Icons.psychology),
            _buildStatRow('Potential', stats.potential, Icons.star_border),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(color: Colors.white10, height: 1),
            ),
            _buildStatRow('Reputation', stats.reputation, Icons.group),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String name, double value, IconData icon) {
    final rank = PlayerStats.getRank(value);
    final currentThresh = PlayerStats.getCurrentThreshold(value);
    final nextThresh = PlayerStats.getNextThreshold(value);
    
    double progress = 0.0;
    if (nextThresh > currentThresh) {
      progress = ((value - currentThresh) / (nextThresh - currentThresh)).clamp(0.0, 1.0);
    } else {
      progress = 1.0;
    }

    final isMax = value >= 2000;
    final isSpecialRank = rank.label == '???' || rank.label.contains('X') || rank.label == 'EX' || rank.label == 'DX';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stat Name & Icon
              Row(
                children: [
                  Icon(icon, color: Colors.white70.withValues(alpha: 0.6), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              
              // Questism Style Rank Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSpecialRank ? Colors.black : const Color(0xFF16161C),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: rank.glowColor.withValues(alpha: 0.8),
                    width: isSpecialRank ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rank.glowColor.withValues(alpha: isSpecialRank ? 0.4 : 0.2),
                      blurRadius: isSpecialRank ? 8 : 4,
                      spreadRadius: isSpecialRank ? 1 : 0,
                    )
                  ],
                ),
                child: Text(
                  rank.label,
                  style: TextStyle(
                    color: rank.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: rank.glowColor.withValues(alpha: 0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          
          // Progress Bar & XP Indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(rank.color),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isMax ? 'MAX' : '${value.toStringAsFixed(1)} / ${nextThresh.toInt()} XP',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
