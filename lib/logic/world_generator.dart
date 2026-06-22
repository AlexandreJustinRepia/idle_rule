import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gang.dart';
import '../components/environments/turf/turf_map.dart';

class WorldGeneratorResult {
  final TurfMapData mapData;
  final List<Gang> rivalGangs;

  const WorldGeneratorResult({
    required this.mapData,
    required this.rivalGangs,
  });
}

class WorldGenerator {
  static const _provinceNames = [
    'Aethelgard', 'Boreal', 'Crescent', 'Dustwallow',
    'Ebonhold', 'Frostford', 'Glimmer', 'Hearth',
  ];

  static const _cityNames = [
    'Vesper City', 'Rookhaven', 'Lowbridge', 'Grayside',
    'Copper Gate', 'Ashcross', 'Neon Ward', 'Port Mercy',
    'Apex', 'New Babel', 'Iron Cast', 'Hollow Point',
    'Steelton', 'Gloomville', 'Nova Ridge', 'Silver Peak'
  ];

  static const _townNames = [
    'Cinder Town', 'Lock Row', 'Mason End', 'Glass Hill',
    'Wire Bend', 'Rail Flats', 'Old Pike', 'Knox Yard',
    'Smokestack', 'Rust Belt', 'Gritville', 'Siren Point'
  ];

  static const _streetNames = [
    'Graffiti Ave', 'Back Alley', 'Block Corner', 'Lantern Lane',
    'Razor Street', 'Dock Road', 'Switchback', 'Market Cut',
    'Foundry Walk', 'Signal Way', 'Hollow Run', 'East Steps',
    'Neon Ave', 'Shadow Blvd', 'Echo Lane', 'Crimson St'
  ];

  static WorldGeneratorResult generateWorld(int seed) {
    final random = math.Random(seed);
    final territories = <TurfTerritory>[];
    final streetIds = <String>[];
    final rivalGangs = <Gang>[];

    // Generate 2 rival gangs
    for (var i = 0; i < 2; i++) {
      final name = 'Syndicate ${String.fromCharCode(65 + i)}';
      final emblem = GangEmblems.all[random.nextInt(GangEmblems.all.length)];
      final colorPrimary = GangColorPresets.primary[random.nextInt(GangColorPresets.primary.length)];
      final colorAccent = GangColorPresets.accent[random.nextInt(GangColorPresets.accent.length)];
      rivalGangs.add(Gang(
        name: name.toUpperCase(),
        emblemId: emblem.id,
        primaryColor: colorPrimary,
        accentColor: colorAccent,
      ));
    }

    final worldId = 'world_$seed';
    territories.add(
      TurfTerritory(
        id: worldId,
        label: 'Universe $seed',
        description: 'A newly generated world full of danger.',
        color: const Color(0xFF263238),
        defense: 0,
        level: TurfMapLevel.world,
        bounds: const Rect.fromLTWH(0.02, 0.02, 0.96, 0.96),
      ),
    );

    final countryId = 'country_$seed';
    territories.add(
      TurfTerritory(
        id: countryId,
        label: 'New Avalon',
        description: 'The primary country spanning this domain.',
        color: const Color(0xFF455A64),
        defense: 0,
        level: TurfMapLevel.country,
        parentId: worldId,
        bounds: const Rect.fromLTWH(0.04, 0.04, 0.92, 0.92),
      ),
    );

    final regions = [
      _RegionSeed('region_north_$seed', 'Northern Sector', const Color(0xFF7E57C2), const Rect.fromLTWH(0.06, 0.07, 0.42, 0.40)),
      _RegionSeed('region_east_$seed', 'Eastern Bloc', const Color(0xFF26A69A), const Rect.fromLTWH(0.52, 0.07, 0.42, 0.40)),
      _RegionSeed('region_south_$seed', 'Southern Expanse', const Color(0xFFE24B4A), const Rect.fromLTWH(0.06, 0.53, 0.42, 0.40)),
      _RegionSeed('region_west_$seed', 'Western Frontier', const Color(0xFFFB8C00), const Rect.fromLTWH(0.52, 0.53, 0.42, 0.40)),
    ];

    int provinceCount = 0;
    int cityCount = 0;
    int townCount = 0;
    int streetCount = 0;

    for (var r = 0; r < regions.length; r++) {
      final region = regions[r];
      territories.add(
        TurfTerritory(
          id: region.id,
          label: region.name,
          description: 'Region of ${region.name}.',
          color: region.color,
          defense: 0,
          level: TurfMapLevel.region,
          parentId: countryId,
          bounds: region.bounds,
        ),
      );

      final provinceRects = _splitGrid(region.bounds.deflate(0.01), 1, 2);
      for (var pIndex = 0; pIndex < provinceRects.length; pIndex++) {
        final provinceId = '${region.id}_prov_$pIndex';
        final provinceName = _provinceNames[provinceCount % _provinceNames.length];
        provinceCount++;

        territories.add(
          TurfTerritory(
            id: provinceId,
            label: provinceName,
            description: 'Province $provinceName in ${region.name}.',
            color: Color.lerp(region.color, Colors.white, 0.05 + pIndex * 0.05)!,
            defense: 0,
            level: TurfMapLevel.province,
            parentId: region.id,
            bounds: provinceRects[pIndex],
          ),
        );

        final cityRects = _splitGrid(provinceRects[pIndex].deflate(0.01), 2, 1);
        for (var cIndex = 0; cIndex < cityRects.length; cIndex++) {
          final cityId = '${provinceId}_city_$cIndex';
          final cityName = _cityNames[cityCount % _cityNames.length];
          cityCount++;

          final occupyingGang = random.nextDouble() > 0.5 ? rivalGangs[random.nextInt(rivalGangs.length)] : null;

          territories.add(
            TurfTerritory(
              id: cityId,
              label: cityName,
              description: '$cityName controls the area.',
              color: Color.lerp(region.color, Colors.white, 0.1 + cIndex * 0.05)!,
              defense: 0,
              level: TurfMapLevel.city,
              parentId: provinceId,
              bounds: cityRects[cIndex],
              occupyingGangId: occupyingGang?.name,
            ),
          );

          final townRects = _splitGrid(cityRects[cIndex].deflate(0.01), 2, 2);
          for (var tIndex = 0; tIndex < townRects.length; tIndex++) {
            final townId = '${cityId}_town_$tIndex';
            final townName = _townNames[townCount % _townNames.length];
            townCount++;
            
            territories.add(
              TurfTerritory(
                id: townId,
                label: townName,
                description: 'A town inside $cityName.',
                color: Color.lerp(region.color, Colors.black, 0.05 + tIndex * 0.05)!,
                defense: 0,
                level: TurfMapLevel.town,
                parentId: cityId,
                bounds: townRects[tIndex],
                occupyingGangId: occupyingGang?.name,
              ),
            );

            final streetRects = _splitGrid(townRects[tIndex].deflate(0.01), 2, 2);
            for (var sIndex = 0; sIndex < streetRects.length; sIndex++) {
              final streetId = '${townId}_street_$sIndex';
              final streetName = _streetNames[streetCount % _streetNames.length];
              streetCount++;
              streetIds.add(streetId);
              
              territories.add(
                TurfTerritory(
                  id: streetId,
                  label: streetName,
                  description: 'A street turf.',
                  color: Color.lerp(region.color, Colors.white, 0.15 + sIndex * 0.05)!,
                  defense: 50 + random.nextInt(100),
                  level: TurfMapLevel.street,
                  parentId: townId,
                  bounds: streetRects[sIndex],
                  occupyingGangId: occupyingGang?.name,
                ),
              );
            }
          }
        }
      }
    }

    final mapData = TurfMapData(
      title: 'GENERATED TURF',
      subtitle: 'A dynamically generated world.',
      territories: territories,
      spawnStreetId: streetIds.isNotEmpty ? streetIds[random.nextInt(streetIds.length)] : '',
    );

    return WorldGeneratorResult(mapData: mapData, rivalGangs: rivalGangs);
  }

  static List<Rect> _splitGrid(Rect rect, int columns, int rows) {
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
}

class _RegionSeed {
  final String id;
  final String name;
  final Color color;
  final Rect bounds;

  const _RegionSeed(this.id, this.name, this.color, this.bounds);
}
