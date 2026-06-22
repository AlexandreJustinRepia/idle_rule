import 'dart:math' as math;
import 'package:flutter/material.dart';

class TravelAnimationOverlay extends StatefulWidget {
  final String streetName;
  final bool isTaxi;
  final VoidCallback onComplete;

  const TravelAnimationOverlay({
    super.key,
    required this.streetName,
    required this.isTaxi,
    required this.onComplete,
  });

  @override
  State<TravelAnimationOverlay> createState() => _TravelAnimationOverlayState();
}

class _TravelAnimationOverlayState extends State<TravelAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _bobAnimation;
  late Animation<double> _roadOffsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.isTaxi ? const Duration(milliseconds: 1600) : const Duration(milliseconds: 2600);
    _controller = AnimationController(duration: duration, vsync: this);

    // Slide across screen
    _slideAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.9, curve: Curves.easeInOut)),
    );

    // Bobbing/Footsteps for walk or engine rattle for taxi
    _bobAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.9, curve: _BobbingCurve()),
      ),
    );

    // Infinite road lines moving backwards
    _roadOffsetAnimation = Tween<double>(begin: 0.0, end: widget.isTaxi ? 8.0 : 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Full screen entry/exit fades
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (_fadeAnimation.value == 0.0) return const SizedBox.shrink();
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.black.withValues(alpha: 0.92),
            child: Stack(
              children: [
                // Moving Background Dust / Speed lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParallaxStarsPainter(
                      progress: _roadOffsetAnimation.value,
                      isTaxi: widget.isTaxi,
                    ),
                  ),
                ),
                
                // Content Center
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing Status Text
                      _buildPulsingText(),
                      const SizedBox(height: 80),

                      // Animation Track Area
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Ground/Road Line
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 25,
                              child: CustomPaint(
                                size: const Size(double.infinity, 8),
                                painter: _RoadPainter(
                                  dashOffset: _roadOffsetAnimation.value * 20,
                                ),
                              ),
                            ),

                            // Traveling Entity (Walker / Cab)
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Positioned(
                                  left: MediaQuery.of(context).size.width * _slideAnimation.value - 30,
                                  bottom: 28 + _bobAnimation.value,
                                  child: _buildTravelerWidget(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingText() {
    final title = widget.isTaxi ? 'TAXI RIDE' : 'WALKING';
    final subtitle = widget.isTaxi
        ? 'CRUISING TO ${widget.streetName.toUpperCase()}...'
        : 'HEADING TO ${widget.streetName.toUpperCase()}...';
    
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFFFD166),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelerWidget() {
    if (widget.isTaxi) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00), // Taxi Yellow
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.local_taxi,
          color: Colors.black,
          size: 32,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE24B4A), // Alert Red
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_walk,
          color: Colors.white,
          size: 28,
        ),
      );
    }
  }
}

class _BobbingCurve extends Curve {
  const _BobbingCurve();

  @override
  double transformInternal(double t) {
    // Generates a clean sine oscillation (bobbing)
    return math.sin(t * math.pi * 12);
  }
}

class _RoadPainter extends CustomPainter {
  final double dashOffset;

  _RoadPainter({required this.dashOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw main solid ground line
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);

    // Draw dashed marker line
    final dashPaint = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    double x = -(dashOffset % 30);
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height - 4),
        Offset(x + 12, size.height - 4),
        dashPaint,
      );
      x += 30;
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) => oldDelegate.dashOffset != dashOffset;
}

class _ParallaxStarsPainter extends CustomPainter {
  final double progress;
  final bool isTaxi;

  _ParallaxStarsPainter({required this.progress, required this.isTaxi});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10;

    final count = isTaxi ? 45 : 15;
    final speedMultiplier = isTaxi ? 6.0 : 1.5;
    final length = isTaxi ? 25.0 : 4.0;

    // Seeded pseudo-random placement
    for (int i = 0; i < count; i++) {
      final y = (math.sin(i * 9.8) * 0.5 + 0.5) * size.height;
      final speedFactor = (math.cos(i * 1.5) * 0.4 + 0.6);
      
      // Horizontal motion
      double x = (math.sin(i * 2.3) * 0.5 + 0.5) * size.width;
      x -= progress * 50 * speedMultiplier * speedFactor;
      x = x % (size.width + 100) - 50;

      if (isTaxi) {
        // Draw speed streaks
        canvas.drawLine(
          Offset(x, y),
          Offset(x + length * speedFactor, y),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.04 + 0.03 * speedFactor)
            ..strokeWidth = 1.5,
        );
      } else {
        // Draw slow dust particles
        canvas.drawCircle(Offset(x, y), 1.5 * speedFactor, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParallaxStarsPainter oldDelegate) => oldDelegate.progress != progress;
}
