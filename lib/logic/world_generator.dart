import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gang.dart';
import '../components/environments/turf/turf_map.dart';
import '../models/interactable_npc.dart';

class WorldGeneratorResult {
  final TurfMapData mapData;
  final List<Gang> rivalGangs;
  final List<InteractableNpc> interactableNpcs;

  const WorldGeneratorResult({
    required this.mapData,
    required this.rivalGangs,
    required this.interactableNpcs,
  });
}

class WorldGenerator {
  static const _provinceNames = [
    'Aethelgard',
    'Boreal',
    'Crescent',
    'Dustwallow',
    'Ebonhold',
    'Frostford',
    'Glimmer',
    'Hearth',
  ];

  static const _cityNames = [
    'Vesper City',
    'Rookhaven',
    'Lowbridge',
    'Grayside',
    'Copper Gate',
    'Ashcross',
    'Neon Ward',
    'Port Mercy',
    'Apex',
    'New Babel',
    'Iron Cast',
    'Hollow Point',
    'Steelton',
    'Gloomville',
    'Nova Ridge',
    'Silver Peak',
  ];

  static const _townNames = [
    'Cinder Town',
    'Lock Row',
    'Mason End',
    'Glass Hill',
    'Wire Bend',
    'Rail Flats',
    'Old Pike',
    'Knox Yard',
    'Smokestack',
    'Rust Belt',
    'Gritville',
    'Siren Point',
  ];

  static const _streetNames = [
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
    'Neon Ave',
    'Shadow Blvd',
    'Echo Lane',
    'Crimson St',
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
      final colorPrimary = GangColorPresets
          .primary[random.nextInt(GangColorPresets.primary.length)];
      final colorAccent = GangColorPresets
          .accent[random.nextInt(GangColorPresets.accent.length)];
      rivalGangs.add(
        Gang(
          name: name.toUpperCase(),
          emblemId: emblem.id,
          primaryColor: colorPrimary,
          accentColor: colorAccent,
        ),
      );
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
      _RegionSeed(
        'region_north_$seed',
        'Northern Sector',
        const Color(0xFF7E57C2),
        const Rect.fromLTWH(0.06, 0.07, 0.42, 0.40),
      ),
      _RegionSeed(
        'region_east_$seed',
        'Eastern Bloc',
        const Color(0xFF26A69A),
        const Rect.fromLTWH(0.52, 0.07, 0.42, 0.40),
      ),
      _RegionSeed(
        'region_south_$seed',
        'Southern Expanse',
        const Color(0xFFE24B4A),
        const Rect.fromLTWH(0.06, 0.53, 0.42, 0.40),
      ),
      _RegionSeed(
        'region_west_$seed',
        'Western Frontier',
        const Color(0xFFFB8C00),
        const Rect.fromLTWH(0.52, 0.53, 0.42, 0.40),
      ),
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
        final provinceName =
            _provinceNames[provinceCount % _provinceNames.length];
        provinceCount++;

        territories.add(
          TurfTerritory(
            id: provinceId,
            label: provinceName,
            description: 'Province $provinceName in ${region.name}.',
            color: Color.lerp(
              region.color,
              Colors.white,
              0.05 + pIndex * 0.05,
            )!,
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

          final occupyingGang = random.nextDouble() > 0.5
              ? rivalGangs[random.nextInt(rivalGangs.length)]
              : null;

          territories.add(
            TurfTerritory(
              id: cityId,
              label: cityName,
              description: '$cityName controls the area.',
              color: Color.lerp(
                region.color,
                Colors.white,
                0.1 + cIndex * 0.05,
              )!,
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
                color: Color.lerp(
                  region.color,
                  Colors.black,
                  0.05 + tIndex * 0.05,
                )!,
                defense: 0,
                level: TurfMapLevel.town,
                parentId: cityId,
                bounds: townRects[tIndex],
                occupyingGangId: occupyingGang?.name,
              ),
            );

            final streetRects = _splitGrid(
              townRects[tIndex].deflate(0.01),
              2,
              2,
            );
            for (var sIndex = 0; sIndex < streetRects.length; sIndex++) {
              final streetId = '${townId}_street_$sIndex';
              final streetName =
                  _streetNames[streetCount % _streetNames.length];
              streetCount++;
              streetIds.add(streetId);

              final streetType =
                  StreetType.values[random.nextInt(StreetType.values.length)];

              territories.add(
                TurfTerritory(
                  id: streetId,
                  label: streetName,
                  description: 'A street turf.',
                  color: Color.lerp(
                    region.color,
                    Colors.white,
                    0.15 + sIndex * 0.05,
                  )!,
                  defense: 50 + random.nextInt(100),
                  level: TurfMapLevel.street,
                  parentId: townId,
                  bounds: streetRects[sIndex],
                  occupyingGangId: occupyingGang?.name,
                  backgroundAsset: streetType.assetPath,
                  streetType: streetType,
                ),
              );
            }
          }
        }
      }
    }

    final mapData = TurfMapData(
      title: 'TURFS',
      subtitle: '',
      territories: territories,
      spawnStreetId: streetIds.isNotEmpty
          ? streetIds[random.nextInt(streetIds.length)]
          : '',
    );

    // Generate unique named interactable NPCs on random streets
    final interactableNpcs = <InteractableNpc>[];
    const npcNames = [
      'Ghost',
      'Viper',
      'Spike',
      'Shadow',
      'Bullet',
      'Razor',
      'Siren',
      'Trigger',
    ];
    const npcDescriptions = [
      'A silent veteran who knows every corner of this town.',
      'Always looking for a lucrative deal. Highly opportunistic.',
      'A hot-tempered brawler. Fights first, asks later.',
      'A mysterious informant with ties to all syndicates.',
      'A legendary marksman laying low in the slums.',
      'A street blade master with a cold attitude.',
      'A persuasive negotiator who can sweet-talk anyone.',
      'A reckless driver and runner. Lives on the edge.',
    ];

    for (int i = 0; i < npcNames.length; i++) {
      final npcId = 'npc_${seed}_$i';
      final streetId = streetIds.isNotEmpty
          ? streetIds[random.nextInt(streetIds.length)]
          : 'spawn';

      final npcHp = 100 + random.nextInt(80);
      interactableNpcs.add(
        InteractableNpc(
          id: npcId,
          name: npcNames[i],
          description: npcDescriptions[i],
          level: 3 + random.nextInt(5),
          hp: npcHp,
          maxHp: npcHp,
          atk: 8 + random.nextInt(6),
          dodgeChance: 0.08 + random.nextDouble() * 0.08,
          reputation: 25.0 + random.nextInt(25),
          relationship:
              -20 + random.nextInt(40), // Initial relationship -20 to 20
          locationStreetId: streetId,
        ),
      );
    }

    return WorldGeneratorResult(
      mapData: mapData,
      rivalGangs: rivalGangs,
      interactableNpcs: interactableNpcs,
    );
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
