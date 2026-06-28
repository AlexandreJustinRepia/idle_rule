import 'package:flutter/material.dart';

class CinematicSlamOverlay extends StatelessWidget {
  final Animation<double> animation;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color accentColor;
  final bool isDark;

  const CinematicSlamOverlay({
    super.key,
    required this.animation,
    required this.title,
    this.subtitle = "",
    this.titleColor = Colors.white,
    this.accentColor = Colors.redAccent,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          
          double slam = 0;
          double opacity = 0;
          
          // Animation timing: 0.0-0.3 Slam, 0.3-0.7 Hold, 0.7-1.0 Fade
          if (progress < 0.3) {
            double p = progress / 0.3;
            slam = 1.0 - p;
            opacity = p;
          } else if (progress < 0.7) {
            slam = 0;
            opacity = 1.0;
          } else {
            opacity = (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);
          }

          final scale = 1.0 + (slam * 5.0);
          final blur = slam * 20.0;

          return Container(
            color: Colors.black.withValues(alpha: opacity * (isDark ? 0.8 : 0.4)),
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle.toUpperCase(),
                          style: TextStyle(
                            color: titleColor.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            shadows: [Shadow(color: Colors.black, blurRadius: blur)],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 8
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 3,
                        width: 250,
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent, 
                              accentColor.withValues(alpha: opacity), 
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
