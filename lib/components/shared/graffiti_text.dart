import 'package:flutter/material.dart';

class GraffitiText extends StatelessWidget {
  final String text;
  final double angle;
  final Color color;
  final double fontSize;

  const GraffitiText({
    super.key,
    required this.text,
    required this.angle,
    required this.color,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Stack(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Impact',
              fontSize: fontSize,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Positioned(
            left: -1.5,
            top: -1.5,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Impact',
                fontSize: fontSize,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
