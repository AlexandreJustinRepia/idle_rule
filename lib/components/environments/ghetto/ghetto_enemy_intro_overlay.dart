import 'package:flutter/material.dart';
import '../../ui/cinematic_slam_overlay.dart';

class GhettoEnemyIntroOverlay extends StatelessWidget {
  final Animation<double> animation;
  final String enemyName;

  const GhettoEnemyIntroOverlay({
    super.key,
    required this.animation,
    required this.enemyName,
  });

  @override
  Widget build(BuildContext context) {
    return CinematicSlamOverlay(
      animation: animation,
      title: enemyName,
      subtitle: "Ghetto District",
    );
  }
}
