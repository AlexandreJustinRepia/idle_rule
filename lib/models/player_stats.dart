import 'dart:math' as math;
import 'package:flutter/material.dart';

@immutable
class PlayerStats {
  final double strength;
  final double speed;
  final double endurance;
  final double intelligence;
  final double potential;
  final double reputation;

  const PlayerStats({
    this.strength = 0,
    this.speed = 0,
    this.endurance = 0,
    this.intelligence = 76,
    this.potential = 96,
    this.reputation = 0,
  });

  PlayerStats gain({
    double strength = 0,
    double speed = 0,
    double endurance = 0,
    double reputation = 0,
  }) {
    return PlayerStats(
      strength: this.strength + strength,
      speed: this.speed + speed,
      endurance: this.endurance + endurance,
      intelligence: intelligence,
      potential: potential,
      reputation: this.reputation + reputation,
    );
  }

  /// Calculates effective stat value after applying soft caps for diminishing returns.
  double _diminish(double value) {
    if (value <= 50) return value;
    if (value <= 100) return 50 + (value - 50) * 0.7;
    return 85 + (value - 100) * 0.4;
  }

  int get attackDamage => 1 + (math.sqrt(_diminish(strength)) * 1.2).floor();
  int get maxHealth => 30 + (math.sqrt(_diminish(strength)) * 4).floor();
  double get maxStamina => 24 + (math.sqrt(_diminish(endurance)) * 10);
  double get maxHunger => 60 + (math.sqrt(_diminish(endurance)) * 15);
  double get staminaRecovery => 2 + (math.sqrt(_diminish(endurance)) * 0.6);

  double get dodgeChance {
    final effectiveSpeed = _diminish(speed);
    return (effectiveSpeed / (effectiveSpeed + 220)).clamp(0.0, 0.45);
  }

  Duration get attackDelay {
    final effectiveSpeed = _diminish(speed);
    final milliseconds = (300 + 650 * (180 / (effectiveSpeed + 180))).round();
    return Duration(milliseconds: milliseconds);
  }

  double get hitChance => 0.7 + (intelligence / (intelligence + 120)) * 0.28;
  double get counterMitigation => (intelligence / (intelligence + 250)) * 0.5;

  int get gangCapacity => 1 + (reputation / 20).floor().clamp(0, 5);

  /// Returns the letter rank for a given stat value.
  static String getRankLabel(double value) {
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
