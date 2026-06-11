import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HERO PAINTER  (canvas: 90 × 140)
// ─────────────────────────────────────────────────────────────────────────────
class HeroPainter extends CustomPainter {
  final Color accentColor;
  final double walkProgress;
  final double idleProgress;
  final double punchProgress; // 0..1: boxing guard -> jab -> retract

  const HeroPainter({
    this.accentColor = Colors.blueAccent,
    this.walkProgress = 0.0,
    this.idleProgress = 0.0,
    this.punchProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // ── Swing / idle calculation ──────────────────────────
    // idleProgress is a 0..1 sine-wave for breathing when still
    final isWalking = walkProgress != 0.5 && walkProgress != 0.0;
    final swing = isWalking ? (walkProgress - 0.5) * 1.2 : 0.0;
    // Idle breath: arms swing gently, body bobs
    final idleSway = isWalking ? 0.0 : (idleProgress - 0.5) * 0.18;
    final idleBob = isWalking ? 0.0 : (idleProgress - 0.5) * 2.0;

    // Apply idle bob to canvas so entire character breathes
    if (!isWalking) canvas.translate(0, idleBob);

    // Colors
    final skinColor = const Color(0xFFE8D5C0);
    final skinColorDark = const Color(0xFFD4C0B0);

    // Common measurements
    final shoulder = Offset(cx, 47);
    final hip = Offset(cx, 81);
    const bodyTop = 37.0;
    const bodyW = 24.0;
    const bodyH = 44.0;

    final isPunching = punchProgress > 0.01;

    // ── Back Arm (Left) ───────────────────────────────────
    final backArmPaint = Paint()..color = const Color(0xFF162D4A)..strokeWidth = 10..strokeCap = StrokeCap.round;
    final backForearmPaint = Paint()..color = const Color(0xFF0F2035)..strokeWidth = 8..strokeCap = StrokeCap.round;
    
    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      final backElbowNormal = Offset(cx, 47 + 18);
      final backFistNormal = Offset(cx, 47 + 34);
      final backElbowGuard = Offset(cx + 4, 38);
      final backFistGuard = Offset(cx + 8, 24);

      final backElbow = Offset.lerp(backElbowNormal, backElbowGuard, guardT)!;
      final backFist = Offset.lerp(backFistNormal, backFistGuard, guardT)!;

      canvas.drawLine(shoulder, backElbow, backArmPaint);
      canvas.drawLine(backElbow, backFist, backForearmPaint);
      canvas.drawCircle(backFist, 5.5, Paint()..color = skinColorDark);
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? -swing : idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, 47 + 18), backArmPaint);
      canvas.drawLine(Offset(cx, 47 + 18), Offset(cx, 47 + 34), backForearmPaint);
      canvas.drawCircle(Offset(cx, 47 + 34), 5.5, Paint()..color = skinColorDark);
      canvas.restore();
    }

    // ── Back Leg (Left) ───────────────────────────────────
    final backLegPaint = Paint()..color = const Color(0xFF0D162A)..strokeWidth = 12..strokeCap = StrokeCap.round;
    final backShinPaint = Paint()..color = const Color(0xFF070D1A)..strokeWidth = 10..strokeCap = StrokeCap.round;
    
    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, 81 + 22), backLegPaint);
    canvas.drawLine(Offset(cx, 81 + 22), Offset(cx, 81 + 40), backShinPaint);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, 81 + 36, cx + 10, 81 + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Body ──────────────────────────────────────────────
    final bodyLeft = cx - bodyW / 2;
    final bodyRect = RRect.fromLTRBR(bodyLeft, bodyTop, bodyLeft + bodyW, bodyTop + bodyH, const Radius.circular(8));
    
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF1E3A5F));
    canvas.drawRRect(bodyRect, Paint()..color = accentColor.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Chest stripe (shifted right for side profile)
    canvas.drawLine(Offset(cx + 6, bodyTop + 6), Offset(cx + 6, bodyTop + bodyH - 6),
        Paint()..color = accentColor.withValues(alpha: 0.3)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // ── Neck ──────────────────────────────────────────────
    const neckTop = 30.0;
    canvas.drawRRect(RRect.fromLTRBR(cx - 3, neckTop, cx + 3, neckTop + 7, const Radius.circular(3)), Paint()..color = skinColorDark);

    // ── Head ──────────────────────────────────────────────
    final headR = 14.0;
    final headCY = 16.0;

    canvas.drawCircle(Offset(cx, headCY), headR + 8,
        Paint()..color = accentColor.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.drawCircle(Offset(cx, headCY), headR, Paint()..color = skinColor);

    // Hair
    final hairPaint = Paint()..color = accentColor;
    final hairPath = Path();
    hairPath.moveTo(cx + 8, headCY - 8);
    hairPath.quadraticBezierTo(cx - 2, headCY - 22, cx - 8, headCY - 24);
    hairPath.lineTo(cx - 5, headCY - 16);
    hairPath.lineTo(cx - 15, headCY - 20);
    hairPath.lineTo(cx - 8, headCY - 12);
    hairPath.lineTo(cx - 20, headCY - 8);
    hairPath.lineTo(cx - 12, headCY - 2);
    hairPath.quadraticBezierTo(cx - 5, headCY - 10, cx + 8, headCY - 8);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Highlight
    canvas.drawCircle(Offset(cx - 2, headCY - 5), 4,
        Paint()..color = Colors.white.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Eye (side profile, only one eye visible)
    canvas.drawCircle(Offset(cx + 6, headCY + 1), 2.5, Paint()..color = Colors.black87);

    // ── Front Leg (Right) ─────────────────────────────────
    final frontLegPaint = Paint()..color = const Color(0xFF14213D)..strokeWidth = 12..strokeCap = StrokeCap.round;
    final frontShinPaint = Paint()..color = const Color(0xFF0D1B2A)..strokeWidth = 10..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(-swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, 81 + 22), frontLegPaint);
    canvas.drawLine(Offset(cx, 81 + 22), Offset(cx, 81 + 40), frontShinPaint);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, 81 + 36, cx + 10, 81 + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Front Arm (Right) ─────────────────────────────────
    final frontArmPaint = Paint()..color = const Color(0xFF1E3A5F)..strokeWidth = 10..strokeCap = StrokeCap.round;
    final frontForearmPaint = Paint()..color = const Color(0xFF16305A)..strokeWidth = 8..strokeCap = StrokeCap.round;

    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      double extendFactor = 0.0;
      if (punchProgress >= 0.25 && punchProgress <= 0.75) {
        if (punchProgress < 0.50) {
          extendFactor = (punchProgress - 0.25) / 0.25;
        } else {
          extendFactor = (0.75 - punchProgress) / 0.25;
        }
      }

      final frontElbowNormal = Offset(cx, 47 + 18);
      final frontFistNormal = Offset(cx, 47 + 34);

      final frontElbowGuard = Offset(cx + 10, 40);
      final frontFistGuard = Offset(cx + 14, 26);

      final frontElbowExtended = Offset(cx + 24, 45);
      final frontFistExtended = Offset(cx + 46, 45);

      final guardElbow = Offset.lerp(frontElbowNormal, frontElbowGuard, guardT)!;
      final guardFist = Offset.lerp(frontFistNormal, frontFistGuard, guardT)!;

      final finalElbow = Offset.lerp(guardElbow, frontElbowExtended, extendFactor)!;
      final finalFist = Offset.lerp(guardFist, frontFistExtended, extendFactor)!;

      canvas.drawLine(shoulder, finalElbow, frontArmPaint);
      canvas.drawLine(finalElbow, finalFist, frontForearmPaint);
      canvas.drawCircle(finalFist, 5.5 + 1.5 * extendFactor, Paint()..color = skinColor);
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? swing : -idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, 47 + 18), frontArmPaint);
      canvas.drawLine(Offset(cx, 47 + 18), Offset(cx, 47 + 34), frontForearmPaint);
      canvas.drawCircle(Offset(cx, 47 + 34), 5.5, Paint()..color = skinColor);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HeroPainter old) =>
      old.accentColor != accentColor ||
      old.walkProgress != walkProgress ||
      old.idleProgress != idleProgress ||
      old.punchProgress != punchProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// ALLY PAINTER  (canvas: 90 × 140 - scaled to match Hero)
// ─────────────────────────────────────────────────────────────────────────────
class AllyPainter extends CustomPainter {
  final Color accentColor;
  final String label;
  final double walkProgress;
  final double idleProgress;
  final double punchProgress;

  const AllyPainter({
    required this.accentColor,
    required this.label,
    this.walkProgress = 0.0,
    this.idleProgress = 0.0,
    this.punchProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const headR = 14.0;
    const headCY = 16.0;

    final isWalking = walkProgress != 0.5 && walkProgress != 0.0;
    final swing = isWalking ? (walkProgress - 0.5) * 1.2 : 0.0;
    final idleSway = isWalking ? 0.0 : (idleProgress - 0.5) * 0.18;
    final idleBob = isWalking ? 0.0 : (idleProgress - 0.5) * 2.0;
    if (!isWalking) canvas.translate(0, idleBob);

    final shoulder = Offset(cx, 47);
    final hip = Offset(cx, 81);
    const bodyTop = 37.0;
    const bodyW = 24.0;
    const bodyH = 44.0;

    final isPunching = punchProgress > 0.01;

    // ── Back Arm (Left) ───────────────────────────────────
    final backArmPaint = Paint()..color = const Color(0xFF1A1A2A)..strokeWidth = 10..strokeCap = StrokeCap.round;
    final backForearmPaint = Paint()..color = const Color(0xFF1A1A2A)..strokeWidth = 8..strokeCap = StrokeCap.round;

    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      final backElbowNormal = Offset(cx, 47 + 18);
      final backFistNormal = Offset(cx, 47 + 34);
      final backElbowGuard = Offset(cx + 4, 38);
      final backFistGuard = Offset(cx + 8, 24);

      final backElbow = Offset.lerp(backElbowNormal, backElbowGuard, guardT)!;
      final backFist = Offset.lerp(backFistNormal, backFistGuard, guardT)!;

      canvas.drawLine(shoulder, backElbow, backArmPaint);
      canvas.drawLine(backElbow, backFist, backForearmPaint);
      canvas.drawCircle(backFist, 5.5, Paint()..color = const Color(0xFFB49872));
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? -swing : idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, 47 + 18), backArmPaint);
      canvas.drawLine(Offset(cx, 47 + 18), Offset(cx, 47 + 34), backForearmPaint);
      canvas.drawCircle(Offset(cx, 47 + 34), 5.5, Paint()..color = const Color(0xFFB49872));
      canvas.restore();
    }

    // ── Back Leg (Left) ───────────────────────────────────
    final backLegPaint = Paint()..color = const Color(0xFF0A0A0A)..strokeWidth = 12..strokeCap = StrokeCap.round;
    
    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, 81 + 22), backLegPaint);
    canvas.drawLine(Offset(cx, 81 + 22), Offset(cx, 81 + 40), Paint()..color = const Color(0xFF050505)..strokeWidth = 10..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, 81 + 36, cx + 10, 81 + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Body ──────────────────────────────────────────────
    final bodyLeft = cx - bodyW / 2;
    final bodyRect = RRect.fromLTRBR(bodyLeft, bodyTop, bodyLeft + bodyW, bodyTop + bodyH, const Radius.circular(8));
    
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF2A2A3A));
    canvas.drawRRect(bodyRect, Paint()..color = accentColor.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Neck
    canvas.drawRRect(RRect.fromLTRBR(cx - 3, 30, cx + 3, 37, const Radius.circular(3)), Paint()..color = const Color(0xFFC4A882));

    // Glow
    canvas.drawCircle(Offset(cx, headCY), headR + 8,
        Paint()..color = accentColor.withValues(alpha: 0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Head
    canvas.drawCircle(Offset(cx, headCY), headR, Paint()..color = const Color(0xFFD4B896));

    // Hair
    final hairPaint = Paint()..color = accentColor;
    final hairPath = Path();
    hairPath.moveTo(cx + 8, headCY - 8);
    hairPath.quadraticBezierTo(cx - 3, headCY - 21, cx - 8, headCY - 24);
    hairPath.lineTo(cx - 5, headCY - 16);
    hairPath.lineTo(cx - 16, headCY - 18);
    hairPath.lineTo(cx - 8, headCY - 10);
    hairPath.lineTo(cx - 18, headCY - 5);
    hairPath.lineTo(cx - 10, headCY - 1);
    hairPath.quadraticBezierTo(cx - 5, headCY - 10, cx + 8, headCY - 8);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Eye
    canvas.drawCircle(Offset(cx + 6, headCY + 1), 2.5, Paint()..color = Colors.black87);

    // ── Front Leg (Right) ─────────────────────────────────
    final frontLegPaint = Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 12..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(-swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, 81 + 22), frontLegPaint);
    canvas.drawLine(Offset(cx, 81 + 22), Offset(cx, 81 + 40), Paint()..color = const Color(0xFF111111)..strokeWidth = 10..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, 81 + 36, cx + 10, 81 + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Front Arm (Right) ─────────────────────────────────
    final frontArmPaint = Paint()..color = const Color(0xFF2A2A3A)..strokeWidth = 10..strokeCap = StrokeCap.round;
    final frontForearmPaint = Paint()..color = const Color(0xFF2A2A3A)..strokeWidth = 8..strokeCap = StrokeCap.round;

    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      double extendFactor = 0.0;
      if (punchProgress >= 0.25 && punchProgress <= 0.75) {
        if (punchProgress < 0.50) {
          extendFactor = (punchProgress - 0.25) / 0.25;
        } else {
          extendFactor = (0.75 - punchProgress) / 0.25;
        }
      }

      final frontElbowNormal = Offset(cx, 47 + 18);
      final frontFistNormal = Offset(cx, 47 + 34);

      final frontElbowGuard = Offset(cx + 8, 32);
      final frontFistGuard = Offset(cx + 11, 22);

      final frontElbowExtended = Offset(cx + 24, 45);
      final frontFistExtended = Offset(cx + 46, 45);

      final guardElbow = Offset.lerp(frontElbowNormal, frontElbowGuard, guardT)!;
      final guardFist = Offset.lerp(frontFistNormal, frontFistGuard, guardT)!;

      final finalElbow = Offset.lerp(guardElbow, frontElbowExtended, extendFactor)!;
      final finalFist = Offset.lerp(guardFist, frontFistExtended, extendFactor)!;

      canvas.drawLine(shoulder, finalElbow, frontArmPaint);
      canvas.drawLine(finalElbow, finalFist, frontForearmPaint);
      canvas.drawCircle(finalFist, 5.5 + 1.5 * extendFactor, Paint()..color = const Color(0xFFC4A882));
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? swing : -idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, 47 + 18), frontArmPaint);
      canvas.drawLine(Offset(cx, 47 + 18), Offset(cx, 47 + 34), frontForearmPaint);
      canvas.drawCircle(Offset(cx, 47 + 34), 5.5, Paint()..color = const Color(0xFFC4A882));
      canvas.restore();
    }

    // Label
    _drawLabel(canvas, label.length > 5 ? label.substring(0, 5) : label, Offset(cx, bodyTop + bodyH / 2), accentColor, fontSize: 7);
  }

  @override
  bool shouldRepaint(covariant AllyPainter old) =>
      old.accentColor != accentColor ||
      old.label != label ||
      old.walkProgress != walkProgress ||
      old.idleProgress != idleProgress ||
      old.punchProgress != punchProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// ENEMY PAINTER  (canvas: 90 × 140 regular, 115 × 165 boss)
// ─────────────────────────────────────────────────────────────────────────────
class EnemyPainter extends CustomPainter {
  final Color accentColor;
  final bool isBoss;
  final bool wasHit;
  final double chargeValue;
  final double walkProgress;
  final double idleProgress;
  final double punchProgress;

  const EnemyPainter({
    required this.accentColor,
    this.isBoss = false,
    this.wasHit = false,
    this.chargeValue = 0,
    this.walkProgress = 0.0,
    this.idleProgress = 0.0,
    this.punchProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Flip horizontal for side view facing left ─────────
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.scale(-1, 1);

    final cx = size.width / 2;
    final skinColor = wasHit ? Colors.white : const Color(0xFFC0A080);
    final skinColorDark = wasHit ? Colors.white70 : const Color(0xFFB09070);
    final headR = isBoss ? 17.0 : 14.0;
    final headCY = isBoss ? (headR + 4) : 16.0;

    final isWalking = walkProgress != 0.5 && walkProgress != 0.0;
    final swing = isWalking ? (walkProgress - 0.5) * 1.2 : 0.0;
    final idleSway = isWalking ? 0.0 : (idleProgress - 0.5) * 0.18;
    final idleBob = isWalking ? 0.0 : (idleProgress - 0.5) * 2.0;
    if (!isWalking) canvas.translate(0, idleBob);

    final bodyTop = isBoss ? (headCY + headR + 6) : 37.0;
    final bodyH = isBoss ? 52.0 : 44.0;
    final legTop = bodyTop + bodyH;

    final upperArmW = isBoss ? 13.0 : 10.0;
    final forearmW = isBoss ? 11.0 : 8.0;
    final armReach = isBoss ? 20.0 : 18.0;

    final bodyColor = isBoss ? const Color(0xFF1A0000) : const Color(0xFF3D0000);
    final bodyColorDark = isBoss ? const Color(0xFF0D0000) : const Color(0xFF2D0000);

    final shoulder = Offset(cx, bodyTop + 10);
    final hip = Offset(cx, legTop);

    final isPunching = punchProgress > 0.01;

    // ── Back Arm (Left) ───────────────────────────────────
    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      final backElbowNormal = Offset(cx, bodyTop + 10 + armReach);
      final backFistNormal = Offset(cx, bodyTop + 10 + armReach + 16);
      final backElbowGuard = Offset(cx + (isBoss ? 6 : 4), bodyTop + 2);
      final backFistGuard = Offset(cx + (isBoss ? 10 : 7), headCY + 4);

      final backElbow = Offset.lerp(backElbowNormal, backElbowGuard, guardT)!;
      final backFist = Offset.lerp(backFistNormal, backFistGuard, guardT)!;

      canvas.drawLine(shoulder, backElbow, Paint()..color = bodyColorDark..strokeWidth = upperArmW..strokeCap = StrokeCap.round);
      canvas.drawLine(backElbow, backFist, Paint()..color = bodyColorDark..strokeWidth = forearmW..strokeCap = StrokeCap.round);
      canvas.drawCircle(backFist, isBoss ? 7 : 5.5, Paint()..color = skinColorDark);
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? -swing : idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, bodyTop + 10 + armReach),
          Paint()..color = bodyColorDark..strokeWidth = upperArmW..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(cx, bodyTop + 10 + armReach), Offset(cx, bodyTop + 10 + armReach + 16),
          Paint()..color = bodyColorDark..strokeWidth = forearmW..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(cx, bodyTop + 10 + armReach + 16), isBoss ? 7 : 5.5, Paint()..color = skinColorDark);
      canvas.restore();
    }

    // ── Back Leg (Left) ───────────────────────────────────
    final legW = isBoss ? 14.0 : 12.0;
    final shinW = isBoss ? 12.0 : 10.0;
    
    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, legTop + 22), Paint()..color = const Color(0xFF1A0000)..strokeWidth = legW..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx, legTop + 22), Offset(cx, legTop + 40), Paint()..color = const Color(0xFF0A0000)..strokeWidth = shinW..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, legTop + 36, cx + 12, legTop + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Body ──────────────────────────────────────────────
    final bodyW = isBoss ? 32.0 : 24.0;
    final bodyLeft = cx - bodyW / 2;
    final bodyRect = RRect.fromLTRBR(bodyLeft, bodyTop, bodyLeft + bodyW, bodyTop + bodyH, const Radius.circular(8));

    canvas.drawRRect(bodyRect, Paint()..color = wasHit ? Colors.white24 : bodyColor);
    canvas.drawRRect(bodyRect, Paint()..color = accentColor.withValues(alpha: wasHit ? 1.0 : 0.7)..style = PaintingStyle.stroke..strokeWidth = isBoss ? 2.5 : 2.0);

    // Charge bar (shifted right)
    if (chargeValue > 0) {
      canvas.drawRRect(
          RRect.fromLTRBR(cx + 2, bodyTop + bodyH - 7, cx + 2 + (bodyW/2 - 4) * chargeValue, bodyTop + bodyH - 3, const Radius.circular(2)),
          Paint()..color = Colors.orangeAccent.withValues(alpha: 0.8));
    }

    // Neck
    canvas.drawRRect(RRect.fromLTRBR(cx - 4, headCY + headR, cx + 4, bodyTop, const Radius.circular(3)), Paint()..color = skinColorDark);

    // Glow
    canvas.drawCircle(Offset(cx, headCY), headR + 10,
        Paint()..color = accentColor.withValues(alpha: wasHit ? 0.8 : 0.45)..maskFilter = MaskFilter.blur(BlurStyle.normal, isBoss ? 16 : 10));

    // Head
    canvas.drawCircle(Offset(cx, headCY), headR, Paint()..color = skinColor);

    // Enemy Hair (Regular punk mohawk/spikes) - sweeping back (left)
    if (!isBoss) {
      final hairPaint = Paint()..color = accentColor;
      final hairPath = Path();
      hairPath.moveTo(cx + 8, headCY - 8);
      hairPath.quadraticBezierTo(cx - 2, headCY - 22, cx - 8, headCY - 24);
      hairPath.lineTo(cx - 5, headCY - 16);
      hairPath.lineTo(cx - 15, headCY - 20);
      hairPath.lineTo(cx - 8, headCY - 12);
      hairPath.lineTo(cx - 20, headCY - 8);
      hairPath.lineTo(cx - 12, headCY - 2);
      hairPath.quadraticBezierTo(cx - 5, headCY - 10, cx + 8, headCY - 8);
      hairPath.close();
      canvas.drawPath(hairPath, hairPaint);
    }

    // Boss crown
    if (isBoss) {
      final crownPaint = Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeJoin = StrokeJoin.miter;
      final path = Path();
      path.moveTo(cx - 10, headCY - headR + 2);
      path.lineTo(cx - 10, headCY - headR - 9);
      path.lineTo(cx - 5, headCY - headR - 3);
      path.lineTo(cx, headCY - headR - 12);
      path.lineTo(cx + 5, headCY - headR - 3);
      path.lineTo(cx + 10, headCY - headR - 9);
      path.lineTo(cx + 10, headCY - headR + 2);
      canvas.drawPath(path, crownPaint);
    }

    // Angry brow (one side)
    final browPaint = Paint()..color = Colors.black87..strokeWidth = isBoss ? 2.8 : 2.0..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, headCY - headR * 0.22), Offset(cx + headR * 0.5, headCY - headR * 0.4), browPaint);

    // Glowing eye (one side)
    canvas.drawCircle(Offset(cx + headR * 0.3, headCY), headR * 0.18, Paint()..color = accentColor);

    // ── Front Leg (Right) ─────────────────────────────────
    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(-swing);
    canvas.translate(-hip.dx, -hip.dy);
    canvas.drawLine(hip, Offset(cx, legTop + 22), Paint()..color = const Color(0xFF2A0000)..strokeWidth = legW..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx, legTop + 22), Offset(cx, legTop + 40), Paint()..color = const Color(0xFF1A0000)..strokeWidth = shinW..strokeCap = StrokeCap.round);
    canvas.drawRRect(RRect.fromLTRBR(cx - 8, legTop + 36, cx + 12, legTop + 44, const Radius.circular(4)), Paint()..color = Colors.black);
    canvas.restore();

    // ── Front Arm (Right) ─────────────────────────────────
    if (isPunching) {
      double guardT = 0.0;
      if (punchProgress < 0.25) {
        guardT = punchProgress / 0.25;
      } else if (punchProgress < 0.75) {
        guardT = 1.0;
      } else {
        guardT = (1.0 - punchProgress) / 0.25;
      }

      double extendFactor = 0.0;
      if (punchProgress >= 0.25 && punchProgress <= 0.75) {
        if (punchProgress < 0.50) {
          extendFactor = (punchProgress - 0.25) / 0.25;
        } else {
          extendFactor = (0.75 - punchProgress) / 0.25;
        }
      }

      final frontElbowNormal = Offset(cx, bodyTop + 10 + armReach);
      final frontFistNormal = Offset(cx, bodyTop + 10 + armReach + 16);

      final frontElbowGuard = Offset(cx + (isBoss ? 12 : 8), bodyTop + 4);
      final frontFistGuard = Offset(cx + (isBoss ? 16 : 11), headCY + 6);

      final frontElbowExtended = Offset(cx + armReach * 1.3, bodyTop + 8);
      final frontFistExtended = Offset(cx + armReach * 2.4, bodyTop + 8);

      final guardElbow = Offset.lerp(frontElbowNormal, frontElbowGuard, guardT)!;
      final guardFist = Offset.lerp(frontFistNormal, frontFistGuard, guardT)!;

      final finalElbow = Offset.lerp(guardElbow, frontElbowExtended, extendFactor)!;
      final finalFist = Offset.lerp(guardFist, frontFistExtended, extendFactor)!;

      canvas.drawLine(shoulder, finalElbow, Paint()..color = bodyColor..strokeWidth = upperArmW..strokeCap = StrokeCap.round);
      canvas.drawLine(finalElbow, finalFist, Paint()..color = bodyColor..strokeWidth = forearmW..strokeCap = StrokeCap.round);
      canvas.drawCircle(finalFist, (isBoss ? 7 : 5.5) + 2 * extendFactor, Paint()..color = skinColor);
    } else {
      canvas.save();
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(isWalking ? swing : -idleSway);
      canvas.translate(-shoulder.dx, -shoulder.dy);
      canvas.drawLine(shoulder, Offset(cx, bodyTop + 10 + armReach),
          Paint()..color = bodyColor..strokeWidth = upperArmW..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(cx, bodyTop + 10 + armReach), Offset(cx, bodyTop + 10 + armReach + 16),
          Paint()..color = bodyColor..strokeWidth = forearmW..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(cx, bodyTop + 10 + armReach + 16), isBoss ? 7 : 5.5, Paint()..color = skinColor);
      canvas.restore();
    }

    canvas.restore(); // Restore flip
  }

  @override
  bool shouldRepaint(covariant EnemyPainter old) =>
      old.accentColor != accentColor ||
      old.wasHit != wasHit ||
      old.isBoss != isBoss ||
      (old.chargeValue - chargeValue).abs() > 0.01 ||
      old.walkProgress != walkProgress ||
      old.idleProgress != idleProgress ||
      old.punchProgress != punchProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
void _drawLabel(Canvas canvas, String text, Offset center, Color color, {double fontSize = 8.5}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        shadows: [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 4)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}
