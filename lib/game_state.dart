import 'package:flutter/material.dart';

@immutable
class PlayerStats {
  final double strength;
  final double speed;
  final double endurance;
  final double intelligence;
  final double potential;

  const PlayerStats({
    this.strength = 0,
    this.speed = 0,
    this.endurance = 0,
    this.intelligence = 76,
    this.potential = 96,
  });

  PlayerStats gain({
    double strength = 0,
    double speed = 0,
    double endurance = 0,
  }) {
    return PlayerStats(
      strength: this.strength + strength,
      speed: this.speed + speed,
      endurance: this.endurance + endurance,
      intelligence: intelligence,
      potential: potential,
    );
  }

  int get attackDamage => 1 + (strength / 10).floor();
  int get maxHealth => 30 + (strength / 3).floor();
  double get maxStamina => 24 + endurance * 0.8;
  double get maxHunger => 60 + endurance * 1.4;
  double get staminaRecovery => 2 + endurance * 0.06;
  double get dodgeChance => (speed / (speed + 180)).clamp(0.0, 0.45);
  Duration get attackDelay {
    final milliseconds = (950 - speed * 6).clamp(360, 950).round();
    return Duration(milliseconds: milliseconds);
  }
}

class Boss {
  final String name;
  final int health;
  final int damage;
  final double dodgeChance;
  final Duration attackDelay;
  final Color themeColor;

  const Boss({
    required this.name,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.05,
    this.themeColor = Colors.red,
  });
}

final List<Boss> gameBosses = [
  Boss(
    name: 'BIG MAMA',
    health: 150,
    damage: 8,
    attackDelay: const Duration(milliseconds: 1800),
    themeColor: Colors.deepOrange,
  ),
  Boss(
    name: 'SLICK RICK',
    health: 100,
    damage: 5,
    attackDelay: const Duration(milliseconds: 800),
    dodgeChance: 0.25,
    themeColor: Colors.purpleAccent,
  ),
  Boss(
    name: 'THE GHOST',
    health: 250,
    damage: 12,
    attackDelay: const Duration(milliseconds: 1400),
    dodgeChance: 0.15,
    themeColor: Colors.blueGrey,
  ),
];
