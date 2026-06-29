import 'package:flutter/material.dart';

enum TurfMapLevel {
  country('Country', 0),
  region('Region', 1),
  province('Province', 2),
  city('City', 3),
  town('Town', 4),
  street('Street', 5);

  final String label;
  final int depth;

  const TurfMapLevel(this.label, this.depth);
}

enum StreetType {
  ghetto('Ghetto', 'assets/background/ghetto.png'),
  harbor('Harbor', 'assets/background/harbor.png'),
  school('School', 'assets/background/school.png'),
  downtown('Downtown', 'assets/background/downtown.png'),
  suburban('Suburban', 'assets/background/suburban.png'),
  chinatown('Chinatown', 'assets/background/chinatown.png'),
  industrial('Industrial', 'assets/background/industrial.png'),
  entertainment('Entertainment', 'assets/background/entertainment.png');

  final String label;
  final String assetPath;

  const StreetType(this.label, this.assetPath);
}

class TurfTerritory {
  final String id;
  final String label;
  final String description;
  final Color color;
  final int defense;
  final TurfMapLevel level;
  final String? parentId;
  final String? occupyingGangId;
  final String? backgroundAsset;
  final StreetType? streetType;

  /// Bounds are normalized (0.0-1.0) relative to the full map canvas.
  final Rect bounds;

  const TurfTerritory({
    required this.id,
    required this.label,
    required this.description,
    required this.color,
    required this.defense,
    required this.level,
    required this.bounds,
    this.parentId,
    this.occupyingGangId,
    this.backgroundAsset,
    this.streetType,
  });

  Offset get center => bounds.center;
}

class TurfMapData {
  final String title;
  final String subtitle;
  final List<TurfTerritory> territories;
  final String spawnStreetId;

  const TurfMapData({
    required this.title,
    required this.subtitle,
    required this.territories,
    required this.spawnStreetId,
  });

  TurfTerritory territoryById(String id) =>
      territories.firstWhere((territory) => territory.id == id);

  List<TurfTerritory> territoriesAtLevel(TurfMapLevel level) =>
      territories.where((territory) => territory.level == level).toList();
}
