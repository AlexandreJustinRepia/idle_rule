import 'package:flutter/material.dart';

enum TurfMapLevel {
  world('World', 0),
  country('Country', 1),
  region('Region', 2),
  province('Province', 3),
  city('City', 4),
  town('Town', 5),
  street('Street', 6);

  final String label;
  final int depth;

  const TurfMapLevel(this.label, this.depth);
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
