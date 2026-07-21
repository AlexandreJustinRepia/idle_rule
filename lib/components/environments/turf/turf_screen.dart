import 'package:flutter/material.dart';
import '../../../controllers/game_controller.dart';
import '../../../models/gang.dart';
import '../../../models/world_session.dart';
import 'ghetto_turf_map.dart';
import 'travel_animation_overlay.dart';
import 'turf_map.dart';
import 'turf_common_widgets.dart';
import 'turf_territory_card.dart';
import '../../../models/interactable_npc.dart';
import '../../ui/npc_interaction_modal.dart';
import '../../ui/player_interaction_modal.dart';

class TurfScreen extends StatefulWidget {
  final GameController gameController;
  final TurfMapData? mapData;
  final String? characterName;
  final String? worldName;
  final String? locationStreetId;
  final List<String> residents;
  final List<GameCharacterSession> worldResidents;
  final ValueChanged<String>? onLocationChanged;
  final ValueChanged<PendingTurfConquest>? onSoloTurfConquestStarted;
  final List<Gang> rivalGangs;
  final List<InteractableNpc> interactableNpcs;

  const TurfScreen({
    super.key,
    required this.gameController,
    this.mapData,
    this.characterName,
    this.worldName,
    this.locationStreetId,
    this.residents = const [],
    this.worldResidents = const [],
    this.onLocationChanged,
    this.onSoloTurfConquestStarted,
    this.rivalGangs = const [],
    this.interactableNpcs = const [],
  });

  @override
  State<TurfScreen> createState() => _TurfScreenState();
}

class _TurfScreenState extends State<TurfScreen> {
  String? _currentParentId;
  TurfMapData get _mapData => widget.mapData ?? ghettoTurfMap;

  @override
  void initState() {
    super.initState();
    // Default to viewing the parent level of the spawn/current street
    final currentStreetId = widget.locationStreetId ?? _mapData.spawnStreetId;
    try {
      final currentStreet = _mapData.territoryById(currentStreetId);
      _currentParentId = currentStreet.parentId;
    } catch (_) {
      _currentParentId = null;
    }

    if (widget.gameController.isSoloRaidFailedTerritory(currentStreetId)) {
      _markStreetNpcsAggressive(currentStreetId);
    }
  }

  @override
  void didUpdateWidget(covariant TurfScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStreetId = oldWidget.locationStreetId ?? _mapData.spawnStreetId;
    final newStreetId = widget.locationStreetId ?? _mapData.spawnStreetId;
    if (newStreetId != oldStreetId &&
        widget.gameController.isSoloRaidFailedTerritory(newStreetId)) {
      _markStreetNpcsAggressive(newStreetId);
    }
  }

  void _markStreetNpcsAggressive(String streetId) {
    var updated = false;
    for (final npc in widget.interactableNpcs) {
      if (npc.locationStreetId != streetId || npc.isRecruited) continue;
      if (npc.relationship > -20) {
        npc.relationship = -20;
        updated = true;
      }
    }
    if (updated && mounted) {
      setState(() {});
    }
  }

  String _locationLabelFor(GameCharacterSession character) {
    final streetId = character.locationStreetId ?? _mapData.spawnStreetId;
    try {
      final location = _mapData.territoryById(streetId);
      final streetType = location.streetType?.label;
      return streetType == null ? location.label : '${location.label} / $streetType';
    } catch (_) {
      return 'Unknown street';
    }
  }

  List<TurfTerritory> get _breadcrumbs {
    final list = <TurfTerritory>[];
    String? currentId = _currentParentId;
    while (currentId != null) {
      try {
        final territory = _mapData.territoryById(currentId);
        list.insert(0, territory);
        currentId = territory.parentId;
      } catch (_) {
        break;
      }
    }
    return list;
  }

  List<TurfTerritory> _childrenOf(String? parentId) {
    return _mapData.territories
        .where((territory) => territory.parentId == parentId)
        .toList();
  }

  void _onRootTap() {
    final currentStreetId = widget.locationStreetId ?? _mapData.spawnStreetId;
    try {
      final currentStreet = _mapData.territoryById(currentStreetId);
      if (_currentParentId == currentStreet.parentId) {
        setState(() => _currentParentId = null);
      } else {
        setState(() => _currentParentId = currentStreet.parentId);
      }
    } catch (_) {
      setState(() => _currentParentId = null);
    }
  }

  Gang? _findGang(String? gangId) {
    if (gangId == null) return null;
    if (widget.gameController.gang?.name == gangId) {
      return widget.gameController.gang;
    }
    for (final gang in widget.rivalGangs) {
      if (gang.name == gangId) return gang;
    }
    return null;
  }

  void _leadTerritoryAttack(
    TurfTerritory territory, {
    bool isBossChallenge = false,
  }) {
    if (territory.level != TurfMapLevel.street) return;
    if (widget.gameController.isTerritoryConquered(territory.id)) return;

    final isUsingGang = widget.gameController.isTurfAttackUsingGang;

    final request = widget.gameController.beginSoloTurfConquest(
      territoryId: territory.id,
      territoryName: territory.label,
      territoryDefense: territory.defense,
      occupyingGangName: territory.occupyingGangId,
      usedGang: isUsingGang,
      isBossChallenge: isBossChallenge,
    );

    widget.onSoloTurfConquestStarted?.call(request);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBossChallenge
              ? 'BOSS CHALLENGE STARTED - DEFEAT ${request.territoryName.toUpperCase()}\'S LEADER!'
              : (isUsingGang
                    ? 'GANG RAID STARTED - TAKING OVER ${territory.label.toUpperCase()}'
                    : 'SOLO RAID STARTED - CLEAR ${territory.label.toUpperCase()} ON THE STREET'),
        ),
        backgroundColor: const Color(0xFFE24B4A),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _sendGangToTerritory(TurfTerritory territory) {
    _leadTerritoryAttack(territory);
  }

  void _showTravelAnimation(
    TurfTerritory street,
    bool isTaxi,
    VoidCallback onAnimationComplete,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return TravelAnimationOverlay(
            streetName: street.label,
            isTaxi: isTaxi,
            onComplete: () {
              Navigator.of(context).pop();
              onAnimationComplete();
            },
          );
        },
      ),
    );
  }

  void _showTravelDialog(TurfTerritory street) {
    final controller = widget.gameController;

    showDialog(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            final dynamicCanWalk =
                controller.playerStamina >= 15 && controller.playerHunger >= 10;
            final dynamicCanTaxi = controller.money >= 15;

            return AlertDialog(
              backgroundColor: const Color(0xFF16181B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              title: Text(
                'TRAVEL TO ${street.label.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose your method of transportation to reach this street turf.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Walk Option Card
                  TravelOptionCard(
                    title: 'Walk',
                    subtitle: 'Consumes stamina & energy',
                    icon: Icons.directions_walk,
                    costText: '15 Stamina, 10 Hunger',
                    isEnabled: dynamicCanWalk,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showTravelAnimation(street, false, () {
                        if (controller.spendStamina(15)) {
                          controller.recoverNeeds(hunger: -10);
                          widget.onLocationChanged?.call(street.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Walked to ${street.label}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Taxi Option Card
                  TravelOptionCard(
                    title: 'Take Taxi',
                    subtitle: 'Fast travel using cash',
                    icon: Icons.local_taxi,
                    costText: '\$15 Cash',
                    isEnabled: dynamicCanTaxi,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showTravelAnimation(street, true, () {
                        if (controller.buyItem(cost: 15)) {
                          widget.onLocationChanged?.call(street.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Took a taxi to ${street.label}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStreetId = widget.locationStreetId ?? _mapData.spawnStreetId;
    final currentStreet = _mapData.territoryById(currentStreetId);

    final streetResidentNames = widget.worldResidents
        .where((r) => r.locationStreetId == currentStreetId)
        .map((r) => r.controller.playerName)
        .toList();

    final sameStreetResidents = widget.worldResidents
        .where((r) =>
            r.controller.playerName != widget.characterName &&
            r.locationStreetId == currentStreetId)
        .toList();

    final crumbs = _breadcrumbs;
    final children = _childrenOf(_currentParentId);

    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mapData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _mapData.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                // Home/Root button to jump back to top level
                if (_currentParentId != null)
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white60),
                    onPressed: _onRootTap,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Current Location Indicator Banner
            LocationIndicatorBanner(
              currentStreet: currentStreet,
              residents: streetResidentNames,
              characterName: widget.characterName,
            ),
            const SizedBox(height: 12),

            // Street Residents Section
            if (widget.interactableNpcs.any(
              (n) => n.locationStreetId == currentStreetId && !n.isRecruited,
            )) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_alt,
                      color: Color(0xFFFFD166),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LOCAL STREET RESIDENTS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.interactableNpcs
                      .where(
                        (n) =>
                            n.locationStreetId == currentStreetId &&
                            !n.isRecruited,
                      )
                      .map(
                        (npc) => TurfNpcCard(
                          npc: npc,
                          onTap: () {
                            final currentStreetId =
                                widget.locationStreetId ??
                                _mapData.spawnStreetId;
                            final isHostileStreet = widget.gameController
                                .isSoloRaidFailedTerritory(currentStreetId);
                            if (isHostileStreet) {
                              // Street is hostile after a failed solo raid —
                              // NPCs attack on sight, no dialog.
                              widget.gameController.fightNpc(npc);
                            } else {
                              NpcInteractionModal.show(
                                context,
                                npc,
                                widget.gameController,
                              );
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Street Encounters Section (other players on same street)
            if (sameStreetResidents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Color(0xFFE24B4A),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STREET ENCOUNTERS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: sameStreetResidents.map((resident) {
                    return PlayerEncounterCard(
                      name: resident.controller.playerName,
                      onTap: () {
                        PlayerInteractionModal.show(
                          context,
                          resident,
                          widget.gameController,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // World Residents Section
            if (widget.worldResidents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: Color(0xFFE24B4A), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'WORLD RESIDENTS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...widget.worldResidents.map((resident) {
                final isCurrentPlayer =
                    resident.controller.playerName == widget.characterName;
                return WorldResidentRow(
                  name: isCurrentPlayer
                      ? '${resident.controller.playerName} (You)'
                      : resident.controller.playerName,
                  locationLabel: _locationLabelFor(resident),
                  isActivePlayer: isCurrentPlayer,
                );
              }),
              const SizedBox(height: 12),
            ],

            // Breadcrumb trail bar
            if (crumbs.isNotEmpty || _currentParentId != null)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    BreadcrumbNode(
                      label: widget.worldName ?? 'Root',
                      isLast: _currentParentId == null,
                      onTap: _onRootTap,
                    ),
                    for (int i = 0; i < crumbs.length; i++)
                      BreadcrumbNode(
                        label: crumbs[i].label,
                        isLast: i == crumbs.length - 1,
                        onTap: () =>
                            setState(() => _currentParentId = crumbs[i].id),
                      ),
                  ],
                ),
              ),

            // Active Card List of Sub-Territories
            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        'No sub-territories found here.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        final isStreetLevel =
                            child.level == TurfMapLevel.street;
                        final isCurrentLocation = child.id == currentStreetId;
                        final isConquered = widget.gameController
                            .isTerritoryConquered(child.id);

                        return TurfTerritoryCard(
                          territory: child,
                          isCurrentLocation: isCurrentLocation,
                          isConquered: isConquered,
                          occupantGang: _findGang(child.occupyingGangId),
                          isStreetLevel: isStreetLevel,
                          gameController: widget.gameController,
                          onTap: () {
                            if (!isStreetLevel) {
                              setState(() => _currentParentId = child.id);
                            }
                          },
                          onTravel: () => _showTravelDialog(child),
                          onSendGang: () => _sendGangToTerritory(child),
                          onLeadAttack: () => _leadTerritoryAttack(child),
                          onChallengeBoss: () => _leadTerritoryAttack(
                            child,
                            isBossChallenge: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
