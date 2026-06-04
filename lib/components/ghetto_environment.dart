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

class BrickWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base color
    final paint = Paint()..color = const Color(0xFF2A1114);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw bricks
    final mortarPaint = Paint()
      ..color = const Color(0xFF150A0B)
      ..strokeWidth = 2.0;
    
    final int rows = 12;
    final double rowHeight = size.height / rows;
    final double brickWidth = 60.0;
    
    for (int i = 0; i <= rows; i++) {
      double y = i * rowHeight;
      // horizontal mortar line
      canvas.drawLine(Offset(0, y), Offset(size.width, y), mortarPaint);
      
      // vertical mortar lines
      double offset = (i % 2 == 0) ? 0 : brickWidth / 2;
      for (double x = offset; x < size.width; x += brickWidth) {
        canvas.drawLine(Offset(x, y), Offset(x, y + rowHeight), mortarPaint);
      }
    }

    // Add some random grunge/dark spots
    final random = math.Random(123);
    final grungePaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        10 + random.nextDouble() * 30,
        grungePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    this.fontSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Stack(
        children: [
          // Shadow/3D effect
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Impact',
              fontSize: fontSize,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          // Main color with blur
          Positioned(
            left: -2,
            top: -2,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Impact',
                fontSize: fontSize,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GhettoEnvironment extends StatefulWidget {
  const GhettoEnvironment({super.key});

  @override
  State<GhettoEnvironment> createState() => _GhettoEnvironmentState();
}

class _GhettoEnvironmentState extends State<GhettoEnvironment> with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late AnimationController _walkController;
  final double sceneWidth = 900.0; // Must be a multiple of 60 for seamless bricks

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Scroll speed
    )..repeat();

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Walk cycle speed
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky Gradient (Static Background)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF334155),
              ],
            ),
          ),
        ),

        // Scrolling Environment Layer
        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-_scrollController.value * sceneWidth, 0),
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

        // Walking Character Placeholder (Center)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: AnimatedBuilder(
              animation: _walkController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_walkController.value * 12),
                  child: Transform.rotate(
                    angle: (_walkController.value - 0.5) * 0.05,
                    child: child,
                  ),
                );
              },
              child: const HeroCharacterPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }
}

class HeroCharacterPlaceholder extends StatelessWidget {
  const HeroCharacterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing aura / Head
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Body
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text('HERO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        ),
        const SizedBox(height: 4),
        // Legs
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 18, height: 35, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 12),
            Container(width: 18, height: 35, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ],
    );
  }
}

class StreetSceneLayer extends StatelessWidget {
  const StreetSceneLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Brick Wall
        Positioned(
          bottom: 90, // Sit exactly on asphalt
          left: 0,
          right: 0,
          height: 250,
          child: CustomPaint(
            painter: BrickWallPainter(),
            child: Stack(
              children: [
                // Windows
                Positioned(top: 20, right: 80, child: _buildWindow()),
                Positioned(top: 80, left: 300, child: _buildWindow()),
                
                // Pipes
                Positioned(left: 30, top: 0, bottom: 0, child: _buildPipes()),
                Positioned(left: 500, top: 0, bottom: 0, child: _buildPipes()),
                
                // Graffiti
                const Positioned(top: 70, left: 60, child: GraffitiText(text: 'S-RANK\nONLY', angle: -0.15, color: Colors.redAccent)),
                const Positioned(top: 40, left: 380, child: GraffitiText(text: 'IDLE', angle: 0.1, color: Colors.greenAccent, fontSize: 30)),
                const Positioned(bottom: 40, right: 150, child: GraffitiText(text: 'LVL 99', angle: -0.05, color: Colors.purpleAccent, fontSize: 24)),
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

        // Props (Street Lamp, Dumpster) spread out across 900 width
        Positioned(right: 100, bottom: 90, child: _buildStreetLamp()),
        Positioned(left: 120, bottom: 80, child: _buildDumpster()),
        Positioned(left: 600, bottom: 90, child: _buildStreetLamp()),
      ],
    );
  }

  Widget _buildWindow() {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.black87, width: 4),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
          Container(height: 4, color: Colors.black87),
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _buildPipes() {
    return Container(
      width: 15,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          left: BorderSide(color: Colors.black54, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  Widget _buildStreetLamp() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.9),
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
    );
  }

  Widget _buildDumpster() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Container(width: 80, height: 2, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.delete_outline, size: 40, color: Colors.grey[800]),
      ],
    );
  }
}
