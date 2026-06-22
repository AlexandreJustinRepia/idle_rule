import 'package:flutter/material.dart';
import '../../../controllers/game_controller.dart';
import '../../../models/gang.dart';
import 'ghetto_turf_map.dart';
import 'travel_animation_overlay.dart';
import 'turf_map.dart';
import '../../../models/interactable_npc.dart';
import '../../ui/npc_interaction_modal.dart';

class TurfScreen extends StatefulWidget {
  final GameController gameController;
  final TurfMapData? mapData;
  final String? characterName;
  final String? worldName;
  final String? locationStreetId;
  final List<String> residents;
  final ValueChanged<String>? onLocationChanged;
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
    this.onLocationChanged,
    this.rivalGangs = const [],
    this.interactableNpcs = const [],
  });

  @override
  State<TurfScreen> createState() => _TurfScreenState();
}

class _TurfScreenState extends State<TurfScreen> {
  String? _currentParentId;
  final Set<String> _conqueredTerritoryIds = {};

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

  void _conquerTerritory(TurfTerritory territory) {
    if (territory.level != TurfMapLevel.street) return;
    if (_conqueredTerritoryIds.contains(territory.id)) return;

    final succeeded = widget.gameController.attemptTurfTakeover(territory.defense);
    if (!mounted) return;

    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${territory.label.toUpperCase()} TAKEOVER FAILED'),
          backgroundColor: Colors.red[900],
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    setState(() => _conqueredTerritoryIds.add(territory.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${territory.label.toUpperCase()} SECURED'),
        backgroundColor: Colors.green[800],
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showTravelAnimation(TurfTerritory street, bool isTaxi, VoidCallback onAnimationComplete) {
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
            final dynamicCanWalk = controller.playerStamina >= 15 && controller.playerHunger >= 10;
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
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Walk Option Card
                  _TravelOptionCard(
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
                  _TravelOptionCard(
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
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
                      ),
                    ],
                  ),
                ),
                // Home/Root button to jump back to top level
                if (_currentParentId != null)
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white60),
                    onPressed: () => setState(() => _currentParentId = null),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Current Location Indicator Banner
            _LocationIndicatorBanner(
              currentStreet: currentStreet,
              residents: widget.residents,
              characterName: widget.characterName,
            ),
            const SizedBox(height: 12),

            // Street Residents Section
            if (widget.interactableNpcs.any((n) => n.locationStreetId == currentStreetId && !n.isRecruited)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt, color: Color(0xFFFFD166), size: 14),
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
                      .where((n) => n.locationStreetId == currentStreetId && !n.isRecruited)
                      .map((npc) => _NpcCard(
                            npc: npc,
                            onTap: () {
                              NpcInteractionModal.show(context, npc, widget.gameController);
                            },
                          ))
                      .toList(),
                ),
              ),
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
                    _BreadcrumbNode(
                      label: 'Root',
                      isLast: _currentParentId == null,
                      onTap: () => setState(() => _currentParentId = null),
                    ),
                    for (int i = 0; i < crumbs.length; i++)
                      _BreadcrumbNode(
                        label: crumbs[i].label,
                        isLast: i == crumbs.length - 1,
                        onTap: () => setState(() => _currentParentId = crumbs[i].id),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        final isStreetLevel = child.level == TurfMapLevel.street;
                        final isCurrentLocation = child.id == currentStreetId;
                        final isConquered = _conqueredTerritoryIds.contains(child.id);

                        return _TerritoryCard(
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
                          onConquer: () => _conquerTerritory(child),
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

class _LocationIndicatorBanner extends StatelessWidget {
  final TurfTerritory currentStreet;
  final List<String> residents;
  final String? characterName;

  const _LocationIndicatorBanner({
    required this.currentStreet,
    required this.residents,
    this.characterName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17191C),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.my_location,
            color: Color(0xFFFFD166),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENTLY AT: ${currentStreet.label.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  residents.isEmpty
                      ? 'You are alone on this street.'
                      : 'Also here: ${residents.join(', ')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbNode extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const _BreadcrumbNode({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLast ? const Color(0xFF262A30) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isLast ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isLast ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.chevron_right, size: 14, color: Colors.white30),
          ),
      ],
    );
  }
}

class _TerritoryCard extends StatelessWidget {
  final TurfTerritory territory;
  final bool isCurrentLocation;
  final bool isConquered;
  final Gang? occupantGang;
  final bool isStreetLevel;
  final GameController gameController;
  final VoidCallback onTap;
  final VoidCallback onTravel;
  final VoidCallback onConquer;

  const _TerritoryCard({
    required this.territory,
    required this.isCurrentLocation,
    required this.isConquered,
    required this.occupantGang,
    required this.isStreetLevel,
    required this.gameController,
    required this.onTap,
    required this.onTravel,
    required this.onConquer,
  });

  IconData _iconForLevel(TurfMapLevel level) {
    return switch (level) {
      TurfMapLevel.world => Icons.public,
      TurfMapLevel.country => Icons.flag,
      TurfMapLevel.region => Icons.map,
      TurfMapLevel.province => Icons.account_balance,
      TurfMapLevel.city => Icons.location_city,
      TurfMapLevel.town => Icons.home_work,
      TurfMapLevel.street => Icons.signpost,
    };
  }

  @override
  Widget build(BuildContext context) {
    final borderGlowColor = isCurrentLocation
        ? const Color(0xFFFFD166).withValues(alpha: 0.5)
        : isConquered
            ? const Color(0xFF2DDA77).withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.08);

    final canAttack = isStreetLevel &&
        !isConquered &&
        gameController.hasGang &&
        gameController.gangFormationSize > 0;

    return Card(
      color: const Color(0xFF111316),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderGlowColor, width: isCurrentLocation || isConquered ? 1.5 : 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Header (Icon, Level, Title, Status Badges)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: territory.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _iconForLevel(territory.level),
                      color: territory.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          territory.level.label.toUpperCase(),
                          style: TextStyle(
                            color: territory.color.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          territory.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentLocation)
                    _Badge(
                      label: 'YOU ARE HERE',
                      color: const Color(0xFFFFD166),
                      textColor: Colors.black,
                    )
                  else if (isConquered)
                    const _Badge(
                      label: 'SECURED',
                      color: Color(0xFF2DDA77),
                      textColor: Colors.white,
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Description / Stats Info
              Text(
                territory.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 10),

              // Occupant Gang badge (if any)
              if (occupantGang != null) ...[
                Row(
                  children: [
                    Icon(
                      occupantGang!.emblem,
                      color: occupantGang!.primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Occupied by: ',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Text(
                      occupantGang!.name,
                      style: TextStyle(
                        color: occupantGang!.primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else if (isStreetLevel && !isConquered) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.security,
                      color: Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Defense: ',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Text(
                      '${territory.defense}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Actions (Drill down arrow or travel/conquer buttons)
              if (isStreetLevel) ...[
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isCurrentLocation)
                      ElevatedButton.icon(
                        onPressed: onTravel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white70,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.alt_route, size: 16),
                        label: const Text(
                          'TRAVEL',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    if (!isCurrentLocation && canAttack) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onConquer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE24B4A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.gavel, size: 16),
                        label: const Text(
                          'RULE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ENTER',
                      style: TextStyle(
                        color: territory.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: territory.color,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TravelOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String costText;
  final bool isEnabled;
  final VoidCallback onTap;

  const _TravelOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.costText,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isEnabled ? const Color(0xFF202327) : const Color(0xFF1A1A1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isEnabled ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
        ),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isEnabled ? const Color(0xFFFFD166) : Colors.white24,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isEnabled ? Colors.white : Colors.white30,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isEnabled ? Colors.white60 : Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cost: $costText',
                      style: TextStyle(
                        color: isEnabled ? Colors.orangeAccent : Colors.white24,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: isEnabled ? Colors.white38 : Colors.white12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NpcCard extends StatelessWidget {
  final InteractableNpc npc;
  final VoidCallback onTap;

  const _NpcCard({
    required this.npc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tier = npc.relationshipTier;
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: const Color(0xFF1E2125),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: tier.color.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: tier.color.withValues(alpha: 0.2),
                  child: Icon(Icons.person, size: 20, color: tier.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        npc.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tier.label.toUpperCase(),
                        style: TextStyle(
                          color: tier.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
