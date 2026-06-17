import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/character_class.dart';

class ClassGachaView extends StatefulWidget {
  final ValueChanged<CharacterClass> onRollComplete;

  const ClassGachaView({
    super.key,
    required this.onRollComplete,
  });

  @override
  State<ClassGachaView> createState() => _ClassGachaViewState();
}

class _ClassGachaViewState extends State<ClassGachaView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _revealAnimation;
  
  final Random _random = Random();
  int _currentIndex = 0;
  CharacterClass? _finalClass;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    );

    _controller.forward();
    _startRolling();
  }

  void _startRolling() {
    const rollDuration = Duration(milliseconds: 60);
    var rollCount = 0;
    const maxRolls = 30;

    Future.doWhile(() async {
      if (rollCount >= maxRolls) return false;
      
      await Future.delayed(rollDuration);
      if (!_isMounted) return false;
      setState(() => _currentIndex = _random.nextInt(CharacterClasses.allClasses.length));
      rollCount++;
      return true;
    }).then((_) {
      _finalizeRoll();
    });
  }

  void _finalizeRoll() async {
    final charClass = CharacterClasses.rollClass(_random);
    _finalClass = charClass;

    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!_isMounted) return;
    setState(() => _finalClass = charClass);
    _revealController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!_isMounted) return;
    widget.onRollComplete(charClass);
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finalClass == null) {
      return _buildRollingView();
    }
    return _buildRevealView();
  }

  Widget _buildRollingView() {
    final charClass = CharacterClasses.allClasses[_currentIndex];
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.3, end: 1.2).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rotate only the emblem circle, not the whole page
                Transform.rotate(
                  angle: _rotationAnimation.value * 2 * pi,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: charClass.tierColor.withValues(alpha: 0.8),
                        width: 3,
                      ),
                      color: charClass.tierColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        charClass.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'ROLLING...',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 28,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white10,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _controller.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        gradient: LinearGradient(
                          colors: [Color(0xFFE24B4A), Color(0xFFFF6B6B)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealView() {
    final charClass = _finalClass!;
    final tierLabel = CharacterClasses.getTierLabel(charClass);

    return Center(
      child: FadeTransition(
        opacity: _revealAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: charClass.tierColor, width: 1.5),
                  color: charClass.tierColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  'TIER $tierLabel',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: charClass.tierColor,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      charClass.tierColor.withValues(alpha: 0.3),
                      charClass.tierColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(color: charClass.tierColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: charClass.glowColor.withValues(alpha: 0.6),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    charClass.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                charClass.name.toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: charClass.tierColor,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                charClass.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
