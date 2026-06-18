import 'package:flutter/material.dart';

class TurfTerritory {
  final String id;
  final String label;
  final String description;
  final Color color;
  final int defense;
  /// Normalized polygon points (0.0–1.0 relative to map size)
  final List<Offset> polygonPoints;
  /// Normalized position for the label text (0.0–1.0)
  final Offset labelPosition;

  const TurfTerritory({
    required this.id,
    required this.label,
    required this.description,
    required this.color,
    required this.defense,
    required this.polygonPoints,
    required this.labelPosition,
  });

  Offset centroid() {
    if (polygonPoints.isEmpty) return Offset.zero;
    double cx = 0, cy = 0;
    for (final p in polygonPoints) {
      cx += p.dx;
      cy += p.dy;
    }
    return Offset(cx / polygonPoints.length, cy / polygonPoints.length);
  }
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

// ─── Polygon Painter ───────────────────────────────────────────────────────

class _TurfMapPainter extends CustomPainter {
  final TurfMapData mapData;
  final String selectedTerritoryId;
  final Set<String> conqueredTerritoryIds;

  _TurfMapPainter({
    required this.mapData,
    required this.selectedTerritoryId,
    required this.conqueredTerritoryIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines for map feel
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const gridCount = 10;
    for (int i = 0; i <= gridCount; i++) {
      final x = size.width * i / gridCount;
      final y = size.height * i / gridCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final territory in mapData.territories) {
      final bool isSelected = territory.id == selectedTerritoryId;
      final bool isConquered = conqueredTerritoryIds.contains(territory.id);

      // Scale polygon points to canvas size
      final points = territory.polygonPoints
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();

      if (points.length < 3) continue;

      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();

      // Fill
      final Color fillColor = isConquered
          ? Color.lerp(territory.color, const Color(0xFF34C759), 0.55)!
          : territory.color;

      final fillPaint = Paint()
        ..color = fillColor.withValues(alpha: isConquered ? 0.55 : 0.28)
        ..style = PaintingStyle.fill;

      // Glow shadow for selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = const Color(0xFFE24B4A).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, glowPaint);
      }

      canvas.drawPath(path, fillPaint);

      // Border
      final borderPaint = Paint()
        ..color = isSelected
            ? const Color(0xFFE24B4A)
            : isConquered
            ? const Color(0xFF34C759).withValues(alpha: 0.8)
            : territory.color.withValues(alpha: 0.7)
        ..strokeWidth = isSelected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, borderPaint);

      // Status badge (small dot)
      final centroid = Offset(
        territory.labelPosition.dx * size.width,
        territory.labelPosition.dy * size.height,
      );

      if (isConquered) {
        final dotPaint = Paint()
          ..color = const Color(0xFF34C759)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(centroid.translate(0, 18), 5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_TurfMapPainter oldDelegate) =>
      oldDelegate.selectedTerritoryId != selectedTerritoryId ||
      oldDelegate.conqueredTerritoryIds.length != conqueredTerritoryIds.length;
}

// ─── Label Painter ─────────────────────────────────────────────────────────

class _TurfLabelPainter extends CustomPainter {
  final TurfMapData mapData;
  final String selectedTerritoryId;
  final Set<String> conqueredTerritoryIds;

  _TurfLabelPainter({
    required this.mapData,
    required this.selectedTerritoryId,
    required this.conqueredTerritoryIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final territory in mapData.territories) {
      final isSelected = territory.id == selectedTerritoryId;
      final isConquered = conqueredTerritoryIds.contains(territory.id);
      final center = Offset(
        territory.labelPosition.dx * size.width,
        territory.labelPosition.dy * size.height,
      );

      final labelColor = isConquered
          ? const Color(0xFF34C759)
          : isSelected
          ? Colors.white
          : Colors.white70;

      final textPainter = TextPainter(
        text: TextSpan(
          text: territory.label.toUpperCase(),
          style: TextStyle(
            color: labelColor,
            fontSize: isSelected ? 11 : 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center.translate(-textPainter.width / 2, -textPainter.height / 2),
      );

      // Defense label below
      final defPainter = TextPainter(
        text: TextSpan(
          text: isConquered ? '✓' : 'DEF ${territory.defense}',
          style: TextStyle(
            color: isConquered
                ? const Color(0xFF34C759)
                : Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      defPainter.layout();
      defPainter.paint(
        canvas,
        center.translate(-defPainter.width / 2, textPainter.height / 2 + 2),
      );
    }
  }

  @override
  bool shouldRepaint(_TurfLabelPainter oldDelegate) =>
      oldDelegate.selectedTerritoryId != selectedTerritoryId ||
      oldDelegate.conqueredTerritoryIds.length != conqueredTerritoryIds.length;
}

// ─── Public Map Widget ─────────────────────────────────────────────────────

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

  bool _pointInPolygon(Offset point, List<Offset> polygon, Size size) {
    final scaledPoly = polygon
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();
    int intersectCount = 0;
    for (int i = 0; i < scaledPoly.length; i++) {
      final Offset v1 = scaledPoly[i];
      final Offset v2 = scaledPoly[(i + 1) % scaledPoly.length];
      if (((v1.dy > point.dy) != (v2.dy > point.dy)) &&
          (point.dx <
              (v2.dx - v1.dx) * (point.dy - v1.dy) / (v2.dy - v1.dy) +
                  v1.dx)) {
        intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E1014), Color(0xFF181C24)],
              ),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: GestureDetector(
                onTapDown: (details) {
                  final tapPos = details.localPosition;
                  // Test from last to first (topmost visually)
                  for (final territory
                      in mapData.territories.reversed) {
                    if (_pointInPolygon(
                      tapPos,
                      territory.polygonPoints,
                      size,
                    )) {
                      onTerritoryTap(territory);
                      break;
                    }
                  }
                },
                child: Stack(
                  children: [
                    // Polygon fills + borders
                    CustomPaint(
                      size: size,
                      painter: _TurfMapPainter(
                        mapData: mapData,
                        selectedTerritoryId: selectedTerritoryId,
                        conqueredTerritoryIds: conqueredTerritoryIds,
                      ),
                    ),
                    // Labels layer
                    CustomPaint(
                      size: size,
                      painter: _TurfLabelPainter(
                        mapData: mapData,
                        selectedTerritoryId: selectedTerritoryId,
                        conqueredTerritoryIds: conqueredTerritoryIds,
                      ),
                    ),
                    // Map title overlay
                    Positioned(
                      left: 16,
                      top: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mapData.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            mapData.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
