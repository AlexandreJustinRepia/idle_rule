import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game_state.dart';

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
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
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
  final PlayerStats stats;
  final int playerHealth;
  final int playerMaxHealth;
  final double playerStamina;
  final double playerMaxStamina;
  final double playerHunger;
  final double playerMaxHunger;
  final void Function({double strength, double speed, double endurance})
  onStatsGained;
  final void Function(int damage) onPlayerDamaged;
  final VoidCallback onPlayerDefeated;
  final VoidCallback onNewEnemyApproached;
  final bool Function(double amount) onStaminaSpent;
  final void Function({double stamina, double hunger}) onNeedsRecovered;

  const GhettoEnvironment({
    super.key,
    required this.stats,
    required this.playerHealth,
    required this.playerMaxHealth,
    required this.playerStamina,
    required this.playerMaxStamina,
    required this.playerHunger,
    required this.playerMaxHunger,
    required this.onStatsGained,
    required this.onPlayerDamaged,
    required this.onPlayerDefeated,
    required this.onNewEnemyApproached,
    required this.onStaminaSpent,
    required this.onNeedsRecovered,
  });

  @override
  State<GhettoEnvironment> createState() => _GhettoEnvironmentState();
}

class _GhettoEnvironmentState extends State<GhettoEnvironment>
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late AnimationController _walkController;
  late AnimationController _attackController;
  late AnimationController _enemyAttackController;
  late AnimationController _deathController;
  final double sceneWidth =
      900.0; // Must be a multiple of 60 for seamless bricks

  bool _isFighting = false;
  bool _isEnemyDying = false;
  bool _enemyWasHit = false;
  bool _playerWasHit = false;
  bool _playerWasDefeated = false;
  int _enemyNumber = 0;
  int _enemyHealth = 0;
  int _enemyMaxHealth = 0;
  Timer? _encounterTimer;
  Timer? _attackTimer;
  Timer? _enemyAttackTimer;
  Timer? _trainingTimer;
  final math.Random _random = math.Random();
  static const double _dodgeStaminaCost = 5;
  static const double _dodgeHungerCost = 2;

  static const List<String> _enemyNames = [
    'THUG',
    'BRAWLER',
    'ENFORCER',
    'RIVAL',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Scroll speed
    );

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Walk cycle speed
    );

    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _enemyAttackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );

    _deathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _startWalking();
  }

  void _startWalking() {
    _encounterTimer?.cancel();
    _attackTimer?.cancel();
    _enemyAttackTimer?.cancel();
    _attackController.stop();
    _attackController.value = 0;
    _enemyAttackController.stop();
    _enemyAttackController.value = 0;
    _deathController.stop();
    _deathController.value = 0;
    setState(() {
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasHit = false;
      _playerWasDefeated = false;
      _enemyHealth = 0;
    });
    _scrollController.repeat();
    _walkController.repeat(reverse: true);
    _trainingTimer?.cancel();
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      widget.onStatsGained(strength: 0, speed: 0.25, endurance: 0);
      widget.onNeedsRecovered(
        stamina: widget.stats.staminaRecovery,
        hunger: -0.45,
      );
    });

    // Spawn the next enemy after a short stretch of walking.
    _encounterTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _startEncounter();
      }
    });
  }

  void _startEncounter() {
    _enemyNumber++;
    _enemyMaxHealth = 5 + ((_enemyNumber - 1) * 2);
    widget.onNewEnemyApproached();

    setState(() {
      _isFighting = true;
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasDefeated = false;
      _enemyHealth = _enemyMaxHealth;
    });

    _scrollController.stop();
    _walkController.value = 0.5; // Neutral pose
    _walkController.stop();
    _trainingTimer?.cancel();

    _schedulePlayerAttack();

    _enemyAttackTimer?.cancel();
    _enemyAttackTimer = Timer.periodic(const Duration(milliseconds: 1250), (_) {
      _enemyAttackPlayer();
    });
  }

  void _schedulePlayerAttack() {
    _attackTimer?.cancel();
    _attackTimer = Timer(widget.stats.attackDelay, () async {
      await _attackEnemy();
      if (mounted && _isFighting) {
        _schedulePlayerAttack();
      }
    });
  }

  Future<void> _attackEnemy() async {
    if (!_isFighting || _attackController.isAnimating) return;

    if (!widget.onStaminaSpent(8)) {
      widget.onStatsGained(strength: 0, speed: 0, endurance: 0.35);
      return;
    }

    await _attackController.forward(from: 0);
    if (!mounted || !_isFighting) return;

    final damage = widget.stats.attackDamage;
    setState(() {
      _enemyHealth -= damage;
      _enemyWasHit = true;
      if (_enemyHealth <= 0) {
        _attackTimer?.cancel();
        _enemyAttackTimer?.cancel();
        _isFighting = false;
        _isEnemyDying = true;
      }
    });
    widget.onStatsGained(strength: 0.65, speed: 0.12, endurance: 0);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _enemyWasHit = false);
      }
    });

    if (_enemyHealth <= 0) {
      await _deathController.forward(from: 0);
      if (mounted) {
        _startWalking(); // Enemy defeated, resume walking to find another one.
      }
    }
  }

  Future<void> _enemyAttackPlayer() async {
    if (!_isFighting || _enemyAttackController.isAnimating || _isEnemyDying) {
      return;
    }

    await _enemyAttackController.forward(from: 0);
    if (!mounted || !_isFighting || _isEnemyDying) return;

    if (_random.nextDouble() < widget.stats.dodgeChance && _payDodgeCost()) {
      widget.onStatsGained(strength: 0, speed: 0.9, endurance: 0);
      setState(() => _playerWasHit = true);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) {
          setState(() => _playerWasHit = false);
        }
      });
      return;
    }

    final damage = 2 + (_enemyNumber / 3).floor();
    final willDefeatPlayer = widget.playerHealth - damage <= 0;
    widget.onPlayerDamaged(damage);
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.8);
    widget.onNeedsRecovered(
      stamina: widget.stats.staminaRecovery * 0.35,
      hunger: -0.25,
    );

    setState(() => _playerWasHit = true);

    if (willDefeatPlayer) {
      _handlePlayerDefeated();
      return;
    }

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() => _playerWasHit = false);
      }
    });
  }

  bool _payDodgeCost() {
    if (widget.onStaminaSpent(_dodgeStaminaCost)) {
      return true;
    }

    if (widget.playerHunger >= _dodgeHungerCost) {
      widget.onNeedsRecovered(stamina: 0, hunger: -_dodgeHungerCost);
      return true;
    }

    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.25);
    return false;
  }

  void _handlePlayerDefeated() {
    _encounterTimer?.cancel();
    _attackTimer?.cancel();
    _enemyAttackTimer?.cancel();
    _trainingTimer?.cancel();

    widget.onPlayerDefeated();

    setState(() {
      _isFighting = false;
      _isEnemyDying = false;
      _playerWasDefeated = true;
      _enemyHealth = _enemyMaxHealth;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isFighting = true;
          _playerWasHit = false;
          _playerWasDefeated = false;
        });
        _schedulePlayerAttack();
        _enemyAttackTimer?.cancel();
        _enemyAttackTimer = Timer.periodic(const Duration(milliseconds: 1250), (
          _,
        ) {
          _enemyAttackPlayer();
        });
      }
    });
  }

  @override
  void dispose() {
    _encounterTimer?.cancel();
    _attackTimer?.cancel();
    _enemyAttackTimer?.cancel();
    _trainingTimer?.cancel();
    _scrollController.dispose();
    _walkController.dispose();
    _attackController.dispose();
    _enemyAttackController.dispose();
    _deathController.dispose();
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
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
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
                    SizedBox(
                      width: sceneWidth,
                      child: const StreetSceneLayer(),
                    ),
                    SizedBox(
                      width: sceneWidth,
                      child: const StreetSceneLayer(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        Positioned(
          top: 88,
          left: 24,
          right: 24,
          child: PlayerHealthBar(
            health: widget.playerHealth,
            maxHealth: widget.playerMaxHealth,
            stamina: widget.playerStamina,
            maxStamina: widget.playerMaxStamina,
            hunger: widget.playerHunger,
            maxHunger: widget.playerMaxHunger,
            wasHit: _playerWasHit,
          ),
        ),

        // Hero Character
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0, left: 60.0),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _walkController,
                _attackController,
                _enemyAttackController,
              ]),
              builder: (context, child) {
                final attackProgress = math.sin(
                  _attackController.value * math.pi,
                );
                final hitShake = _playerWasHit
                    ? math.sin(_enemyAttackController.value * math.pi * 8) * 8
                    : 0.0;
                return Opacity(
                  opacity: _playerWasHit ? 0.72 : 1,
                  child: Transform.translate(
                    offset: Offset(
                      (_isFighting ? attackProgress * 78 : 0) + hitShake,
                      _isFighting
                          ? -attackProgress * 6
                          : -_walkController.value * 12,
                    ),
                    child: Transform.rotate(
                      angle: _isFighting
                          ? attackProgress * 0.18
                          : (_walkController.value - 0.5) * 0.05,
                      child: child,
                    ),
                  ),
                );
              },
              child: const HeroCharacterPlaceholder(),
            ),
          ),
        ),

        // Enemy Character
        if (_isFighting || _isEnemyDying || _playerWasDefeated)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0, right: 60.0),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _attackController,
                  _enemyAttackController,
                  _deathController,
                ]),
                builder: (context, child) {
                  final hitShake = _enemyWasHit
                      ? math.sin(_attackController.value * math.pi * 8) * 8
                      : 0.0;
                  final enemyAttackProgress = math.sin(
                    _enemyAttackController.value * math.pi,
                  );
                  final fallProgress = Curves.easeIn.transform(
                    _deathController.value,
                  );
                  return Opacity(
                    opacity: (1 - fallProgress).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        hitShake - enemyAttackProgress * 58 + fallProgress * 70,
                        -enemyAttackProgress * 5 + fallProgress * 125,
                      ),
                      child: Transform.rotate(
                        angle:
                            -enemyAttackProgress * 0.14 +
                            fallProgress * math.pi / 2.5,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: _attackEnemy,
                  child: EnemyCharacterPlaceholder(
                    health: _enemyHealth,
                    maxHealth: _enemyMaxHealth,
                    name: _enemyNames[(_enemyNumber - 1) % _enemyNames.length],
                    enemyNumber: _enemyNumber,
                    wasHit: _enemyWasHit,
                  ),
                ),
              ),
            ),
          ),

        if (_isEnemyDying || _playerWasDefeated)
          Positioned(
            bottom: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isEnemyDying ? 'ENEMY DEFEATED' : 'RECOVERING',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PlayerHealthBar extends StatelessWidget {
  final int health;
  final int maxHealth;
  final double stamina;
  final double maxStamina;
  final double hunger;
  final double maxHunger;
  final bool wasHit;

  const PlayerHealthBar({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.hunger,
    required this.maxHunger,
    required this.wasHit,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, maxHealth);
    final healthPercent = maxHealth == 0 ? 0.0 : visibleHealth / maxHealth;
    final staminaPercent = maxStamina == 0
        ? 0.0
        : stamina.clamp(0, maxStamina) / maxStamina;
    final hungerPercent = maxHunger == 0
        ? 0.0
        : hunger.clamp(0, maxHunger) / maxHunger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PLAYER',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: healthPercent,
            backgroundColor: Colors.black54,
            valueColor: AlwaysStoppedAnimation<Color>(
              wasHit ? Colors.white : Colors.lightGreenAccent,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'HP: $visibleHealth/$maxHealth',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _buildNeedBar('STAMINA', staminaPercent, Colors.cyanAccent),
        const SizedBox(height: 4),
        _buildNeedBar('HUNGER', hungerPercent, Colors.orangeAccent),
      ],
    );
  }

  Widget _buildNeedBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: value,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(color),
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
            border: Border.all(
              color: Colors.blueAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'HERO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Legs
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 18,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EnemyCharacterPlaceholder extends StatelessWidget {
  final int health;
  final int maxHealth;
  final String name;
  final int enemyNumber;
  final bool wasHit;

  const EnemyCharacterPlaceholder({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.name,
    required this.enemyNumber,
    required this.wasHit,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, maxHealth);
    final healthPercent = maxHealth == 0 ? 0.0 : visibleHealth / maxHealth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Health Bar
        Text(
          '$name #$enemyNumber',
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 92,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: healthPercent,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(
                wasHit ? Colors.white : Colors.redAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'HP: $visibleHealth/$maxHealth',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        // Head
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.red[800],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
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
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'ENEMY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Legs
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 18,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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
                const Positioned(
                  top: 70,
                  left: 60,
                  child: GraffitiText(
                    text: 'S-RANK\nONLY',
                    angle: -0.15,
                    color: Colors.redAccent,
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 380,
                  child: GraffitiText(
                    text: 'IDLE',
                    angle: 0.1,
                    color: Colors.greenAccent,
                    fontSize: 30,
                  ),
                ),
                const Positioned(
                  bottom: 40,
                  right: 150,
                  child: GraffitiText(
                    text: 'LVL 99',
                    angle: -0.05,
                    color: Colors.purpleAccent,
                    fontSize: 24,
                  ),
                ),
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
          child: CustomPaint(painter: AsphaltPainter()),
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
          Expanded(
            child: Container(color: Colors.yellow.withValues(alpha: 0.1)),
          ),
          Container(height: 4, color: Colors.black87),
          Expanded(
            child: Container(color: Colors.yellow.withValues(alpha: 0.1)),
          ),
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
