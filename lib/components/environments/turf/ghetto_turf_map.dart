import 'package:flutter/material.dart';
import 'turf_map.dart';

// Polygon points are normalized (0.0–1.0) relative to the map canvas size.
// The map is divided into irregular polygon territories that share borders,
// giving a real gang-territory-map feel.
//
//  Layout (approximate):
//
//   ┌──────────────────────────────────────┐
//   │  TRAIN YARD  │    BLOCK CORNER       │
//   │   (purple)   │      (orange)         │
//   ├──────────┬───┴──────────┬────────────┤
//   │  BACK    │  GRAFFITI   │  SAFE      │
//   │  ALLEY   │    AVE      │  HOUSE     │
//   │  (red)   │   (cyan)    │  (green)   │
//   └──────────┴─────────────┴────────────┘

const TurfMapData ghettoTurfMap = TurfMapData(
  title: 'GHETTO TURF',
  subtitle: 'Conquer the city blocks and secure your territory.',
  territories: [
    // ── TRAIN YARD (top-left, irregular) ──────────────────────────────────
    TurfTerritory(
      id: 'train_yard',
      label: 'Train Yard',
      description: 'A rusted rail hub with strong rivals and hidden loot.',
      color: Color(0xFF7E57C2),
      defense: 260,
      polygonPoints: [
        Offset(0.02, 0.06),
        Offset(0.48, 0.06),
        Offset(0.44, 0.13),
        Offset(0.50, 0.44),
        Offset(0.34, 0.50),
        Offset(0.20, 0.46),
        Offset(0.02, 0.50),
      ],
      labelPosition: Offset(0.24, 0.28),
    ),
    // ── BLOCK CORNER (top-right, larger) ──────────────────────────────────
    TurfTerritory(
      id: 'block_corner',
      label: 'Block Corner',
      description: 'The street intersection where power is claimed.',
      color: Color(0xFFFB8C00),
      defense: 140,
      polygonPoints: [
        Offset(0.48, 0.06),
        Offset(0.98, 0.06),
        Offset(0.98, 0.48),
        Offset(0.72, 0.52),
        Offset(0.58, 0.44),
        Offset(0.50, 0.44),
        Offset(0.44, 0.13),
      ],
      labelPosition: Offset(0.72, 0.26),
    ),
    // ── BACK ALLEY (bottom-left) ───────────────────────────────────────────
    TurfTerritory(
      id: 'back_alley',
      label: 'Back Alley',
      description: 'Narrow passages where ambushes and street fights happen.',
      color: Color(0xFFE53935),
      defense: 170,
      polygonPoints: [
        Offset(0.02, 0.50),
        Offset(0.20, 0.46),
        Offset(0.34, 0.50),
        Offset(0.30, 0.62),
        Offset(0.28, 0.94),
        Offset(0.02, 0.94),
      ],
      labelPosition: Offset(0.14, 0.72),
    ),
    // ── GRAFFITI AVENUE (bottom-center, wide) ────────────────────────────
    TurfTerritory(
      id: 'graffiti_avenue',
      label: 'Graffiti Ave',
      description: 'Tagged walls and loud crews hold this territory.',
      color: Color(0xFF4FC3F7),
      defense: 210,
      polygonPoints: [
        Offset(0.34, 0.50),
        Offset(0.50, 0.44),
        Offset(0.58, 0.44),
        Offset(0.68, 0.52),
        Offset(0.70, 0.68),
        Offset(0.64, 0.94),
        Offset(0.28, 0.94),
        Offset(0.30, 0.62),
      ],
      labelPosition: Offset(0.48, 0.72),
    ),
    // ── SAFE HOUSE (bottom-right) ─────────────────────────────────────────
    TurfTerritory(
      id: 'safe_house',
      label: 'Safe House',
      description: 'A hidden sanctuary that shields recruits and supplies.',
      color: Color(0xFF66BB6A),
      defense: 190,
      polygonPoints: [
        Offset(0.68, 0.52),
        Offset(0.72, 0.52),
        Offset(0.98, 0.48),
        Offset(0.98, 0.94),
        Offset(0.64, 0.94),
        Offset(0.70, 0.68),
      ],
      labelPosition: Offset(0.82, 0.72),
    ),
  ],
);
