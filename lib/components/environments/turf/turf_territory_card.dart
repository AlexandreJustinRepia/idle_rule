import 'package:flutter/material.dart';

import '../../../controllers/game_controller.dart';
import '../../../models/gang.dart';
import '../../shared/gang_pictorial.dart';
import 'turf_common_widgets.dart';
import 'turf_map.dart';

class TurfTerritoryCard extends StatelessWidget {
  final TurfTerritory territory;
  final bool isCurrentLocation;
  final bool isConquered;
  final Gang? occupantGang;
  final bool isStreetLevel;
  final GameController gameController;
  final VoidCallback onTap;
  final VoidCallback onTravel;
  final VoidCallback onSendGang;
  final VoidCallback onLeadAttack;
  final VoidCallback? onChallengeBoss;

  const TurfTerritoryCard({
    super.key,
    required this.territory,
    required this.isCurrentLocation,
    required this.isConquered,
    required this.occupantGang,
    required this.isStreetLevel,
    required this.gameController,
    required this.onTap,
    required this.onTravel,
    required this.onSendGang,
    required this.onLeadAttack,
    this.onChallengeBoss,
  });

  IconData _iconForLevel(TurfMapLevel level) {
    return switch (level) {
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

    final canAttack = isStreetLevel && !isConquered;
    final attackUsesGang = gameController.isTurfAttackUsingGang;

    return Card(
      color: const Color(0xFF111316),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderGlowColor,
          width: isCurrentLocation || isConquered ? 1.5 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isStreetLevel)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 125,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          territory.backgroundAsset ??
                              'assets/background/ghetto.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Visual front-view Gang Pictorial
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: GangPictorial(
                          gang: occupantGang,
                          width: 110,
                          height: 75,
                        ),
                      ),
                      // Small street type label on top-left
                      if (territory.streetType != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: territory.color.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              territory.streetType!.label.toUpperCase(),
                              style: TextStyle(
                                color: territory.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Padding(
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
                            if (!isStreetLevel &&
                                territory.level == TurfMapLevel.street &&
                                territory.streetType != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                territory.streetType!.label.toUpperCase(),
                                style: TextStyle(
                                  color: territory.color.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isCurrentLocation)
                        TurfStatusBadge(
                          label: 'YOU ARE HERE',
                          color: const Color(0xFFFFD166),
                          textColor: Colors.black,
                        )
                      else if (isConquered)
                        const TurfStatusBadge(
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
                          'Ruled by: ',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                        Flexible(
                          child: Text(
                            occupantGang!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: occupantGang!.primaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (occupantGang!.leaderName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white38,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Leader: ',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              occupantGang!.leaderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.alt_route, size: 16),
                            label: const Text(
                              'TRAVEL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (isCurrentLocation &&
                            occupantGang != null &&
                            !isConquered) ...[
                          ElevatedButton.icon(
                            onPressed: onChallengeBoss,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.flash_on, size: 16),
                            label: const Text(
                              'CHALLENGE BOSS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        if (!isCurrentLocation && canAttack) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: attackUsesGang
                                ? onSendGang
                                : onLeadAttack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE24B4A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.gavel, size: 16),
                            label: Text(
                              attackUsesGang ? 'SEND' : 'SOLO',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
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
          ],
        ),
      ),
    );
  }
}
