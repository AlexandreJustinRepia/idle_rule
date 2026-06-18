import 'package:flutter/material.dart';

@immutable
class Gang {
  final String name;
  final String emblemId;
  final Color primaryColor;
  final Color accentColor;

  const Gang({
    required this.name,
    required this.emblemId,
    required this.primaryColor,
    required this.accentColor,
  });

  IconData get emblem => GangEmblems.byId(emblemId).icon;
}

class GangEmblemOption {
  final String id;
  final IconData icon;
  final String label;

  const GangEmblemOption({
    required this.id,
    required this.icon,
    required this.label,
  });
}

class GangEmblems {
  static const List<GangEmblemOption> all = [
    GangEmblemOption(id: 'skull', icon: Icons.dangerous, label: 'Skull'),
    GangEmblemOption(
      id: 'flame',
      icon: Icons.local_fire_department,
      label: 'Flame',
    ),
    GangEmblemOption(
      id: 'crown',
      icon: Icons.workspace_premium,
      label: 'Crown',
    ),
    GangEmblemOption(
      id: 'fist',
      icon: Icons.sports_martial_arts,
      label: 'Fist',
    ),
    GangEmblemOption(id: 'wolf', icon: Icons.pets, label: 'Wolf'),
    GangEmblemOption(id: 'star', icon: Icons.star, label: 'Star'),
    GangEmblemOption(id: 'bolt', icon: Icons.bolt, label: 'Bolt'),
    GangEmblemOption(id: 'diamond', icon: Icons.diamond, label: 'Diamond'),
    GangEmblemOption(id: 'shield', icon: Icons.shield, label: 'Shield'),
    GangEmblemOption(id: 'snake', icon: Icons.water, label: 'Serpent'),
  ];

  static GangEmblemOption byId(String id) {
    return all.firstWhere((emblem) => emblem.id == id, orElse: () => all.first);
  }
}

class GangCreationRequirements {
  static const int moneyCost = 500;
  static const double reputationRequired = 10.0;
}

class GangBuildingStage {
  final String name;
  final int minLevel;

  const GangBuildingStage({required this.name, required this.minLevel});
}

class GangBuildings {
  static const List<GangBuildingStage> stages = [
    GangBuildingStage(name: 'Hangout Spot', minLevel: 1),
    GangBuildingStage(name: 'Training Center', minLevel: 10),
    GangBuildingStage(name: 'Crew HQ', minLevel: 20),
  ];
}

class RecruitTier {
  final int tier;
  final String name;
  final String description;
  final int requiredBuildingStage;
  final int requiredBuildingLevel;
  final Duration trainingTime;
  final int cost;
  final int baseHp;
  final int baseAtk;
  final int maxTrainingLevel;

  const RecruitTier({
    required this.tier,
    required this.name,
    required this.description,
    required this.requiredBuildingStage,
    required this.requiredBuildingLevel,
    required this.trainingTime,
    required this.cost,
    required this.baseHp,
    required this.baseAtk,
    required this.maxTrainingLevel,
  });

  bool isUnlocked(int buildingStage, int buildingLevel) {
    if (buildingStage > requiredBuildingStage) return true;
    return buildingStage == requiredBuildingStage &&
        buildingLevel >= requiredBuildingLevel;
  }

  String get unlockText =>
      '${GangBuildings.stages[requiredBuildingStage].name} Lv.$requiredBuildingLevel';
}

class RecruitTiers {
  static const List<RecruitTier> all = [
    RecruitTier(
      tier: 1,
      name: 'Rookie',
      description: 'Just joined the crew.',
      requiredBuildingStage: 0,
      requiredBuildingLevel: 1,
      trainingTime: Duration(seconds: 10),
      cost: 35,
      baseHp: 24,
      baseAtk: 2,
      maxTrainingLevel: 8,
    ),
    RecruitTier(
      tier: 2,
      name: 'Street Punk',
      description: 'Always looking for trouble.',
      requiredBuildingStage: 0,
      requiredBuildingLevel: 10,
      trainingTime: Duration(seconds: 30),
      cost: 85,
      baseHp: 40,
      baseAtk: 5,
      maxTrainingLevel: 10,
    ),
    RecruitTier(
      tier: 3,
      name: 'Enforcer',
      description: 'The muscle of the organization.',
      requiredBuildingStage: 1,
      requiredBuildingLevel: 5,
      trainingTime: Duration(minutes: 2),
      cost: 180,
      baseHp: 78,
      baseAtk: 10,
      maxTrainingLevel: 12,
    ),
    RecruitTier(
      tier: 4,
      name: 'Lieutenant',
      description: 'A leader who earned respect through fights.',
      requiredBuildingStage: 1,
      requiredBuildingLevel: 20,
      trainingTime: Duration(minutes: 10),
      cost: 420,
      baseHp: 135,
      baseAtk: 18,
      maxTrainingLevel: 15,
    ),
    RecruitTier(
      tier: 5,
      name: 'Captain',
      description: 'Controls entire blocks for the organization.',
      requiredBuildingStage: 2,
      requiredBuildingLevel: 10,
      trainingTime: Duration(minutes: 30),
      cost: 1200,
      baseHp: 260,
      baseAtk: 32,
      maxTrainingLevel: 20,
    ),
  ];

  static RecruitTier byTier(int tier) {
    return all.firstWhere((option) => option.tier == tier);
  }
}

class GangColorPresets {
  static const List<Color> primary = [
    Color(0xFFE24B4A),
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFAF52DE),
    Color(0xFFFF2D55),
    Color(0xFF8E8E93),
    Color(0xFFFFCC00),
    Color(0xFF00C7BE),
    Color(0xFFB22222),
  ];

  static const List<Color> accent = [
    Color(0xFF111111),
    Color(0xFFFFFFFF),
    Color(0xFFFFD60A),
    Color(0xFF64D2FF),
    Color(0xFFBF5AF2),
    Color(0xFFFF375F),
    Color(0xFF30D158),
    Color(0xFFFF9F0A),
    Color(0xFF5E5CE6),
    Color(0xFF48484A),
  ];
}
