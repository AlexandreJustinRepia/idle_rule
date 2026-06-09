import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';

class GhettoEnemyFactory {
  static final math.Random _random = math.Random();

  static Enemy generateRandomEnemy(int level) {
    final typeIndex = _random.nextInt(4);
    final enemyType = EnemyType.values[typeIndex];

    switch (enemyType) {
      case EnemyType.fast:
        return Enemy(
          name: 'PUNK',
          type: EnemyType.fast,
          health: 5 + (level * 1.5).floor(),
          damage: 1 + (level / 5).floor(),
          attackDelay: const Duration(milliseconds: 700),
          dodgeChance: 0.35,
          themeColor: Colors.yellowAccent,
        );
      case EnemyType.tank:
        return Enemy(
          name: 'BRUISER',
          type: EnemyType.tank,
          health: 15 + (level * 3.5).floor(),
          damage: 4 + (level / 2.5).floor(),
          attackDelay: const Duration(milliseconds: 2200),
          dodgeChance: 0.0,
          themeColor: Colors.blueAccent,
        );
      case EnemyType.counter:
        return Enemy(
          name: 'REBEL',
          type: EnemyType.counter,
          health: 8 + (level * 2).floor(),
          damage: 2 + (level / 4).floor(),
          attackDelay: const Duration(milliseconds: 1400),
          counterChance: 0.4,
          themeColor: Colors.deepPurpleAccent,
        );
      case EnemyType.regular:
      default:
        return Enemy(
          name: 'THUG',
          type: EnemyType.regular,
          health: 8 + (level * 2.2).floor(),
          damage: 2 + (level / 3.5).floor(),
          attackDelay: const Duration(milliseconds: 1300),
        );
    }
  }
}
