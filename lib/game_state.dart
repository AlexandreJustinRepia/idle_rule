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
