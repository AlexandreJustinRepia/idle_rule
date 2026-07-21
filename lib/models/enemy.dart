import 'package:flutter/material.dart';
import 'combat_entity.dart';
import 'character_customization.dart';

enum EnemyType { regular, fast, tank, counter }
enum NpcType { civilian, thug, gangMember, merchant, cop, playerCharacter }

class Enemy implements CombatEntity {
  @override
  final String name;
  final EnemyType type;
  final NpcType npcType;

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
  final CharacterCustomization? customization;

  @override
  int hp;

  @override
  ActionState actionState;

  @override
  CombatEntity? target;

  Enemy({
    required this.name,
    this.type = EnemyType.regular,
    this.npcType = NpcType.thug,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.0,
    this.counterChance = 0.0,
    this.comboChance = 0.0,
    this.themeColor = Colors.redAccent,
    this.isBoss = false,
    this.customization,
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
      npcType: npcType,
      health: health,
      damage: damage,
      attackDelay: attackDelay,
      dodgeChance: dodgeChance,
      counterChance: counterChance,
      comboChance: comboChance,
      themeColor: themeColor,
      isBoss: isBoss,
      customization: customization,
    );
  }

  Enemy copyWith({Color? themeColor, NpcType? npcType}) {
    return Enemy(
      name: name,
      type: type,
      npcType: npcType ?? this.npcType,
      health: health,
      damage: damage,
      attackDelay: attackDelay,
      dodgeChance: dodgeChance,
      counterChance: counterChance,
      comboChance: comboChance,
      themeColor: themeColor ?? this.themeColor,
      isBoss: isBoss,
      customization: customization,
    );
  }
}
