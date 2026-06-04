import 'dart:math' as math;
import 'package:flutter/material.dart';

class AsphaltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw base asphalt color
    final paint = Paint()..color = const Color(0xFF0F0F0F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw noise/gravel
    final random = math.Random(42); // fixed seed for consistent texture
    final gravelPaint = Paint()..strokeWidth = 1.0;
    
    for (int i = 0; i < 2000; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      // Randomly pick a grey shade for the gravel
      int grey = 30 + random.nextInt(30);
      gravelPaint.color = Color.fromRGBO(grey, grey, grey, 1.0);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), gravelPaint);
    }
    
    // Draw sidewalk edge
    final edgePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 4.0;
    canvas.drawLine(const Offset(0, 2), Offset(size.width, 2), edgePaint);
    
    // Draw road cracks
    final crackPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.22, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height);
    canvas.drawPath(path, crackPaint);
    
    final path2 = Path();
    path2.moveTo(size.width * 0.7, 0);
    path2.lineTo(size.width * 0.65, size.height * 0.3);
    path2.lineTo(size.width * 0.8, size.height * 0.7);
    path2.lineTo(size.width * 0.75, size.height);
    canvas.drawPath(path2, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GhettoEnvironment extends StatefulWidget {
  const GhettoEnvironment({super.key});

  @override
  State<GhettoEnvironment> createState() => _GhettoEnvironmentState();
}

class _GhettoEnvironmentState extends State<GhettoEnvironment> with SingleTickerProviderStateMixin {
  late AnimationController _punchController;

  @override
  void initState() {
    super.initState();
    _punchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _punchController.dispose();
    super.dispose();
  }

  void _train() {
    _punchController.forward().then((_) => _punchController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A), // Dark night
                Color(0xFF1E293B), // Gloomy grey
                Color(0xFF334155), // Street level
              ],
            ),
          ),
        ),
        
        // Brick Wall Background
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF311518), // Very dark brick red
              border: Border(top: BorderSide(color: Colors.black, width: 6)),
            ),
            child: Stack(
              children: [
                // Fake graffiti
                Positioned(
                  top: 50,
                  left: 40,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: const Text(
                      'S-RANK\nONLY',
                      style: TextStyle(
                        fontFamily: 'Impact',
                        fontSize: 48,
                        color: Colors.white12,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Asphalt ground
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 90,
          child: CustomPaint(
            painter: AsphaltPainter(),
          ),
        ),

        // Street Lamp
        Positioned(
          right: 40,
          bottom: 90,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.9), // Glowing yellow
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 60,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
              ),
            ],
          ),
        ),

        // Dumpster Prop
        Positioned(
          left: 20,
          bottom: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[900], // Dark green dumpster
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 2,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Trash bags
              Icon(Icons.delete_outline, size: 40, color: Colors.grey[800]),
            ],
          ),
        ),

        // Interactive Punching Bag (The "Idle" Tap Target)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: GestureDetector(
              onTap: _train,
              child: AnimatedBuilder(
                animation: _punchController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_punchController.value * 15, 0), // Push back
                    child: Transform.rotate(
                      angle: _punchController.value * 0.15, // Tilt back
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The Bag
                    Container(
                      width: 80,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA12020), // Dark red bag
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'TAP TO\nTRAIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Stand pole
                    Container(
                      width: 12,
                      height: 50,
                      color: Colors.grey[800],
                    ),
                    // Stand base
                    Container(
                      width: 100,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
