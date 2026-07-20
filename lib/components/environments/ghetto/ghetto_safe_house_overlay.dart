import 'package:flutter/material.dart';

class GhettoSafeHouseOverlay extends StatelessWidget {
  const GhettoSafeHouseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0x66121212),
        child: Center(
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
      ),
    );
  }
}
