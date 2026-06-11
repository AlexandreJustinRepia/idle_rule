import 'package:flutter/material.dart';

class GhettoSafeHouseOverlay extends StatelessWidget {
  const GhettoSafeHouseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF121212),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_rounded,
                size: 100,
                color: Colors.blueAccent.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
              Text(
                "SAFE HOUSE",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
