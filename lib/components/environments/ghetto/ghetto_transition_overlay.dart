import 'package:flutter/material.dart';

class GhettoTransitionOverlay extends StatelessWidget {
  final Animation<double> animation;

  const GhettoTransitionOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final val = animation.value;
        return Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: (val * 2.0).clamp(0.0, 1.0)),
            child: Center(
              child: Opacity(
                opacity: (val * 4.0).clamp(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.door_front_door, size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    const Text(
                      "LEAVING SAFE HOUSE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
