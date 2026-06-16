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
      reputation: _generateStat(random, 0, 10) * reputationMultiplier,
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
      strengthMultiplier: 1.1,
      speedMultiplier: 1.1,
      enduranceMultiplier: 1.1,
      intelligenceMultiplier: 1.0,
      potentialMultiplier: 1.2,
      reputationMultiplier: 1.0,
      emoji: '🌱',
    ),
    CharacterClass(
      id: 'skilled',
      name: 'Skilled',
      description: 'Trained in combat and tactics',
      gachaChance: 0.18,
      tierColor: Color(0xFF007AFF),
      glowColor: Color(0xFF007AFF),
      strengthMultiplier: 1.3,
      speedMultiplier: 1.3,
      enduranceMultiplier: 1.2,
      intelligenceMultiplier: 1.1,
      potentialMultiplier: 1.3,
      reputationMultiplier: 1.1,
      emoji: '⚔️',
    ),
    CharacterClass(
      id: 'elite',
      name: 'Elite',
      description: 'Exceptional talent in all areas',
      gachaChance: 0.12,
      tierColor: Color(0xFFFF0D00),
      glowColor: Color(0xFFFF0D00),
      strengthMultiplier: 1.5,
      speedMultiplier: 1.5,
      enduranceMultiplier: 1.4,
      intelligenceMultiplier: 1.3,
      potentialMultiplier: 1.5,
      reputationMultiplier: 1.2,
      emoji: '🔥',
    ),
    CharacterClass(
      id: 'legendary',
      name: 'Legendary',
      description: 'Born with extraordinary gifts',
      gachaChance: 0.07,
      tierColor: Color(0xFFFFCC00),
      glowColor: Color(0xFFFFCC00),
      strengthMultiplier: 1.8,
      speedMultiplier: 1.8,
      enduranceMultiplier: 1.7,
      intelligenceMultiplier: 1.5,
      potentialMultiplier: 1.8,
      reputationMultiplier: 1.4,
      emoji: '⭐',
    ),
    CharacterClass(
      id: 'mythic',
      name: 'Mythic',
      description: 'Once in a lifetime prodigy',
      gachaChance: 0.025,
      tierColor: Color(0xFFFF2D55),
      glowColor: Color(0xFFFF2D55),
      strengthMultiplier: 2.2,
      speedMultiplier: 2.2,
      enduranceMultiplier: 2.0,
      intelligenceMultiplier: 1.8,
      potentialMultiplier: 2.2,
      reputationMultiplier: 1.6,
      emoji: '💎',
    ),
    CharacterClass(
      id: 'transcendent',
      name: 'Transcendent',
      description: 'Beyond normal human limits',
      gachaChance: 0.005,
      tierColor: Color(0xFFB22222),
      glowColor: Color(0xFFB22222),
      strengthMultiplier: 2.8,
      speedMultiplier: 2.8,
      enduranceMultiplier: 2.5,
      intelligenceMultiplier: 2.2,
      potentialMultiplier: 2.8,
      reputationMultiplier: 2.0,
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
