import 'package:flutter/material.dart';

class TurfTerritory {
  final String id;
  final String label;
  final String description;
  final Alignment position;
  final double widthFactor;
  final double heightFactor;
  final Color color;

  const TurfTerritory({
    required this.id,
    required this.label,
    required this.description,
    required this.position,
    required this.widthFactor,
    required this.heightFactor,
    required this.color,
  });
}

class TurfMapData {
  final String title;
  final String subtitle;
  final List<TurfTerritory> territories;

  const TurfMapData({
    required this.title,
    required this.subtitle,
    required this.territories,
  });
}

class TurfMapView extends StatelessWidget {
  final TurfMapData mapData;
  final String selectedTerritoryId;
  final Set<String> conqueredTerritoryIds;
  final ValueChanged<TurfTerritory> onTerritoryTap;

  const TurfMapView({
    super.key,
    required this.mapData,
    required this.selectedTerritoryId,
    required this.conqueredTerritoryIds,
    required this.onTerritoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double mapWidth = constraints.maxWidth;
          final double mapHeight = constraints.maxHeight;
          try {
            return Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
              ),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Stack(
              children: [
                ...mapData.territories.map((territory) {
                  final bool isSelected = territory.id == selectedTerritoryId;
                  final bool isConquered = conqueredTerritoryIds.contains(territory.id);
                  final double minWidth = 110.0;
                  final double minHeight = 80.0;
                  final double width = (mapWidth * territory.widthFactor).clamp(minWidth, mapWidth * 0.45);
                  final double height = (mapHeight * territory.heightFactor).clamp(minHeight, mapHeight * 0.35);

                  return Align(
                    alignment: territory.position,
                    child: GestureDetector(
                      onTap: () => onTerritoryTap(territory),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: width,
                        height: height,
                        constraints: BoxConstraints(
                          minWidth: minWidth,
                          minHeight: minHeight,
                        ),
                        decoration: BoxDecoration(
                          color: territory.color.withValues(alpha: isConquered ? 0.45 : 0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE24B4A) : Colors.white12,
                            width: isSelected ? 3 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE24B4A).withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              territory.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: isConquered ? 0.75 : 0.95),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                fontSize: 12,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isConquered
                                      ? const Color(0xFF34C759).withValues(alpha: 0.18)
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isConquered ? 'CONQUERED' : 'OPEN',
                                  style: TextStyle(
                                    color: isConquered ? const Color(0xFF34C759) : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                Positioned(
                  left: 24,
                  top: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mapData.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            );
          } catch (e, st) {
            // Show exception and stack trace to help root-cause the invalid argument
            final trace = st.toString();
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.shade700,
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turf map error: $e',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trace.length > 200 ? '${trace.substring(0, 200)}...' : trace,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
