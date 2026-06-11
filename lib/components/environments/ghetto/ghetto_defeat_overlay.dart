import 'package:flutter/material.dart';
import '../../ui/cinematic_slam_overlay.dart';

class GhettoDefeatOverlay extends StatelessWidget {
  final Animation<double> animation;

  const GhettoDefeatOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return CinematicSlamOverlay(
      animation: animation,
      title: "Washed Out",
      subtitle: "Ghetto District",
      titleColor: Colors.red,
      accentColor: Colors.black,
    );
  }
}
