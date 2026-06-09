import 'package:flutter/material.dart';
import '../shared/street_scene_layer.dart';

class GhettoBackground extends StatelessWidget {
  final Animation<double> scrollAnimation;
  final double sceneWidth;

  const GhettoBackground({
    super.key,
    required this.scrollAnimation,
    this.sceneWidth = 900.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
          ),
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
                    SizedBox(width: sceneWidth, child: const StreetSceneLayer()),
                    SizedBox(width: sceneWidth, child: const StreetSceneLayer()),
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
