import 'package:flutter/material.dart';

class GhettoBackground extends StatelessWidget {
  final Animation<double> scrollAnimation;
  final double sceneWidth;
  final String backgroundAsset;

  const GhettoBackground({
    super.key,
    required this.scrollAnimation,
    required this.backgroundAsset,
    this.sceneWidth = 900.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFF0F172A), // Fallback color
        ),
        AnimatedBuilder(
          animation: scrollAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-scrollAnimation.value * sceneWidth, 0),
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      backgroundAsset,
                      width: sceneWidth,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      backgroundAsset,
                      width: sceneWidth,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
