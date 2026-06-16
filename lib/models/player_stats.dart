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

  static double getNextThreshold(double value) {
    if (value >= 2000) return 2000;
    if (value >= 1500) return 2000;
    if (value >= 1100) return 1500;
    if (value >= 800) return 1100;
    if (value >= 600) return 800;
    if (value >= 450) return 600;
    if (value >= 350) return 450;
    if (value >= 280) return 350;
    if (value >= 220) return 280;
    if (value >= 170) return 220;
    if (value >= 130) return 170;
    if (value >= 100) return 130;
    if (value >= 80) return 100;
    if (value >= 60) return 80;
    if (value >= 45) return 60;
    if (value >= 30) return 45;
    if (value >= 20) return 30;
    if (value >= 12) return 20;
    if (value >= 5) return 12;
    return 5;
  }

  static double getCurrentThreshold(double value) {
    if (value >= 2000) return 2000;
    if (value >= 1500) return 1500;
    if (value >= 1100) return 1100;
    if (value >= 800) return 800;
    if (value >= 600) return 600;
    if (value >= 450) return 450;
    if (value >= 350) return 350;
    if (value >= 280) return 280;
    if (value >= 220) return 220;
    if (value >= 170) return 170;
    if (value >= 130) return 130;
    if (value >= 100) return 100;
    if (value >= 80) return 80;
    if (value >= 60) return 60;
    if (value >= 45) return 45;
    if (value >= 30) return 30;
    if (value >= 20) return 20;
    if (value >= 12) return 12;
    if (value >= 5) return 5;
    return 0;
  }

  static QuestismRank getRank(double value) {
    if (value >= 2000) {
      return const QuestismRank(
        label: '???',
        color: Colors.white,
        glowColor: Colors.deepPurpleAccent,
      );
    }
    if (value >= 1500) {
      return const QuestismRank(
        label: 'DX',
        color: Colors.amberAccent,
        glowColor: Colors.redAccent,
      );
    }
    if (value >= 1100) {
      return const QuestismRank(
        label: 'EX',
        color: Colors.pinkAccent,
        glowColor: Colors.cyanAccent,
      );
    }
    if (value >= 800) {
      return const QuestismRank(
        label: 'XXX',
        color: Color(0xFFE0B0FF), // Neon Purple text on black
        glowColor: Colors.purpleAccent,
      );
    }
    if (value >= 600) {
      return const QuestismRank(
        label: 'XX',
        color: Color(0xFFFF4D4D), // Dark Neon Red text on black
        glowColor: Colors.redAccent,
      );
    }
    if (value >= 450) {
      return const QuestismRank(
        label: 'X',
        color: Colors.white,
        glowColor: Colors.white70,
      );
    }
    if (value >= 350) {
      return const QuestismRank(
        label: 'MR',
        color: Color(0xFFFF0D00),
        glowColor: Color(0xFFFF0D00),
      );
    }
    if (value >= 280) {
      return const QuestismRank(
        label: 'LR',
        color: Color(0xFFB22222),
        glowColor: Color(0xFFB22222),
      );
    }
    if (value >= 220) {
      return const QuestismRank(
        label: 'UR',
        color: Color(0xFF7D00FF),
        glowColor: Color(0xFF7D00FF),
      );
    }
    if (value >= 170) {
      return const QuestismRank(
        label: 'SSR',
        color: Color(0xFFFF2D55),
        glowColor: Color(0xFFFF2D55),
      );
    }
    if (value >= 130) {
      return const QuestismRank(
        label: 'SR',
        color: Color(0xFF8B0000),
        glowColor: Color(0xFF8B0000),
      );
    }
    if (value >= 100) {
      return const QuestismRank(
        label: 'SSS',
        color: Color(0xFFFF3B30),
        glowColor: Color(0xFFFF3B30),
      );
    }
    if (value >= 80) {
      return const QuestismRank(
        label: 'SS',
        color: Color(0xFFFF9500),
        glowColor: Color(0xFFFF9500),
      );
    }
    if (value >= 60) {
      return const QuestismRank(
        label: 'S',
        color: Color(0xFFFFCC00),
        glowColor: Color(0xFFFFCC00),
      );
    }
    if (value >= 45) {
      return const QuestismRank(
        label: 'A',
        color: Color(0xFFAF52DE),
        glowColor: Color(0xFFAF52DE),
      );
    }
    if (value >= 30) {
      return const QuestismRank(
        label: 'B',
        color: Color(0xFF007AFF),
        glowColor: Color(0xFF007AFF),
      );
    }
    if (value >= 20) {
      return const QuestismRank(
        label: 'C',
        color: Color(0xFF34C759),
        glowColor: Color(0xFF34C759),
      );
    }
    if (value >= 12) {
      return const QuestismRank(
        label: 'D',
        color: Color(0xFFD1D1D6),
        glowColor: Color(0xFFD1D1D6),
      );
    }
    if (value >= 5) {
      return const QuestismRank(
        label: 'E',
        color: Color(0xFF8E8E93),
        glowColor: Color(0xFF8E8E93),
      );
    }
    return const QuestismRank(
      label: 'F',
      color: Color(0xFF8E8E93),
      glowColor: Color(0xFF8E8E93),
    );
  }

  /// Returns the letter rank for a given stat value.
  static String getRankLabel(double value) {
    return getRank(value).label;
  }
}

class QuestismRank {
  final String label;
  final Color color;
  final Color glowColor;

  const QuestismRank({
    required this.label,
    required this.color,
    required this.glowColor,
  });
}
