import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        border: const Border(
          top: BorderSide(color: Colors.white24, width: 1),
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
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Strength', 'F', Colors.grey),
          const SizedBox(height: 12),
          _buildStatRow('Speed', 'E', Colors.blueGrey),
          const SizedBox(height: 12),
          _buildStatRow('Endurance', 'C', Colors.blueAccent),
          const SizedBox(height: 12),
          _buildStatRow('Intelligence', 'S-', Colors.purpleAccent),
          const SizedBox(height: 12),
          _buildStatRow('Potential', 'SSR', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatRow(String name, String tier, Color tierColor) {
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
              'Rank ',
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
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
