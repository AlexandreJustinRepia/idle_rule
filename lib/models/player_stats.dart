import 'dart:math' as math;
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

  int get attackDamage => 1 + (math.sqrt(strength) * 1.2).floor();
  int get maxHealth => 30 + (math.sqrt(strength) * 4).floor();
  double get maxStamina => 24 + (math.sqrt(endurance) * 10);
  double get maxHunger => 60 + (math.sqrt(endurance) * 15);
  double get staminaRecovery => 2 + (math.sqrt(endurance) * 0.6);

  double get dodgeChance => (speed / (speed + 220)).clamp(0.0, 0.45);

  Duration get attackDelay {
    final milliseconds = (300 + 650 * (180 / (speed + 180))).round();
    return Duration(milliseconds: milliseconds);
  }

  double get hitChance => 0.7 + (intelligence / (intelligence + 120)) * 0.28;
  double get counterMitigation => (intelligence / (intelligence + 250)) * 0.5;
}
