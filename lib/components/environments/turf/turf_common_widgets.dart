import 'package:flutter/material.dart';

import '../../../models/interactable_npc.dart';
import 'turf_map.dart';

class LocationIndicatorBanner extends StatelessWidget {
  final TurfTerritory currentStreet;
  final List<String> residents;
  final String? characterName;

  const LocationIndicatorBanner({
    super.key,
    required this.currentStreet,
    required this.residents,
    this.characterName,
  });

  @override
  Widget build(BuildContext context) {
    final streetTypeLabel = currentStreet.streetType?.label;

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
          const Icon(Icons.my_location, color: Color(0xFFFFD166), size: 20),
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
                if (streetTypeLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'STREET TYPE: ${streetTypeLabel.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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

class BreadcrumbNode extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const BreadcrumbNode({
    super.key,
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

class TurfStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const TurfStatusBadge({
    super.key,
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

class TravelOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String costText;
  final bool isEnabled;
  final VoidCallback onTap;

  const TravelOptionCard({
    super.key,
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
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
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

class WorldResidentRow extends StatelessWidget {
  final String name;
  final String locationLabel;
  final bool isActivePlayer;

  const WorldResidentRow({
    super.key,
    required this.name,
    required this.locationLabel,
    this.isActivePlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2125),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActivePlayer
              ? const Color(0xFFE24B4A).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActivePlayer ? Icons.person_pin : Icons.person_outline,
            size: 16,
            color: isActivePlayer ? const Color(0xFFE24B4A) : Colors.white54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isActivePlayer ? const Color(0xFFE24B4A) : Colors.white,
                fontSize: 13,
                fontWeight: isActivePlayer ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            locationLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class TurfNpcCard extends StatelessWidget {
  final InteractableNpc npc;
  final VoidCallback onTap;

  const TurfNpcCard({super.key, required this.npc, required this.onTap});

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
