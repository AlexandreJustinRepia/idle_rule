import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game_state.dart';
import '../ui/player_health_bar.dart';
import '../../logic/player_needs_logic.dart';

enum GymActivity { strength, speed, endurance }

class GymEnvironment extends StatefulWidget {
  final PlayerStats stats;
  final int playerHealth;
  final double playerStamina;
  final double playerHunger;
  final bool hasGang;
  final bool isActive;
  final void Function({double strength, double speed, double endurance})
  onStatsGained;
  final bool Function(double amount) onStaminaSpent;
  final void Function({double stamina, double hunger}) onNeedsRecovered;

  const GymEnvironment({
    super.key,
    required this.stats,
    required this.playerHealth,
    required this.playerStamina,
    required this.playerHunger,
    required this.hasGang,
    required this.isActive,
    required this.onStatsGained,
    required this.onStaminaSpent,
    required this.onNeedsRecovered,
  });

  @override
  State<GymEnvironment> createState() => _GymEnvironmentState();
}

class _GymEnvironmentState extends State<GymEnvironment>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  // --- Strength Minigame ---
  late AnimationController _powerBarController;
  int _strengthStreak = 0;
  static const int _maxStreak = 4;
  // Sweet spot is the centre 28% of the bar
  static const double _sweetLow = 0.36;
  static const double _sweetHigh = 0.64;
  bool _lastRepPerfect = false;
  bool _tapFlash = false;
  // --- End Strength Minigame ---

  GymActivity _currentActivity = GymActivity.strength;
  bool _isTraining = false;
  Timer? _trainingTimer;
  Timer? _passiveTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _powerBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startPassiveTimer();
  }

  void _startPassiveTimer() {
    _passiveTimer?.cancel();
    _passiveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.isActive && !_isTraining) {
        double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(
          widget.playerHunger,
          widget.stats.maxHunger,
        );
        bool isRecovering = widget.playerStamina < widget.stats.maxStamina;
        double hungerDrain = isRecovering ? -0.15 : -0.05;
        widget.onNeedsRecovered(
          stamina: widget.stats.staminaRecovery * 4.0 * recoveryMult,
          hunger: hungerDrain,
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _powerBarController.dispose();
    _trainingTimer?.cancel();
    _passiveTimer?.cancel();
    super.dispose();
  }

  void _toggleTraining() {
    if (_isTraining) {
      _stopTraining();
    } else {
      _startTraining();
    }
  }

  void _startTraining() {
    if (widget.playerHunger <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too starving to train! Buy food.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() {
      _isTraining = true;
      _strengthStreak = 0;
      _lastRepPerfect = false;
    });
    _animController.repeat(reverse: true);

    // Strength is handled by the tap minigame — no periodic timer for it
    if (_currentActivity == GymActivity.strength) {
      // Start the oscillating power bar
      _powerBarController.repeat(reverse: true);
      return;
    }

    // Non-strength activities keep the periodic timer logic
    double staminaCost = 5.0;
    double hungerCost = -1.0;
    double gSpeed = 0;
    double gEndurance = 0;

    switch (_currentActivity) {
      case GymActivity.speed:
        staminaCost = 5.0;
        hungerCost = -1.0;
        gSpeed = 1.2;
        gEndurance = 0.2;
        break;
      case GymActivity.endurance:
        staminaCost = 4.0;
        hungerCost = -0.7;
        gEndurance = 1.2;
        break;
      case GymActivity.strength:
        break;
    }

    _trainingTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
      if (widget.playerHunger <= 0) {
        _stopTraining();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too starving to continue! Buy food.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      if (!widget.onStaminaSpent(staminaCost)) {
        _stopTraining();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too exhausted to continue! Rest or buy food.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      widget.onStatsGained(
        speed: gSpeed,
        endurance: gEndurance,
      );
      widget.onNeedsRecovered(stamina: 0, hunger: hungerCost);
    });
  }

  void _stopTraining() {
    setState(() {
      _isTraining = false;
      _strengthStreak = 0;
      _lastRepPerfect = false;
      _tapFlash = false;
    });
    _animController.stop();
    _powerBarController.stop();
    _trainingTimer?.cancel();
  }

  /// Called when player taps LIFT during strength minigame
  void _onStrengthTap() {
    if (!_isTraining || _currentActivity != GymActivity.strength) return;

    // Check hunger / stamina first
    if (widget.playerHunger <= 0) {
      _stopTraining();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too starving to continue! Buy food.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (!widget.onStaminaSpent(4.0)) {
      _stopTraining();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too exhausted to lift! Rest up.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Evaluate indicator position
    // _powerBarController.value oscillates 0→1→0; mirror it so 0.5 = centre
    final double raw = _powerBarController.value;
    final bool isPerfect = raw >= _sweetLow && raw <= _sweetHigh;

    setState(() {
      _lastRepPerfect = isPerfect;
      _tapFlash = true;
      if (isPerfect) {
        _strengthStreak = (_strengthStreak + 1).clamp(0, _maxStreak);
      } else {
        _strengthStreak = 0;
      }
    });

    // Remove flash after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _tapFlash = false);
    });

    final int mult = (_strengthStreak == 0 ? 1 : _strengthStreak);
    final double baseStrength = 1.8;
    final double baseEndurance = 0.15;

    widget.onStatsGained(
      strength: baseStrength * mult,
      endurance: baseEndurance * mult,
    );
    widget.onNeedsRecovered(stamina: 0, hunger: -0.8);
  }

  void _selectActivity(GymActivity activity) {
    if (_isTraining) {
      _stopTraining();
    }
    setState(() {
      _currentActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color activityColor = Colors.deepOrangeAccent;
    String activityTitle = 'STRENGTH AREA';
    String activityDetails = 'Bench Press';

    if (_currentActivity == GymActivity.speed) {
      activityColor = Colors.cyanAccent;
      activityTitle = 'CARDIO AREA';
      activityDetails = 'Treadmill RUN';
    } else if (_currentActivity == GymActivity.endurance) {
      activityColor = Colors.amberAccent;
      activityTitle = 'COMBAT AREA';
      activityDetails = 'Heavy Punching Bag';
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0F0F12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 112, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOLDSMITH STREET GYM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: activityColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No pain, no gain. Train your attributes.',
                          style: TextStyle(
                            color: Colors.white70.withValues(alpha: 0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PlayerHealthBar(
                  health: widget.playerHealth,
                  maxHealth: widget.stats.maxHealth,
                  stamina: widget.playerStamina,
                  maxStamina: widget.stats.maxStamina,
                  hunger: widget.playerHunger,
                  maxHunger: widget.stats.maxHunger,
                  reputation: widget.stats.reputation,
                  wasHit: false,
                  damage: widget.stats.attackDamage,
                  dodge: (widget.stats.dodgeChance * 100).toInt(),
                  gangCapacity: widget.hasGang ? widget.stats.gangCapacity : 0,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SELECTION TABS
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectorCard(
                          activity: GymActivity.strength,
                          title: 'STRENGTH',
                          subtitle: 'Bench Press',
                          icon: Icons.fitness_center,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectorCard(
                          activity: GymActivity.speed,
                          title: 'SPEED',
                          subtitle: 'Treadmill',
                          icon: Icons.directions_run,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectorCard(
                          activity: GymActivity.endurance,
                          title: 'ENDURANCE',
                          subtitle: 'Heavy Bag',
                          icon: Icons.sports_mma,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ANIMATED AREA CARD
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: activityColor.withValues(alpha: 0.03),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: GridBackgroundPainter(),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  activityTitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedBuilder(
                                  animation: _animController,
                                  builder: (context, child) {
                                    switch (_currentActivity) {
                                      case GymActivity.strength:
                                        return _buildBenchPressAnimation();
                                      case GymActivity.speed:
                                        return _buildTreadmillAnimation();
                                      case GymActivity.endurance:
                                        return _buildPunchingBagAnimation();
                                    }
                                  },
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  activityDetails,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // STRENGTH MINIGAME — only shown when strength is selected
                  if (_currentActivity == GymActivity.strength)
                    _buildStrengthMinigame(),

                  // TRAINING DETAILS
                  _buildDetailsCard(activityColor),
                  const SizedBox(height: 8),

                  // ACTION BUTTON
                  if (_currentActivity != GymActivity.strength ||
                      !_isTraining)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTraining
                            ? Colors.redAccent
                            : activityColor,
                        foregroundColor: Colors.black,
                        elevation: 6,
                        shadowColor: _isTraining
                            ? Colors.redAccent
                            : activityColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _toggleTraining,
                      child: Text(
                        _isTraining ? 'STOP TRAINING' : 'START TRAINING',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthMinigame() {
    final int mult = _strengthStreak == 0 ? 1 : _strengthStreak;
    final Color multColor = mult >= 4
        ? Colors.purpleAccent
        : mult == 3
            ? Colors.orangeAccent
            : mult == 2
                ? Colors.yellowAccent
                : Colors.white70;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Streak display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= _maxStreak; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i <= _strengthStreak
                      ? multColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: i <= _strengthStreak
                        ? multColor
                        : Colors.white12,
                    width: i <= _strengthStreak ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'x$i',
                    style: TextStyle(
                      color: i <= _strengthStreak ? multColor : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Power bar
        AnimatedBuilder(
          animation: _powerBarController,
          builder: (context, _) {
            final double pos = _powerBarController.value;
            return LayoutBuilder(
              builder: (context, constraints) {
                final double barWidth = constraints.maxWidth;
                return Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.deepOrangeAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Sweet-spot zone
                      Positioned(
                        left: barWidth * _sweetLow,
                        width: barWidth * (_sweetHigh - _sweetLow),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.18),
                            border: Border.symmetric(
                              vertical: BorderSide(
                                color: Colors.greenAccent.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Moving indicator
                      Positioned(
                        left: (pos * (barWidth - 6)).clamp(
                            0, barWidth - 6),
                        top: 4,
                        bottom: 4,
                        width: 6,
                        child: AnimatedContainer(
                          duration: Duration.zero,
                          decoration: BoxDecoration(
                            color: _tapFlash
                                ? (_lastRepPerfect
                                    ? Colors.greenAccent
                                    : Colors.redAccent)
                                : Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: (_tapFlash && _lastRepPerfect
                                        ? Colors.greenAccent
                                        : Colors.deepOrangeAccent)
                                    .withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // PERFECT label in sweet spot
                      Center(
                        child: Text(
                          'PERFECT',
                          style: TextStyle(
                            color:
                                Colors.greenAccent.withValues(alpha: 0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),

        // Hint text
        Text(
          _isTraining
              ? (_lastRepPerfect
                  ? '✓ Perfect rep! x$mult multiplier'
                  : _strengthStreak == 0
                      ? 'Tap LIFT when the bar hits the green zone!'
                      : 'Keep it up! x$mult active')
              : 'Press START TRAINING then tap LIFT!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _lastRepPerfect
                ? Colors.greenAccent
                : Colors.white38,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),

        // LIFT button — only shown while training
        if (_isTraining)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _onStrengthTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _tapFlash && _lastRepPerfect
                          ? Colors.greenAccent.withValues(alpha: 0.2)
                          : Colors.deepOrangeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tapFlash && _lastRepPerfect
                            ? Colors.greenAccent
                            : Colors.deepOrangeAccent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrangeAccent.withValues(
                              alpha: _tapFlash ? 0.4 : 0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LIFT!',
                          style: TextStyle(
                            color: _tapFlash && _lastRepPerfect
                                ? Colors.greenAccent
                                : Colors.deepOrangeAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (mult > 1)
                          Text(
                            'x$mult MULTIPLIER',
                            style: TextStyle(
                              color: multColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _stopTraining,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: const Text(
                    'STOP',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSelectorCard({
    required GymActivity activity,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _currentActivity == activity;

    return GestureDetector(
      onTap: () => _selectActivity(activity),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : const Color(0xFF16161C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white70.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? color.withValues(alpha: 0.8)
                    : Colors.white30,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Color color) {
    double staminaVal = 4.0;
    double hungerVal = 0.8;
    String gainsText = '+1.2 Strength\n+0.1 Endurance';

    if (_currentActivity == GymActivity.speed) {
      staminaVal = 5.0;
      hungerVal = 1.0;
      gainsText = '+1.2 Speed\n+0.2 Endurance';
    } else if (_currentActivity == GymActivity.endurance) {
      staminaVal = 4.0;
      hungerVal = 0.7;
      gainsText = '+1.2 Endurance\n+0.2 Strength';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRAINING BENEFITS',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gainsText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COST / SECOND',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.cyanAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '-${staminaVal.toStringAsFixed(1)} Stamina',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    color: Colors.orangeAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '-${hungerVal.toStringAsFixed(1)} Hunger',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // ANIMATION BUILDERS
  // ----------------------------------------------------

  Widget _buildBenchPressAnimation() {
    final double yOffset = _animController.value * 20.0;
    return SizedBox(
      height: 90,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bench support
          Positioned(
            bottom: 5,
            child: Container(
              width: 110,
              height: 8,
              color: const Color(0xFF212121),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 10,
              height: 12,
              color: const Color(0xFF424242),
            ),
          ),
          // Hero Character lying down
          Positioned(
            bottom: 8,
            child: Transform.rotate(
              angle: math.pi / 2,
              child: Container(
                width: 20,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.deepOrangeAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.deepOrangeAccent,
                  size: 14,
                ),
              ),
            ),
          ),
          // Barbell
          Positioned(
            top: 15 + yOffset,
            child: Container(
              width: 150,
              height: 3,
              color: const Color(0xFFBDBDBD),
            ),
          ),
          // Weight Plates Left
          Positioned(top: 7 + yOffset, left: 15, child: _buildBarbellWeight()),
          // Weight Plates Right
          Positioned(top: 7 + yOffset, right: 15, child: _buildBarbellWeight()),
        ],
      ),
    );
  }

  Widget _buildBarbellWeight() {
    return Container(
      width: 6,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white12),
      ),
    );
  }

  Widget _buildTreadmillAnimation() {
    final double runOffset = _isTraining
        ? math.sin(_animController.value * math.pi * 2) * 4.0
        : 0.0;
    final double speedLineWidth = _isTraining
        ? (_animController.value * 50)
        : 0.0;

    return SizedBox(
      height: 90,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Treadmill Base
          Positioned(
            bottom: 5,
            child: Container(
              width: 150,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 35,
            child: Container(
              width: 4,
              height: 25,
              color: const Color(0xFF424242),
            ),
          ),
          Positioned(
            bottom: 35,
            left: 35,
            child: Container(
              width: 20,
              height: 4,
              color: const Color(0xFF616161),
            ),
          ),
          // Runner (Hero)
          Positioned(
            bottom: 12,
            left: 75 + runOffset,
            child: Container(
              width: 24,
              height: 50,
              decoration: BoxDecoration(
                color: _isTraining
                    ? Colors.cyanAccent.withValues(alpha: 0.1)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.directions_run,
                color: Colors.cyanAccent,
                size: 18,
              ),
            ),
          ),
          if (_isTraining) ...[
            Positioned(
              bottom: 25,
              right: 25,
              child: Container(
                width: speedLineWidth,
                height: 1.5,
                color: Colors.cyanAccent.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPunchingBagAnimation() {
    final double swayAngle = _isTraining
        ? math.sin(_animController.value * math.pi * 2) * 0.12
        : 0.0;

    return SizedBox(
      height: 90,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stand Frame
          Positioned(
            top: 0,
            child: Container(
              width: 80,
              height: 4,
              color: const Color(0xFF424242),
            ),
          ),
          Positioned(
            top: 0,
            left: 60,
            child: Container(
              width: 4,
              height: 90,
              color: const Color(0xFF212121),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 30,
            child: Container(
              width: 80,
              height: 6,
              color: const Color(0xFF424242),
            ),
          ),

          // Swaying Heavy Bag
          Positioned(
            top: 4,
            left: 60,
            child: Transform.rotate(
              angle: swayAngle,
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(left: -10),
                width: 18,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 1.5, color: Colors.amberAccent),
                    const Text(
                      'MMA',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(height: 1.5, color: Colors.amberAccent),
                  ],
                ),
              ),
            ),
          ),

          // Fighter
          Positioned(
            bottom: 8,
            left: 45,
            child: Opacity(
              opacity: _isTraining ? 1.0 : 0.4,
              child: Container(
                width: 20,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.sports_mma,
                  color: Colors.amberAccent,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;

    const double step = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
