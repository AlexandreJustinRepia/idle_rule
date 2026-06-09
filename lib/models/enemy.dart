import 'package:flutter/material.dart';

enum EnemyType { regular, fast, tank, counter }

class Enemy {
  final String name;
  final EnemyType type;
  final int health;
  final int damage;
  final Duration attackDelay;
  final double dodgeChance;
  final double counterChance;
  final Color themeColor;

  const Enemy({
    required this.name,
    this.type = EnemyType.regular,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.0,
    this.counterChance = 0.0,
    this.themeColor = Colors.redAccent,
  });
}
