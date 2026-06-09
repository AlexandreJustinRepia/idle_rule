import 'package:flutter/material.dart';

class Boss {
  final String name;
  final int health;
  final int damage;
  final double dodgeChance;
  final Duration attackDelay;
  final Color themeColor;

  const Boss({
    required this.name,
    required this.health,
    required this.damage,
    required this.attackDelay,
    this.dodgeChance = 0.05,
    this.themeColor = Colors.red,
  });
}

final List<Boss> gameBosses = [
  Boss(
    name: 'BIG MAMA',
    health: 150,
    damage: 8,
    attackDelay: const Duration(milliseconds: 1800),
    themeColor: Colors.deepOrange,
  ),
  Boss(
    name: 'SLICK RICK',
    health: 100,
    damage: 5,
    attackDelay: const Duration(milliseconds: 800),
    dodgeChance: 0.25,
    themeColor: Colors.purpleAccent,
  ),
  Boss(
    name: 'THE GHOST',
    health: 250,
    damage: 12,
    attackDelay: const Duration(milliseconds: 1400),
    dodgeChance: 0.15,
    themeColor: Colors.blueGrey,
  ),
];
