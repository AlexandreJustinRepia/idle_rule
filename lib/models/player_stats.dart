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

  int get gangCapacity => (5 + (reputation / 5).floor()).clamp(5, 250);

  static const List<_GradeBand> _gradeBands = [
    _GradeBand(2200, '???', Colors.white, Colors.deepPurpleAccent),
    _GradeBand(1700, 'DX', Colors.amberAccent, Colors.redAccent),
    _GradeBand(1250, 'EX', Colors.pinkAccent, Colors.cyanAccent),
    _GradeBand(920, 'XXX', Color(0xFFE0B0FF), Colors.purpleAccent),
    _GradeBand(700, 'XX', Color(0xFFFF4D4D), Colors.redAccent),
    _GradeBand(540, 'X', Colors.white, Colors.white70),
    _GradeBand(430, 'MR', Color(0xFFFF0D00), Color(0xFFFF0D00)),
    _GradeBand(350, 'LR', Color(0xFFB22222), Color(0xFFB22222)),
    _GradeBand(275, 'UR', Color(0xFF7D00FF), Color(0xFF7D00FF)),
    _GradeBand(215, 'SSR', Color(0xFFFF2D55), Color(0xFFFF2D55)),
    _GradeBand(170, 'SR', Color(0xFF8B0000), Color(0xFF8B0000)),
    _GradeBand(132, 'SSS', Color(0xFFFF3B30), Color(0xFFFF3B30)),
    _GradeBand(105, 'SS', Color(0xFFFF9500), Color(0xFFFF9500)),
    _GradeBand(82, 'S', Color(0xFFFFCC00), Color(0xFFFFCC00)),
    _GradeBand(62, 'A', Color(0xFFAF52DE), Color(0xFFAF52DE)),
    _GradeBand(45, 'B', Color(0xFF007AFF), Color(0xFF007AFF)),
    _GradeBand(30, 'C', Color(0xFF34C759), Color(0xFF34C759)),
    _GradeBand(18, 'D', Color(0xFFD1D1D6), Color(0xFFD1D1D6)),
    _GradeBand(8, 'E', Color(0xFF8E8E93), Color(0xFF8E8E93)),
  ];

  static const QuestismRank _fRank = QuestismRank(
    label: 'F',
    color: Color(0xFF8E8E93),
    glowColor: Color(0xFF8E8E93),
  );

  static double get maxGradeValue => _gradeBands.first.min;

  static double getNextThreshold(double value) {
    for (var i = 0; i < _gradeBands.length; i++) {
      if (value >= _gradeBands[i].min) {
        return i == 0 ? _gradeBands[i].min : _gradeBands[i - 1].min;
      }
    }
    return _gradeBands.last.min;
  }

  static double getCurrentThreshold(double value) {
    for (final band in _gradeBands) {
      if (value >= band.min) return band.min;
    }
    return 0;
  }

  static QuestismRank getRank(double value) {
    for (final band in _gradeBands) {
      if (value >= band.min) {
        return QuestismRank(
          label: band.label,
          color: band.color,
          glowColor: band.glowColor,
        );
      }
    }
    return _fRank;
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

class _GradeBand {
  final double min;
  final String label;
  final Color color;
  final Color glowColor;

  const _GradeBand(this.min, this.label, this.color, this.glowColor);
}
