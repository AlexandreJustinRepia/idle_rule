import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  // DIMINISHING RETURNS FORMULAS
  // Using Square Root or Hyperbolic curves to ensure early gains feel impactful but late stacking flattens.

  int get attackDamage => 1 + (math.sqrt(strength) * 1.2).floor();
  
  int get maxHealth => 30 + (math.sqrt(strength) * 4).floor();

  double get maxStamina => 24 + (math.sqrt(endurance) * 10);
  
  double get maxHunger => 60 + (math.sqrt(endurance) * 15);
  
  double get staminaRecovery => 2 + (math.sqrt(endurance) * 0.6);

  // Hyperbolic Dodge: harder to hit 45% cap
  double get dodgeChance => (speed / (speed + 220)).clamp(0.0, 0.45);

  // Hyperbolic Attack Delay: prevents "instant" attacks
  Duration get attackDelay {
    final milliseconds = (300 + 650 * (180 / (speed + 180))).round();
    return Duration(milliseconds: milliseconds);
  }

  // INTELLIGENCE & VARIETY STATS
  // Hit Chance: Reduces miss chance against "Fast" enemies.
  double get hitChance => 0.7 + (intelligence / (intelligence + 120)) * 0.28;

  // Counter Mitigation: Reduces damage taken from "Counter" strikes.
  double get counterMitigation => (intelligence / (intelligence + 250)) * 0.5;
}

enum EnemyType { regular, fast, tank, counter }

class Enemy {
  final String name;
  final EnemyType type;
  final int health;
  final int damage;
  final Duration attackDelay;
  final double dodgeChance;
  final double counterChance;
  final Color themeColor;

  const Enemy({
    required this.name,
    this.type = EnemyType.regular,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.0,
    this.counterChance = 0.0,
    this.themeColor = Colors.redAccent,
  });
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
