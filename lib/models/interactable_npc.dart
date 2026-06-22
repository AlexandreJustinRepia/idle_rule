import 'package:flutter/material.dart';

enum NpcRelationshipTier {
  hostile('Hostile', Color(0xFFD9383A)),
  aggressive('Aggressive', Color(0xFFFF9500)),
  neutral('Neutral', Color(0xFF8E8E93)),
  friendly('Friendly', const Color(0xFF34C759)),
  loyal('Loyal', const Color(0xFF30D158));

  final String label;
  final Color color;

  const NpcRelationshipTier(this.label, this.color);
}

class InteractableNpc {
  final String id;
  final String name;
  final String description;
  int level;
  int hp;
  int maxHp;
  int atk;
  double dodgeChance;
  double reputation;
  int relationship; // -100 to 100
  String locationStreetId;
  bool isRecruited;

  InteractableNpc({
    required this.id,
    required this.name,
    required this.description,
    this.level = 1,
    required this.hp,
    required this.maxHp,
    required this.atk,
    this.dodgeChance = 0.05,
    this.reputation = 10.0,
    this.relationship = 0,
    required this.locationStreetId,
    this.isRecruited = false,
  });

  NpcRelationshipTier get relationshipTier {
    if (relationship < -50) return NpcRelationshipTier.hostile;
    if (relationship < -10) return NpcRelationshipTier.aggressive;
    if (relationship <= 30) return NpcRelationshipTier.neutral;
    if (relationship <= 70) return NpcRelationshipTier.friendly;
    return NpcRelationshipTier.loyal;
  }

  void levelUp() {
    level++;
    maxHp = (maxHp * 1.15).round();
    hp = maxHp;
    atk = (atk * 1.12).round();
    reputation += 5.0;
  }

  void changeRelationship(int delta) {
    relationship = (relationship + delta).clamp(-100, 100);
  }
}
