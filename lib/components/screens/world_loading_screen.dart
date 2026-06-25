import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorldLoadingScreen extends StatefulWidget {
  final String worldName;
  final bool isGenerating;
  final VoidCallback onComplete;

  const WorldLoadingScreen({
    super.key,
    required this.worldName,
    required this.isGenerating,
    required this.onComplete,
  });

  @override
  State<WorldLoadingScreen> createState() => _WorldLoadingScreenState();
}

class _WorldLoadingScreenState extends State<WorldLoadingScreen> {
  double _progress = 0;
  Timer? _timer;

  List<String> get _messages => widget.isGenerating
      ? const [
          'DRAWING COUNTRY BORDERS...',
          'SPLITTING REGIONS...',
          'BUILDING PROVINCES...',
          'LIGHTING UP CITIES...',
          'MARKING TOWNS...',
          'LAYING DOWN STREETS...',
        ]
      : const [
          'FINDING SAVED COUNTRY...',
          'LOADING TURF MAP...',
          'ENTERING STREETS...',
        ];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    final step = widget.isGenerating ? 0.04 : 0.1;
    final tick = widget.isGenerating
        ? const Duration(milliseconds: 90)
        : const Duration(milliseconds: 55);

    _timer = Timer.periodic(tick, (timer) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + step).clamp(0.0, 1.0);
      });

      if (_progress >= 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 220), () {
          if (mounted) widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageIndex = (_messages.length * _progress).floor().clamp(
      0,
      _messages.length - 1,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  widget.isGenerating ? Icons.public : Icons.map,
                  color: const Color(0xFFE24B4A),
                  size: 62,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isGenerating ? 'GENERATING WORLD' : 'LOADING WORLD',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: 34,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.worldName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE24B4A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE24B4A),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _messages[messageIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_progress * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
