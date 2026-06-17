import 'package:flutter/material.dart';
import 'combat_entity.dart';

class Ally implements CombatEntity {
  @override
  final String name;

  @override
  int hp;

  @override
  int maxHp;

  @override
  int atk;

  @override
  final Duration attackDelay;

  @override
  final double dodgeChance;

  @override
  ActionState actionState;

  @override
  CombatEntity? target;

  final Color themeColor;
  final bool isExclusive;
  int trainingLevel;
  final int maxTrainingLevel;

  Ally({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.atk,
    required this.attackDelay,
    this.dodgeChance = 0.1,
    this.actionState = ActionState.idle,
    this.themeColor = Colors.greenAccent,
    this.isExclusive = false,
    this.trainingLevel = 0,
    this.maxTrainingLevel = 10,
  });

  bool get canTrain => trainingLevel < maxTrainingLevel;

  void train() {
    if (!canTrain) return;
    trainingLevel++;
    maxHp += isExclusive ? 9 : 6;
    atk += isExclusive ? 2 : 1;
    hp = maxHp;
  }
}
