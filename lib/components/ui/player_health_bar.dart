import 'package:flutter/material.dart';

class PlayerHealthBar extends StatelessWidget {
  final int health;
  final int maxHealth;
  final double stamina;
  final double maxStamina;
  final double hunger;
  final double maxHunger;
  final double reputation;
  final bool wasHit;
  final int damage;
  final int dodge;
  final int gangCapacity;

  const PlayerHealthBar({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.hunger,
    required this.maxHunger,
    required this.reputation,
    required this.wasHit,
    required this.damage,
    required this.dodge,
    required this.gangCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, maxHealth);
    final healthPercent = maxHealth == 0 ? 0.0 : visibleHealth / maxHealth;
    final staminaPercent = maxStamina == 0 ? 0.0 : stamina.clamp(0, maxStamina) / maxStamina;
    final hungerPercent = maxHunger == 0 ? 0.0 : hunger.clamp(0, maxHunger) / maxHunger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PLAYER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text('REP: ${reputation.toStringAsFixed(1)} (CAP: $gangCapacity)',
                  style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
            Text('ATK: $damage  DDG: $dodge%', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        _buildSegmentedBar(healthPercent, wasHit ? Colors.white : const Color(0xFFE24B4A)),
        const SizedBox(height: 3),
        Text('HP: $visibleHealth/$maxHealth', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _buildNeedBar('STM', staminaPercent, const Color(0xFFD0D0D0)),
        const SizedBox(height: 3),
        _buildNeedBar('HNG', hungerPercent, const Color(0xFFBA7517)),
      ],
    );
  }

  Widget _buildNeedBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 35, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900))),
        Expanded(
          child: _buildSegmentedBar(value, color, height: 6),
        ),
      ],
    );
  }

  Widget _buildSegmentedBar(double percent, Color color, {double height = 10}) {
    int totalSegments = 10;
    int activeSegments = (percent * totalSegments).round();

    return Row(
      children: List.generate(totalSegments, (index) {
        bool isActive = index < activeSegments;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == totalSegments - 1 ? 0 : 2),
            height: height,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.black54,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}
