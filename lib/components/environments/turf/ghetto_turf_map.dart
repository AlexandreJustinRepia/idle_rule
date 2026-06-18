import 'package:flutter/material.dart';
import 'turf_map.dart';

const TurfMapData ghettoTurfMap = TurfMapData(
  title: 'GHETTO TURF',
  subtitle: 'Conquer the city blocks and secure your territory.',
  territories: [
    TurfTerritory(
      id: 'train_yard',
      label: 'Train Yard',
      description: 'A rusted rail hub with strong rivals and hidden loot.',
      position: Alignment(-0.75, -0.45),
      widthFactor: 0.28,
      heightFactor: 0.18,
      color: Color(0xFF7E57C2),
      defense: 260,
    ),
    TurfTerritory(
      id: 'block_corner',
      label: 'Block Corner',
      description: 'The street intersection where power is claimed.',
      position: Alignment(0.55, -0.55),
      widthFactor: 0.24,
      heightFactor: 0.16,
      color: Color(0xFFFB8C00),
      defense: 140,
    ),
    TurfTerritory(
      id: 'graffiti_avenue',
      label: 'Graffiti Ave',
      description: 'Tagged walls and loud crews hold this territory.',
      position: Alignment(-0.1, -0.1),
      widthFactor: 0.32,
      heightFactor: 0.20,
      color: Color(0xFF4FC3F7),
      defense: 210,
    ),
    TurfTerritory(
      id: 'safe_house',
      label: 'Safe House',
      description: 'A hidden sanctuary that shields recruits and supplies.',
      position: Alignment(0.7, 0.18),
      widthFactor: 0.24,
      heightFactor: 0.18,
      color: Color(0xFF66BB6A),
      defense: 190,
    ),
    TurfTerritory(
      id: 'back_alley',
      label: 'Back Alley',
      description: 'Narrow passages where ambushes and street fights happen.',
      position: Alignment(-0.65, 0.3),
      widthFactor: 0.28,
      heightFactor: 0.18,
      color: Color(0xFFE53935),
      defense: 170,
    ),
  ],
);
