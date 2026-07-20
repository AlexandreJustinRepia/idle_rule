import 'package:flutter/material.dart';

class GhettoSafeHouseOverlay extends StatelessWidget {
  const GhettoSafeHouseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF101215),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF171A20), Color(0xFF0C0D10)],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF1A1714)),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_rounded,
                    size: 100,
                    color: Colors.blueAccent.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SAFE HOUSE",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Resting & recovering...",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
