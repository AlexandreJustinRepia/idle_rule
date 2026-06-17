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
    GangEmblemOption(id: 'flame', icon: Icons.local_fire_department, label: 'Flame'),
    GangEmblemOption(id: 'crown', icon: Icons.workspace_premium, label: 'Crown'),
    GangEmblemOption(id: 'fist', icon: Icons.sports_martial_arts, label: 'Fist'),
    GangEmblemOption(id: 'wolf', icon: Icons.pets, label: 'Wolf'),
    GangEmblemOption(id: 'star', icon: Icons.star, label: 'Star'),
    GangEmblemOption(id: 'bolt', icon: Icons.bolt, label: 'Bolt'),
    GangEmblemOption(id: 'diamond', icon: Icons.diamond, label: 'Diamond'),
    GangEmblemOption(id: 'shield', icon: Icons.shield, label: 'Shield'),
    GangEmblemOption(id: 'snake', icon: Icons.water, label: 'Serpent'),
  ];

  static GangEmblemOption byId(String id) {
    return all.firstWhere(
      (emblem) => emblem.id == id,
      orElse: () => all.first,
    );
  }
}

class GangCreationRequirements {
  static const int moneyCost = 500;
  static const double reputationRequired = 10.0;
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
