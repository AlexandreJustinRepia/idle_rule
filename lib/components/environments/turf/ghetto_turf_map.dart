import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'turf_map.dart';

final TurfMapData ghettoTurfMap = createGhettoTurfMap();

TurfMapData createGhettoTurfMap({String title = 'IRONVALE TURF'}) {
  final territories = <TurfTerritory>[];
  final streetIds = <String>[];

  territories.add(
    const TurfTerritory(
      id: 'ironvale',
      label: 'Ironvale',
      description:
          'One country split into provinces, cities, towns, and turf streets.',
      color: Color(0xFF455A64),
      defense: 0,
      level: TurfMapLevel.country,
      bounds: Rect.fromLTWH(0.04, 0.04, 0.92, 0.92),
    ),
  );

  final provinces = [
    _RegionSeed(
      'north_yard',
      'North Yard',
      const Color(0xFF7E57C2),
      Rect.fromLTWH(0.06, 0.07, 0.42, 0.40),
    ),
    _RegionSeed(
      'east_stack',
      'East Stack',
      const Color(0xFF26A69A),
      Rect.fromLTWH(0.52, 0.07, 0.42, 0.40),
    ),
    _RegionSeed(
      'south_line',
      'South Line',
      const Color(0xFFE24B4A),
      Rect.fromLTWH(0.06, 0.53, 0.42, 0.40),
    ),
    _RegionSeed(
      'west_lock',
      'West Lock',
      const Color(0xFFFB8C00),
      Rect.fromLTWH(0.52, 0.53, 0.42, 0.40),
    ),
  ];

  for (final province in provinces) {
    territories.add(
      TurfTerritory(
        id: province.id,
        label: province.name,
        description:
            'Province of ${province.name}. Open it to reveal its cities.',
        color: province.color,
        defense: 0,
        level: TurfMapLevel.province,
        parentId: 'ironvale',
        bounds: province.bounds,
      ),
    );

    final cityRects = _splitGrid(province.bounds.deflate(0.018), 2, 2);
    for (var cityIndex = 0; cityIndex < cityRects.length; cityIndex++) {
      final cityId = '${province.id}_city_${cityIndex + 1}';
      final cityName =
          _cityNames[(territories.length + cityIndex) % _cityNames.length];
      territories.add(
        TurfTerritory(
          id: cityId,
          label: cityName,
          description: '$cityName controls the roads feeding ${province.name}.',
          color: Color.lerp(
            province.color,
            Colors.white,
            0.08 + cityIndex * 0.04,
          )!,
          defense: 0,
          level: TurfMapLevel.city,
          parentId: province.id,
          bounds: cityRects[cityIndex],
        ),
      );

      final townRects = _splitGrid(cityRects[cityIndex].deflate(0.014), 2, 2);
      for (var townIndex = 0; townIndex < townRects.length; townIndex++) {
        final townId = '${cityId}_town_${townIndex + 1}';
        final townName =
            _townNames[(cityIndex * 4 + townIndex) % _townNames.length];
        territories.add(
          TurfTerritory(
            id: townId,
            label: townName,
            description:
                '$townName is a local command pocket. Open it for streets.',
            color: Color.lerp(
              province.color,
              Colors.black,
              0.05 + townIndex * 0.05,
            )!,
            defense: 0,
            level: TurfMapLevel.town,
            parentId: cityId,
            bounds: townRects[townIndex],
          ),
        );

        final streetRects = _splitGrid(
          townRects[townIndex].deflate(0.01),
          2,
          3,
        );
        for (
          var streetIndex = 0;
          streetIndex < streetRects.length;
          streetIndex++
        ) {
          final streetId = '${townId}_street_${streetIndex + 1}';
          final streetName =
              _streetNames[(cityIndex * 24 + townIndex * 6 + streetIndex) %
                  _streetNames.length];
          streetIds.add(streetId);
          territories.add(
            TurfTerritory(
              id: streetId,
              label: streetName,
              description: 'A street-level turf claim inside $townName.',
              color: Color.lerp(
                province.color,
                Colors.white,
                0.18 + streetIndex * 0.035,
              )!,
              defense: 70 + cityIndex * 35 + townIndex * 22 + streetIndex * 11,
              level: TurfMapLevel.street,
              parentId: townId,
              bounds: streetRects[streetIndex],
            ),
          );
        }
      }
    }
  }

  final random = math.Random();
  return TurfMapData(
    title: title,
    subtitle: 'Read the chain from country down to the streets you can rule.',
    territories: territories,
    spawnStreetId: streetIds[random.nextInt(streetIds.length)],
  );
}

List<Rect> _splitGrid(Rect rect, int columns, int rows) {
  final cells = <Rect>[];
  final cellWidth = rect.width / columns;
  final cellHeight = rect.height / rows;
  for (var row = 0; row < rows; row++) {
    for (var column = 0; column < columns; column++) {
      cells.add(
        Rect.fromLTWH(
          rect.left + column * cellWidth,
          rect.top + row * cellHeight,
          cellWidth,
          cellHeight,
        ),
      );
    }
  }
  return cells;
}

class _RegionSeed {
  final String id;
  final String name;
  final Color color;
  final Rect bounds;

  const _RegionSeed(this.id, this.name, this.color, this.bounds);
}

const _cityNames = [
  'Vesper City',
  'Rookhaven',
  'Lowbridge',
  'Grayside',
  'Copper Gate',
  'Ashcross',
  'Neon Ward',
  'Port Mercy',
];

const _townNames = [
  'Cinder Town',
  'Lock Row',
  'Mason End',
  'Glass Hill',
  'Wire Bend',
  'Rail Flats',
  'Old Pike',
  'Knox Yard',
];

const _streetNames = [
  'Graffiti Ave',
  'Back Alley',
  'Block Corner',
  'Lantern Lane',
  'Razor Street',
  'Dock Road',
  'Switchback',
  'Market Cut',
  'Foundry Walk',
  'Signal Way',
  'Hollow Run',
  'East Steps',
];
