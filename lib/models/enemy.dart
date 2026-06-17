import 'package:flutter/material.dart';
import 'combat_entity.dart';

enum EnemyType { regular, fast, tank, counter }

class Enemy implements CombatEntity {
  @override
  final String name;
  final EnemyType type;

  /// Base health from definition
  final int health;

  /// Base damage from definition
  final int damage;

  @override
  final Duration attackDelay;

  @override
  final double dodgeChance;

  final double counterChance;
  final double comboChance; // Chance to strike again immediately

  final Color themeColor;
  final bool isBoss;

  @override
  int hp;

  @override
  ActionState actionState;

  @override
  CombatEntity? target;

  Enemy({
    required this.name,
    this.type = EnemyType.regular,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.0,
    this.counterChance = 0.0,
    this.comboChance = 0.0,
    this.themeColor = Colors.redAccent,
    this.isBoss = false,
    this.actionState = ActionState.idle,
    this.target,
  }) : hp = health;

  @override
  int get maxHp => health;

  @override
  int get atk => damage;

  /// Copy method to create a new instance for combat
  Enemy copy() {
    return Enemy(
      name: name,
      type: type,
      health: health,
      damage: damage,
      attackDelay: attackDelay,
      dodgeChance: dodgeChance,
      counterChance: counterChance,
      comboChance: comboChance,
      themeColor: themeColor,
      isBoss: isBoss,
    );
  }
}
