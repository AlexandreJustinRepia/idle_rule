import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const LoadingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _controller.forward();
    _simulateLoading();
  }

  void _simulateLoading() async {
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() => _loadingProgress = i / 100);
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 60),
                _buildLoadingBar(),
                const SizedBox(height: 16),
                _buildLoadingText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
            blurRadius: 35,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE24B4A),
                    const Color(0xFF8B0000),
                  ],
                ),
              ),
              child: const Icon(
                Icons.shield,
                size: 60,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'IDLE',
          style: GoogleFonts.bebasNeue(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 8,
          ),
        ),
        Text(
          'RULE',
          style: GoogleFonts.bebasNeue(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE24B4A),
            letterSpacing: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE24B4A), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBar() {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white10,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 200 * _loadingProgress,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: const LinearGradient(
            colors: [Color(0xFFE24B4A), Color(0xFFFF6B6B)],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingText() {
    final messages = [
      'CALIBRATING FIGHT INSTINCTS...',
      'LOADING STREET CRED...',
      'PREPARING YOUR LEGACY...',
    ];

    final messageIndex = (messages.length * _loadingProgress).floor().clamp(0, messages.length - 1);

    return Text(
      messages[messageIndex],
      style: TextStyle(
        fontSize: 10,
        color: Colors.white.withValues(alpha: 0.5),
        letterSpacing: 2,
      ),
    );
  }
}
