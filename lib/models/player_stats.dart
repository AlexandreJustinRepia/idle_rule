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

  /// Calculates effective stat value after applying soft caps for diminishing returns.
  /// 0-50: 100% efficiency
  /// 50-100: 70% efficiency
  /// 100+: 40% efficiency
  double _diminish(double value) {
    if (value <= 50) return value;
    if (value <= 100) return 50 + (value - 50) * 0.7;
    return 85 + (value - 100) * 0.4; // 85 = 50 + (50 * 0.7)
  }

  // ATK scaling: Diminishing returns on strength applied before sqrt
  int get attackDamage => 1 + (math.sqrt(_diminish(strength)) * 1.2).floor();

  // Health: Scales with diminished strength
  int get maxHealth => 30 + (math.sqrt(_diminish(strength)) * 4).floor();

  // Stamina/Hunger: Scales with diminished endurance
  double get maxStamina => 24 + (math.sqrt(_diminish(endurance)) * 10);
  double get maxHunger => 60 + (math.sqrt(_diminish(endurance)) * 15);
  double get staminaRecovery => 2 + (math.sqrt(_diminish(endurance)) * 0.6);

  // Dodge: Hyperbolic scaling + Soft Cap on speed
  // Max dodge is still hard capped at 45%
  double get dodgeChance {
    final effectiveSpeed = _diminish(speed);
    return (effectiveSpeed / (effectiveSpeed + 220)).clamp(0.0, 0.45);
  }

  // Attack Speed: Scales with diminished speed
  Duration get attackDelay {
    final effectiveSpeed = _diminish(speed);
    final milliseconds = (300 + 650 * (180 / (effectiveSpeed + 180))).round();
    return Duration(milliseconds: milliseconds);
  }

  // Intelligence stats already use hyperbolic diminishing returns natively
  double get hitChance => 0.7 + (intelligence / (intelligence + 120)) * 0.28;
  double get counterMitigation => (intelligence / (intelligence + 250)) * 0.5;
}
