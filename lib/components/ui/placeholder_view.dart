import 'package:flutter/material.dart';

class PlaceholderView extends StatelessWidget {
  final String title;

  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.red.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            '$title COMING SOON',
            style: TextStyle(
              color: Colors.red.withValues(alpha: 0.3),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 100,
            color: Colors.red.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
