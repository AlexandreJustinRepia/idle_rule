import 'dart:ui' show Tangent;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/game_controller.dart';
import '../../game_state.dart';

// ─── Animated Locked Training Room Card ───────────────────────────────────────

class LockedTrainingRoomCard extends StatefulWidget {
  final GameController gameController;
  final GangBuildingStage nextStage;

  const LockedTrainingRoomCard({
    super.key,
    required this.gameController,
    required this.nextStage,
  });

  @override
  State<LockedTrainingRoomCard> createState() => _LockedTrainingRoomCardState();
}

class _LockedTrainingRoomCardState extends State<LockedTrainingRoomCard>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _shimmerController;
  late final Animation<double> _breathAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breathAnim = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = widget.gameController.gangBuildingLevel;
    final requiredLevel = widget.nextStage.minLevel;
    final progress = (currentLevel / requiredLevel).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final progressColor = Color.lerp(
      const Color(0xFFE24B4A),
      const Color(0xFFFFCC00),
      progress,
    )!;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _shimmerController]),
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: CustomPaint(
            painter: _ShimmerBorderPainter(
              progress: _shimmerController.value,
              breathe: _breathAnim.value,
              borderRadius: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ───────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFCC00).withValues(
                                alpha: 0.08 + _breathAnim.value * 0.28,
                              ),
                              blurRadius: 6 + _breathAnim.value * 14,
                              spreadRadius: _breathAnim.value * 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: Color.lerp(
                            Colors.white24,
                            const Color(0xFFFFCC00),
                            _breathAnim.value * 0.55,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'TRAINING ROOM',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            color: Colors.white38,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Color.lerp(
                                Colors.white30,
                                const Color(0xFFFFCC00),
                                _breathAnim.value * 0.4,
                              ),
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LOCKED',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 12),
                  // ── Requirement + Progress ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REQUIREMENT',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.nextStage.name} Lv.$requiredLevel',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CURRENT PROGRESS',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lv.$currentLevel / Lv.$requiredLevel',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ── Progress bar ─────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 12),
                  // ── Unlocks Preview ──────────────────────────────────
                  const Text(
                    'UNLOCKS',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _UnlockRow(label: 'Recruit gang members in batches'),
                  const SizedBox(height: 6),
                  _UnlockRow(label: 'Train & level up your crew'),
                  const SizedBox(height: 6),
                  _UnlockRow(label: 'Promote members to higher tiers'),
                  const SizedBox(height: 6),
                  _UnlockRow(label: 'Access Brawler & Enforcer recruits'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Unlock Row ───────────────────────────────────────────────────────────────

class _UnlockRow extends StatelessWidget {
  final String label;

  const _UnlockRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF34C759), size: 10),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Shimmer Border Painter ───────────────────────────────────────────────────

class _ShimmerBorderPainter extends CustomPainter {
  final double progress; // 0.0→1.0, position of spark around perimeter
  final double breathe; // 0.0→1.0, breathing phase
  final double borderRadius;

  const _ShimmerBorderPainter({
    required this.progress,
    required this.breathe,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      radius,
    );

    // Base border — faint, always visible, breathes slightly
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.08 + breathe * 0.06);
    canvas.drawRRect(rrect, basePaint);

    // Build perimeter path and find the spark position
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold(0.0, (sum, m) => sum + m.length);
    final targetDist = progress * totalLength;

    // Find tangent at target distance
    double walked = 0;
    Tangent? tangent;
    for (final metric in metrics) {
      if (walked + metric.length >= targetDist) {
        tangent = metric.getTangentForOffset(targetDist - walked);
        break;
      }
      walked += metric.length;
    }
    if (tangent == null) return;

    final sparkPos = tangent.position;
    const sparkRadius = 36.0;

    // Glow trail behind the spark
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFCC00).withValues(alpha: 0.55 + breathe * 0.2),
          const Color(0xFFFFCC00).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sparkPos, radius: sparkRadius));

    final arcPath = _subPath(path, targetDist, totalLength, sparkRadius * 0.8);
    canvas.drawPath(arcPath, glowPaint);

    // Bright dot at the spark tip
    canvas.drawCircle(
      sparkPos,
      2.5 + breathe * 1.0,
      Paint()
        ..color = const Color(
          0xFFFFEE88,
        ).withValues(alpha: 0.85 + breathe * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      sparkPos,
      1.5,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  /// Returns a sub-path of [original] of [length] centred at [center].
  Path _subPath(Path original, double center, double total, double length) {
    final half = length / 2;
    final start = center - half;
    final end = center + half;
    final metrics = original.computeMetrics().toList();

    Path result = Path();
    bool started = false;
    double wrap(double d) => ((d % total) + total) % total;

    double current = 0;
    for (final metric in metrics) {
      final mStart = current;
      double localStart = wrap(start) - mStart;
      double localEnd = wrap(end) - mStart;

      if (localStart < 0) localStart = 0;
      if (localEnd > metric.length) localEnd = metric.length;
      if (localStart < localEnd) {
        final extracted = metric.extractPath(localStart, localEnd);
        if (!started) {
          result = extracted;
          started = true;
        } else {
          result.addPath(extracted, Offset.zero);
        }
      }
      current += metric.length;
    }
    return result;
  }

  @override
  bool shouldRepaint(_ShimmerBorderPainter old) =>
      old.progress != progress || old.breathe != breathe;
}
