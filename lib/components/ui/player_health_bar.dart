import 'package:flutter/material.dart';

class PlayerHealthBar extends StatelessWidget {
  final int health;
  final int maxHealth;
  final double stamina;
  final double maxStamina;
  final double hunger;
  final double maxHunger;
  final bool wasHit;
  final int damage;
  final int dodge;

  const PlayerHealthBar({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.hunger,
    required this.maxHunger,
    required this.wasHit,
    required this.damage,
    required this.dodge,
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
            const Text('PLAYER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text('ATK: $damage  DDG: $dodge%', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: healthPercent,
            backgroundColor: Colors.black54,
            valueColor: AlwaysStoppedAnimation<Color>(wasHit ? Colors.white : Colors.lightGreenAccent),
          ),
        ),
        const SizedBox(height: 3),
        Text('HP: $visibleHealth/$maxHealth', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _buildNeedBar('STM', staminaPercent, Colors.cyanAccent),
        const SizedBox(height: 3),
        _buildNeedBar('HNG', hungerPercent, hungerPercent < 0.25 ? Colors.redAccent : Colors.orangeAccent),
      ],
    );
  }

  Widget _buildNeedBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 35, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: value,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
