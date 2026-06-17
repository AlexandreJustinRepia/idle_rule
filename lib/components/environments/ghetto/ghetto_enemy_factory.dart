import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';

class GhettoEnemyFactory {
  static final math.Random _random = math.Random();
  static const List<String> _firstNames = [
    'Mace',
    'Rico',
    'Talon',
    'Vince',
    'Nero',
    'Silas',
    'Kade',
    'Brix',
    'Zane',
    'Marco',
    'Lex',
    'Tori',
    'Nova',
    'Raze',
    'Iris',
    'Knox',
  ];
  static const List<String> _lastNames = [
    'Cross',
    'Vale',
    'Stone',
    'Reyes',
    'Hale',
    'Voss',
    'Crowe',
    'Rook',
    'Banks',
    'Sable',
    'Drake',
    'Kane',
    'Frost',
    'Wolfe',
    'Rivers',
    'Steel',
  ];

  static String _randomName(String alias) {
    final first = _firstNames[_random.nextInt(_firstNames.length)];
    final last = _lastNames[_random.nextInt(_lastNames.length)];
    return '$first "$alias" $last';
  }

  static Enemy generateRandomEnemy(int level, PlayerStats playerStats) {
    final typeIndex = _random.nextInt(4);
    final enemyType = EnemyType.values[typeIndex];

    // REPUTATION SCALING
    // Higher reputation means enemies are more prepared and tougher
    double repMod =
        1.0 + (playerStats.reputation / 100); // +1% stats per reputation point

    // ADAPTIVE INTELLIGENCE CALCULATIONS
    double playerPower = playerStats.attackDamage.toDouble();
    double expectedPower = 2.0 + (level * 1.2);
    double powerRatio = (playerPower / expectedPower).clamp(1.0, 3.0);

    // Adaptive modifiers
    double adaptiveDodge = (powerRatio - 1.0) * 0.15;
    double adaptiveSpeedMult = 1.0 - ((powerRatio - 1.0) * 0.25);
    double adaptiveCombo = (powerRatio - 1.0) * 0.20;

    switch (enemyType) {
      case EnemyType.fast:
        return Enemy(
          name: _randomName('Flash'),
          type: EnemyType.fast,
          health: ((5 + (level * 1.5).floor()) * repMod).floor(),
          damage: ((1 + (level / 5).floor()) * repMod).floor(),
          attackDelay: Duration(
            milliseconds: (700 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.35 + adaptiveDodge).clamp(0.0, 0.7),
          comboChance: adaptiveCombo * 1.5,
          themeColor: Colors.yellowAccent,
        );
      case EnemyType.tank:
        return Enemy(
          name: _randomName('Brick'),
          type: EnemyType.tank,
          health: ((15 + (level * 3.5).floor()) * repMod).floor(),
          damage: ((4 + (level / 2.5).floor()) * repMod).floor(),
          attackDelay: Duration(
            milliseconds: (2200 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.0 + adaptiveDodge).clamp(0.0, 0.4),
          comboChance: adaptiveCombo * 0.5,
          themeColor: Colors.blueAccent,
        );
      case EnemyType.counter:
        return Enemy(
          name: _randomName('Switch'),
          type: EnemyType.counter,
          health: ((8 + (level * 2).floor()) * repMod).floor(),
          damage: ((2 + (level / 4).floor()) * repMod).floor(),
          attackDelay: Duration(
            milliseconds: (1400 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.1 + adaptiveDodge).clamp(0.0, 0.5),
          counterChance: (0.4 + adaptiveDodge).clamp(0.0, 0.8),
          comboChance: adaptiveCombo,
          themeColor: Colors.deepPurpleAccent,
        );
      case EnemyType.regular:
        return Enemy(
          name: _randomName('Ace'),
          type: EnemyType.regular,
          health: ((8 + (level * 2.2).floor()) * repMod).floor(),
          damage: ((2 + (level / 3.5).floor()) * repMod).floor(),
          attackDelay: Duration(
            milliseconds: (1300 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: adaptiveDodge.clamp(0.0, 0.4),
          comboChance: adaptiveCombo,
        );
    }
  }
}
