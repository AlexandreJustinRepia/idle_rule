import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';

class GhettoEnemyFactory {
  static final math.Random _random = math.Random();

  static Enemy generateRandomEnemy(int level, PlayerStats playerStats) {
    final typeIndex = _random.nextInt(4);
    final enemyType = EnemyType.values[typeIndex];

    // ADAPTIVE INTELLIGENCE CALCULATIONS
    // Calculate how "overpowered" the player is for this level
    // Expected strength at level X is roughly level * 2
    double playerPower = playerStats.attackDamage.toDouble();
    double expectedPower = 2.0 + (level * 1.2);
    double powerRatio = (playerPower / expectedPower).clamp(1.0, 3.0);
    
    // Adaptive modifiers
    double adaptiveDodge = (powerRatio - 1.0) * 0.15; // Up to +15% dodge
    double adaptiveSpeedMult = 1.0 - ((powerRatio - 1.0) * 0.25); // Up to 25% faster
    double adaptiveCombo = (powerRatio - 1.0) * 0.20; // Up to 20% combo chance

    switch (enemyType) {
      case EnemyType.fast:
        return Enemy(
          name: 'PUNK',
          type: EnemyType.fast,
          health: 5 + (level * 1.5).floor(),
          damage: 1 + (level / 5).floor(),
          attackDelay: Duration(milliseconds: (700 * adaptiveSpeedMult).round()),
          dodgeChance: (0.35 + adaptiveDodge).clamp(0.0, 0.7),
          comboChance: adaptiveCombo * 1.5,
          themeColor: Colors.yellowAccent,
        );
      case EnemyType.tank:
        return Enemy(
          name: 'BRUISER',
          type: EnemyType.tank,
          health: 15 + (level * 3.5).floor(),
          damage: 4 + (level / 2.5).floor(),
          attackDelay: Duration(milliseconds: (2200 * adaptiveSpeedMult).round()),
          dodgeChance: (0.0 + adaptiveDodge).clamp(0.0, 0.4),
          comboChance: adaptiveCombo * 0.5,
          themeColor: Colors.blueAccent,
        );
      case EnemyType.counter:
        return Enemy(
          name: 'REBEL',
          type: EnemyType.counter,
          health: 8 + (level * 2).floor(),
          damage: 2 + (level / 4).floor(),
          attackDelay: Duration(milliseconds: (1400 * adaptiveSpeedMult).round()),
          dodgeChance: (0.1 + adaptiveDodge).clamp(0.0, 0.5),
          counterChance: (0.4 + adaptiveDodge).clamp(0.0, 0.8),
          comboChance: adaptiveCombo,
          themeColor: Colors.deepPurpleAccent,
        );
      case EnemyType.regular:
        return Enemy(
          name: 'THUG',
          type: EnemyType.regular,
          health: 8 + (level * 2.2).floor(),
          damage: 2 + (level / 3.5).floor(),
          attackDelay: Duration(milliseconds: (1300 * adaptiveSpeedMult).round()),
          dodgeChance: adaptiveDodge.clamp(0.0, 0.4),
          comboChance: adaptiveCombo,
        );
    }
  }
}
