import 'package:flutter/material.dart';
import 'combat_entity.dart';

class Ally implements CombatEntity {
  @override
  final String name;
  
  @override
  int hp;
  
  @override
  final int maxHp;
  
  @override
  final int atk;
  
  @override
  final Duration attackDelay;
  
  @override
  final double dodgeChance;

  @override
  ActionState actionState;

  @override
  CombatEntity? target;

  final Color themeColor;

  Ally({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.atk,
    required this.attackDelay,
    this.dodgeChance = 0.1,
    this.actionState = ActionState.idle,
    this.themeColor = Colors.greenAccent,
  });
}
