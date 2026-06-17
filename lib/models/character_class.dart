import 'dart:math';
import 'package:flutter/material.dart';
import 'player_stats.dart';

class CharacterClass {
  final String id;
  final String name;
  final String description;
  final double gachaChance;
  final Color tierColor;
  final Color glowColor;
  final double strengthMultiplier;
  final double speedMultiplier;
  final double enduranceMultiplier;
  final double intelligenceMultiplier;
  final double potentialMultiplier;
  final double reputationMultiplier;
  final String emoji;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.description,
    required this.gachaChance,
    required this.tierColor,
    required this.glowColor,
    this.strengthMultiplier = 1.0,
    this.speedMultiplier = 1.0,
    this.enduranceMultiplier = 1.0,
    this.intelligenceMultiplier = 1.0,
    this.potentialMultiplier = 1.0,
    this.reputationMultiplier = 1.0,
    required this.emoji,
  });

  PlayerStats generateBaseStats(Random random) {
    final baseStats = PlayerStats(
      strength: _generateStat(random, 10, 30) * strengthMultiplier,
      speed: _generateStat(random, 10, 30) * speedMultiplier,
      endurance: _generateStat(random, 10, 30) * enduranceMultiplier,
      intelligence: _generateStat(random, 30, 50) * intelligenceMultiplier,
      potential: _generateStat(random, 30, 50) * potentialMultiplier,
      reputation: 0,
    );
    return baseStats;
  }

  double _generateStat(Random random, double min, double max) {
    return min + random.nextDouble() * (max - min);
  }
}

class CharacterClasses {
  static const List<CharacterClass> allClasses = [
    CharacterClass(
      id: 'normal',
      name: 'Normal',
      description: 'Average person with no special abilities',
      gachaChance: 0.35,
      tierColor: Color(0xFF8E8E93),
      glowColor: Color(0xFF8E8E93),
      emoji: '👤',
    ),
    CharacterClass(
      id: 'novice',
      name: 'Novice',
      description: 'A beginner with slight potential',
      gachaChance: 0.25,
      tierColor: Color(0xFF34C759),
      glowColor: Color(0xFF34C759),
      strengthMultiplier: 1.10,
      speedMultiplier: 1.10,
      enduranceMultiplier: 1.08,
      intelligenceMultiplier: 1.05,
      potentialMultiplier: 1.12,
      reputationMultiplier: 1.00,
      emoji: '🌱',
    ),
    CharacterClass(
      id: 'skilled',
      name: 'Skilled',
      description: 'Trained in combat and tactics',
      gachaChance: 0.18,
      tierColor: Color(0xFF007AFF),
      glowColor: Color(0xFF007AFF),
      strengthMultiplier: 1.22,
      speedMultiplier: 1.22,
      enduranceMultiplier: 1.18,
      intelligenceMultiplier: 1.12,
      potentialMultiplier: 1.24,
      reputationMultiplier: 1.05,
      emoji: '⚔️',
    ),
    CharacterClass(
      id: 'elite',
      name: 'Elite',
      description: 'Exceptional talent in all areas',
      gachaChance: 0.12,
      tierColor: Color(0xFFFF0D00),
      glowColor: Color(0xFFFF0D00),
      strengthMultiplier: 1.36,
      speedMultiplier: 1.36,
      enduranceMultiplier: 1.30,
      intelligenceMultiplier: 1.20,
      potentialMultiplier: 1.38,
      reputationMultiplier: 1.10,
      emoji: '🔥',
    ),
    CharacterClass(
      id: 'legendary',
      name: 'Legendary',
      description: 'Born with extraordinary gifts',
      gachaChance: 0.07,
      tierColor: Color(0xFFFFCC00),
      glowColor: Color(0xFFFFCC00),
      strengthMultiplier: 1.52,
      speedMultiplier: 1.52,
      enduranceMultiplier: 1.44,
      intelligenceMultiplier: 1.30,
      potentialMultiplier: 1.54,
      reputationMultiplier: 1.15,
      emoji: '⭐',
    ),
    CharacterClass(
      id: 'mythic',
      name: 'Mythic',
      description: 'Once in a lifetime prodigy',
      gachaChance: 0.025,
      tierColor: Color(0xFFFF2D55),
      glowColor: Color(0xFFFF2D55),
      strengthMultiplier: 1.70,
      speedMultiplier: 1.70,
      enduranceMultiplier: 1.60,
      intelligenceMultiplier: 1.42,
      potentialMultiplier: 1.72,
      reputationMultiplier: 1.22,
      emoji: '💎',
    ),
    CharacterClass(
      id: 'transcendent',
      name: 'Transcendent',
      description: 'Beyond normal human limits',
      gachaChance: 0.005,
      tierColor: Color(0xFFB22222),
      glowColor: Color(0xFFB22222),
      strengthMultiplier: 1.90,
      speedMultiplier: 1.90,
      enduranceMultiplier: 1.78,
      intelligenceMultiplier: 1.55,
      potentialMultiplier: 1.92,
      reputationMultiplier: 1.30,
      emoji: '👑',
    ),
  ];

  static CharacterClass rollClass(Random random) {
    final roll = random.nextDouble();
    var cumulative = 0.0;
    
    for (final charClass in allClasses) {
      cumulative += charClass.gachaChance;
      if (roll <= cumulative) {
        return charClass;
      }
    }
    
    return allClasses.first;
  }

  static CharacterClass getClassById(String id) {
    return allClasses.firstWhere(
      (c) => c.id == id,
      orElse: () => allClasses.first,
    );
  }

  static String getTierLabel(CharacterClass charClass) {
    switch (charClass.id) {
      case 'normal':
        return 'N';
      case 'novice':
        return 'R';
      case 'skilled':
        return 'SR';
      case 'elite':
        return 'SSR';
      case 'legendary':
        return 'UR';
      case 'mythic':
        return 'LR';
      case 'transcendent':
        return 'MR';
      default:
        return 'N';
    }
  }
}
