import 'dart:async';
import 'package:flutter/material.dart';
import '../../game_state.dart';
import 'shared/environment_painters.dart';

class GymEnvironment extends StatefulWidget {
  final PlayerStats stats;
  final double playerStamina;
  final double playerHunger;
  final void Function({double strength, double speed, double endurance}) onStatsGained;
  final bool Function(double amount) onStaminaSpent;
  final void Function({double stamina, double hunger}) onNeedsRecovered;

  const GymEnvironment({
    super.key,
    required this.stats,
    required this.playerStamina,
    required this.playerHunger,
    required this.onStatsGained,
    required this.onStaminaSpent,
    required this.onNeedsRecovered,
  });

  @override
  State<GymEnvironment> createState() => _GymEnvironmentState();
}

class _GymEnvironmentState extends State<GymEnvironment> with TickerProviderStateMixin {
  late AnimationController _benchController;
  bool _isTraining = false;
  Timer? _trainingTimer;

  @override
  void initState() {
    super.initState();
    _benchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _benchController.dispose();
    _trainingTimer?.cancel();
    super.dispose();
  }

  void _toggleStrengthTraining() {
    if (_isTraining) {
      _stopTraining();
    } else {
      _startTraining();
    }
  }

  void _startTraining() {
    setState(() => _isTraining = true);
    _benchController.repeat(reverse: true);
    _trainingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!widget.onStaminaSpent(4)) {
        _stopTraining();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Too tired to lift!'), duration: Duration(seconds: 1)),
        );
        return;
      }
      widget.onStatsGained(strength: 1.2, speed: 0, endurance: 0.1);
      widget.onNeedsRecovered(stamina: 0, hunger: -0.8);
    });
  }

  void _stopTraining() {
    setState(() => _isTraining = false);
    _benchController.stop();
    _trainingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Stack(
        children: [
          // Gym Background elements
          Positioned.fill(
            child: CustomPaint(
              painter: GymBackgroundPainter(),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'STRENGTH AREA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Animated Bench Press Character
                AnimatedBuilder(
                  animation: _benchController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_benchController.value * 20),
                      child: const BenchPressWidget(),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                GestureDetector(
                  onTap: _toggleStrengthTraining,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: _isTraining ? Colors.redAccent : Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (_isTraining ? Colors.redAccent : Colors.orangeAccent).withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _isTraining ? 'STOP LIFTING' : 'BENCH PRESS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BenchPressWidget extends StatelessWidget {
  const BenchPressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Barbell
          Positioned(
            top: 20,
            child: Container(
              width: 180,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          // Weights
          Positioned(
            top: 5,
            left: 0,
            child: _buildWeight(),
          ),
          Positioned(
            top: 5,
            right: 0,
            child: _buildWeight(),
          ),
          // Bench
          Positioned(
            bottom: 0,
            child: Container(
              width: 120,
              height: 40,
              color: Colors.black87,
            ),
          ),
          // Hero
          Positioned(
            bottom: 30,
            child: Container(
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('HERO', style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeight() {
    return Container(
      width: 20,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
    );
  }
}
