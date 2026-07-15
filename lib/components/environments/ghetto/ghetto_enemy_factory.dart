import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';

class GhettoEnemyFactory {
  static final math.Random _random = math.Random();
  static const List<String> _firstNames = [
    'Mace', 'Rico', 'Talon', 'Vince', 'Nero', 'Silas', 'Kade', 'Brix',
    'Zane', 'Marco', 'Lex', 'Tori', 'Nova', 'Raze', 'Iris', 'Knox',
  ];
  static const List<String> _lastNames = [
    'Cross', 'Vale', 'Stone', 'Reyes', 'Hale', 'Voss', 'Crowe', 'Rook',
    'Banks', 'Sable', 'Drake', 'Kane', 'Frost', 'Wolfe', 'Rivers', 'Steel',
  ];

  static String _randomName(String alias) {
    final first = _firstNames[_random.nextInt(_firstNames.length)];
    final last = _lastNames[_random.nextInt(_lastNames.length)];
    return '$first "$alias" $last';
  }

  static Enemy generateRandomEnemy(int level, PlayerStats playerStats, {String? streetControllingGangName}) {
    final typeIndex = _random.nextInt(4);
    final enemyType = EnemyType.values[typeIndex];

    // Select NPC Type
    final npcRandom = _random.nextDouble();
    NpcType npcType;
    String alias = 'Ace';
    Color defaultColor = Colors.redAccent;

    if (npcRandom < 0.25) {
      npcType = NpcType.civilian;
      alias = 'Civilian';
      defaultColor = Colors.grey;
    } else if (npcRandom < 0.55) {
      npcType = NpcType.thug;
      alias = 'Thug';
      defaultColor = Colors.deepOrangeAccent;
    } else if (npcRandom < 0.70) {
      npcType = NpcType.merchant;
      alias = 'Hustler';
      defaultColor = Colors.greenAccent;
    } else if (npcRandom < 0.85) {
      npcType = NpcType.cop;
      alias = 'Officer';
      defaultColor = Colors.blueAccent;
    } else {
      if (streetControllingGangName != null && streetControllingGangName.isNotEmpty) {
        npcType = NpcType.gangMember;
        alias = 'Gangster';
        defaultColor = Colors.purpleAccent;
      } else {
        npcType = NpcType.thug;
        alias = 'Thug';
        defaultColor = Colors.deepOrangeAccent;
      }
    }

    // REPUTATION SCALING
    double repMod = 1.0 + (playerStats.reputation / 100);

    // ADAPTIVE INTELLIGENCE CALCULATIONS
    double playerPower = playerStats.attackDamage.toDouble();
    double expectedPower = 2.0 + (level * 1.2);
    double powerRatio = (playerPower / expectedPower).clamp(1.0, 3.0);

    double adaptiveDodge = (powerRatio - 1.0) * 0.15;
    double adaptiveSpeedMult = 1.0 - ((powerRatio - 1.0) * 0.25);
    double adaptiveCombo = (powerRatio - 1.0) * 0.20;

    final look = generateNpcCustomization(
      _random.nextInt(1 << 30),
      palette: _enemyTypeColor(enemyType) ?? defaultColor,
    );

    // Calculate base health and damage based on NPC type
    int baseHealth = 8;
    int baseDamage = 2;
    double dodgeModifier = 0.0;
    double counterChance = 0.0;

    switch (npcType) {
      case NpcType.civilian:
        baseHealth = 5; // civilians are weaker
        baseDamage = 1;
        dodgeModifier = 0.1; // but run/dodge more
        break;
      case NpcType.thug:
        baseHealth = 10;
        baseDamage = 3;
        break;
      case NpcType.merchant:
        baseHealth = 8;
        baseDamage = 2;
        break;
      case NpcType.cop:
        baseHealth = 15; // cops are tough
        baseDamage = 4;
        counterChance = 0.2;
        break;
      case NpcType.gangMember:
        baseHealth = 11;
        baseDamage = 3;
        counterChance = 0.1;
        break;
    }

    switch (enemyType) {
      case EnemyType.fast:
        return Enemy(
          name: _randomName(alias),
          type: EnemyType.fast,
          npcType: npcType,
          health: (((baseHealth * 0.8) + (level * 1.2).floor()) * repMod).floor().clamp(3, 9999),
          damage: (((baseDamage * 0.8) + (level / 6).floor()) * repMod).floor().clamp(1, 999),
          attackDelay: Duration(
            milliseconds: (700 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.35 + adaptiveDodge + dodgeModifier).clamp(0.0, 0.75),
          comboChance: adaptiveCombo * 1.5,
          themeColor: defaultColor,
          customization: look,
        );
      case EnemyType.tank:
        return Enemy(
          name: _randomName(alias),
          type: EnemyType.tank,
          npcType: npcType,
          health: (((baseHealth * 1.8) + (level * 3.0).floor()) * repMod).floor().clamp(8, 9999),
          damage: (((baseDamage * 1.5) + (level / 3.0).floor()) * repMod).floor().clamp(1, 999),
          attackDelay: Duration(
            milliseconds: (2200 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.0 + adaptiveDodge).clamp(0.0, 0.4),
          comboChance: adaptiveCombo * 0.5,
          themeColor: defaultColor,
          customization: look,
        );
      case EnemyType.counter:
        return Enemy(
          name: _randomName(alias),
          type: EnemyType.counter,
          npcType: npcType,
          health: (((baseHealth * 1.0) + (level * 1.8).floor()) * repMod).floor().clamp(5, 9999),
          damage: (((baseDamage * 1.0) + (level / 4.5).floor()) * repMod).floor().clamp(1, 999),
          attackDelay: Duration(
            milliseconds: (1400 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (0.1 + adaptiveDodge + dodgeModifier).clamp(0.0, 0.5),
          counterChance: (0.4 + adaptiveDodge + counterChance).clamp(0.0, 0.8),
          comboChance: adaptiveCombo,
          themeColor: defaultColor,
          customization: look,
        );
      case EnemyType.regular:
        return Enemy(
          name: _randomName(alias),
          type: EnemyType.regular,
          npcType: npcType,
          health: (((baseHealth * 1.0) + (level * 2.0).floor()) * repMod).floor().clamp(4, 9999),
          damage: (((baseDamage * 1.0) + (level / 3.8).floor()) * repMod).floor().clamp(1, 999),
          attackDelay: Duration(
            milliseconds: (1300 * adaptiveSpeedMult).round(),
          ),
          dodgeChance: (adaptiveDodge + dodgeModifier).clamp(0.0, 0.45),
          comboChance: adaptiveCombo,
          themeColor: defaultColor,
          customization: look,
        );
    }
  }

  static Color? _enemyTypeColor(EnemyType type) {
    switch (type) {
      case EnemyType.fast:
        return Colors.yellowAccent;
      case EnemyType.tank:
        return Colors.blueAccent;
      case EnemyType.counter:
        return Colors.deepPurpleAccent;
      case EnemyType.regular:
        return null;
    }
  }
}
