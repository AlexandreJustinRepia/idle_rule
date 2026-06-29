import 'package:flutter/material.dart';
import 'combat_entity.dart';
import 'gang.dart';

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
  final bool isStreetRecruit;
  int tier;
  int trainingLevel;
  int maxTrainingLevel;
  bool isInFormation;

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
    this.isStreetRecruit = false,
    this.tier = 1,
    this.trainingLevel = 0,
    this.maxTrainingLevel = 10,
    this.isInFormation = false,
  });

  bool get canTrain => trainingLevel < maxTrainingLevel;
  int get power => atk * 12 + maxHp + (dodgeChance * 100).round();

  void train() {
    if (!canTrain) return;
    trainingLevel++;
    maxHp += isExclusive ? 9 : 4 + tier * 2;
    atk += isExclusive ? 2 : 1 + (tier / 3).floor();
    hp = maxHp;
  }

  void promoteTo(RecruitTier nextTier) {
    if (isExclusive || nextTier.tier <= tier) return;
    tier = nextTier.tier;
    trainingLevel = 0;
    maxTrainingLevel = nextTier.maxTrainingLevel;
    maxHp = (maxHp + nextTier.baseHp).clamp(nextTier.baseHp, 99999);
    atk = (atk + nextTier.baseAtk).clamp(nextTier.baseAtk, 99999);
    hp = maxHp;
  }
}
