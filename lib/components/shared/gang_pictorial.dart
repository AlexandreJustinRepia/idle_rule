import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/gang.dart';

class GangPictorial extends StatelessWidget {
  final Gang? gang;
  final double width;
  final double height;

  const GangPictorial({
    super.key,
    required this.gang,
    this.width = 110,
    this.height = 75,
  });

  @override
  Widget build(BuildContext context) {
    // If no gang controls it, we show a neutral/unclaimed layout or a default street crew
    final activeGang = gang ?? const Gang(
      name: 'Neutral Crew',
      emblemId: 'skull',
      primaryColor: Colors.grey,
      accentColor: Colors.white24,
    );

    return CustomPaint(
      size: Size(width, height),
      painter: _GangFrontPainter(
        primaryColor: activeGang.primaryColor,
        accentColor: activeGang.accentColor,
        emblemIcon: activeGang.emblem,
      ),
    );
  }
}

class _GangFrontPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final IconData emblemIcon;

  const _GangFrontPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.emblemIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;

    // Draw a subtle background backing circle or glow for premium UI aesthetics
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy * 0.5), size.height * 0.45, glowPaint);

    // Draw Left Member (slightly smaller, background)
    _drawMember(
      canvas,
      x: cx - size.width * 0.24,
      y: cy - 2,
      heightFactor: 0.78,
      shoulderWidth: size.width * 0.28,
      skinColor: const Color(0xFFC8A280),
      isLeader: false,
    );

    // Draw Right Member (slightly smaller, background)
    _drawMember(
      canvas,
      x: cx + size.width * 0.24,
      y: cy - 2,
      heightFactor: 0.78,
      shoulderWidth: size.width * 0.28,
      skinColor: const Color(0xFFD8B290),
      isLeader: false,
    );

    // Draw Center Member (Leader/Enforcer, foreground)
    _drawMember(
      canvas,
      x: cx,
      y: cy,
      heightFactor: 0.95,
      shoulderWidth: size.width * 0.35,
      skinColor: const Color(0xFFE4BC9C),
      isLeader: true,
    );
  }

  void _drawMember(
    Canvas canvas, {
    required double x,
    required double y,
    required double heightFactor,
    required double shoulderWidth,
    required Color skinColor,
    required bool isLeader,
  }) {
    // Member height is relative to the canvas height
    final memberH = y * heightFactor;
    final torsoH = memberH * 0.5;
    final neckH = memberH * 0.08;
    final headRadius = memberH * 0.20;

    final headCenterY = y - torsoH - neckH - headRadius;
    final shoulderTopY = y - torsoH;

    // 1. Draw Torso (Hoodie/Jacket) - Front facing
    final torsoPaint = Paint()..color = primaryColor;
    final torsoPath = Path()
      ..moveTo(x - shoulderWidth / 2, y)
      ..lineTo(x - shoulderWidth / 2 * 0.8, shoulderTopY)
      ..lineTo(x + shoulderWidth / 2 * 0.8, shoulderTopY)
      ..lineTo(x + shoulderWidth / 2, y)
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);

    // 2. Draw Accent Trim / Collar (V-neck or stripes)
    final trimPaint = Paint()..color = accentColor;
    final trimPath = Path()
      ..moveTo(x - shoulderWidth * 0.15, shoulderTopY)
      ..lineTo(x, shoulderTopY + torsoH * 0.28)
      ..lineTo(x + shoulderWidth * 0.15, shoulderTopY)
      ..close();
    canvas.drawPath(trimPath, trimPaint);

    // Leader gets a gold/accent emblem printed on their chest
    if (isLeader) {
      final emblemPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, shoulderTopY + torsoH * 0.42), 3.5, emblemPaint);
    }

    // 3. Draw Neck
    final neckPaint = Paint()..color = skinColor.withValues(alpha: 0.9);
    canvas.drawRect(
      Rect.fromLTRB(x - 3.5, shoulderTopY - neckH, x + 3.5, shoulderTopY),
      neckPaint,
    );

    // 4. Draw Head
    final headPaint = Paint()..color = skinColor;
    canvas.drawCircle(Offset(x, headCenterY), headRadius, headPaint);

    // 5. Draw Face Mask / Bandana
    final maskPaint = Paint()..color = accentColor;
    final maskPath = Path()
      // Covers lower half of the circle
      ..moveTo(x - headRadius, headCenterY + 1)
      ..quadraticBezierTo(x, headCenterY + 3, x + headRadius, headCenterY + 1)
      ..lineTo(x + headRadius * 0.85, headCenterY + headRadius)
      ..quadraticBezierTo(x, headCenterY + headRadius * 1.25, x - headRadius * 0.85, headCenterY + headRadius)
      ..close();
    canvas.drawPath(maskPath, maskPaint);

    // 6. Sunglasses/Cool eyes (a horizontal dark line or visor)
    final sunglassesPaint = Paint()
      ..color = const Color(0xFF0F0F0F)
      ..style = PaintingStyle.fill;
    final glassPath = Path()
      ..moveTo(x - headRadius * 0.7, headCenterY - headRadius * 0.2)
      ..lineTo(x + headRadius * 0.7, headCenterY - headRadius * 0.2)
      ..lineTo(x + headRadius * 0.5, headCenterY + headRadius * 0.1)
      ..lineTo(x - headRadius * 0.5, headCenterY + headRadius * 0.1)
      ..close();
    canvas.drawPath(glassPath, sunglassesPaint);

    // Highlight on sunglasses
    final glassHighlight = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(x - headRadius * 0.4, headCenterY - headRadius * 0.15),
      Offset(x - headRadius * 0.1, headCenterY - headRadius * 0.1),
      glassHighlight,
    );

    // 7. Hood / Hair over head
    final hoodPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    // Draw hood outline over the head
    final hoodPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(x, headCenterY), radius: headRadius + 1.5),
        -math.pi * 1.15,
        math.pi * 1.3,
      );
    canvas.drawPath(hoodPath, hoodPaint);
  }

  @override
  bool shouldRepaint(covariant _GangFrontPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.emblemIcon != emblemIcon;
  }
}
