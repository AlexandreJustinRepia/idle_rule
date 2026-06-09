import 'dart:math' as math;
import 'package:flutter/material.dart';

class AsphaltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F0F0F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final random = math.Random(42); 
    final gravelPaint = Paint()..strokeWidth = 1.0;

    for (int i = 0; i < 1500; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      int grey = 30 + random.nextInt(30);
      gravelPaint.color = Color.fromRGBO(grey, grey, grey, 1.0);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), gravelPaint);
    }

    final edgePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3.0;
    canvas.drawLine(const Offset(0, 1.5), Offset(size.width, 1.5), edgePaint);

    final crackPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.22, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height);
    canvas.drawPath(path, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrickWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A1114);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final mortarPaint = Paint()
      ..color = const Color(0xFF150A0B)
      ..strokeWidth = 1.5;

    final int rows = 12;
    final double rowHeight = size.height / rows;
    final double brickWidth = 45.0; 

    for (int i = 0; i <= rows; i++) {
      double y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), mortarPaint);

      double offset = (i % 2 == 0) ? 0 : brickWidth / 2;
      for (double x = offset; x < size.width; x += brickWidth) {
        canvas.drawLine(Offset(x, y), Offset(x, y + rowHeight), mortarPaint);
      }
    }

    final random = math.Random(123);
    final grungePaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
    for (int i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        8 + random.nextDouble() * 20,
        grungePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GymBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;

    // Draw grid
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
