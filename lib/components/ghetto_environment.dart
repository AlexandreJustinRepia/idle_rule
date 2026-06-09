import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game_state.dart';

class AsphaltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F0F0F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final random = math.Random(42); 
    final gravelPaint = Paint()..strokeWidth = 1.0;

    for (int i = 0; i < 1500; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      int grey = 30 + random.nextInt(30);
      gravelPaint.color = Color.fromRGBO(grey, grey, grey, 1.0);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), gravelPaint);
    }

    final edgePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3.0;
    canvas.drawLine(const Offset(0, 1.5), Offset(size.width, 1.5), edgePaint);

    final crackPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.22, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height);
    canvas.drawPath(path, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrickWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A1114);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final mortarPaint = Paint()
      ..color = const Color(0xFF150A0B)
      ..strokeWidth = 1.5;

    final int rows = 12;
    final double rowHeight = size.height / rows;
    final double brickWidth = 45.0; 

    for (int i = 0; i <= rows; i++) {
      double y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), mortarPaint);

      double offset = (i % 2 == 0) ? 0 : brickWidth / 2;
      for (double x = offset; x < size.width; x += brickWidth) {
        canvas.drawLine(Offset(x, y), Offset(x, y + rowHeight), mortarPaint);
      }
    }

    final random = math.Random(123);
    final grungePaint = Paint()..color = Colors.black.withValues(alpha: 0.25);
    for (int i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        8 + random.nextDouble() * 20,
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
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Stack(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Impact',
              fontSize: fontSize,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Positioned(
            left: -1.5,
            top: -1.5,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Impact',
                fontSize: fontSize,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
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
  final void Function({double strength, double speed, double endurance}) onStatsGained;
  final void Function(int damage) onPlayerDamaged;
  final VoidCallback onPlayerDefeated;
  final VoidCallback onNewEnemyApproached;
  final bool Function(double amount) onStaminaSpent;
  final void Function({double stamina, double hunger}) onNeedsRecovered;
  final Boss? activeBoss;
  final VoidCallback? onBossDefeated;

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
    this.activeBoss,
    this.onBossDefeated,
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
  late AnimationController _encounterProgressController;
  late AnimationController _enemyChargeController;

  final double sceneWidth = 900.0; 

  bool _isFighting = false;
  bool _isEnemyDying = false;
  bool _enemyWasHit = false;
  bool _playerWasHit = false;
  bool _playerWasDefeated = false;
  bool _playerMissed = false;
  int _enemyNumber = 0;
  int _enemyHealth = 0;
  Enemy? _currentEnemy;
  Timer? _attackTimer;
  Timer? _enemyAttackTimer;
  Timer? _trainingTimer;
  final math.Random _random = math.Random();
  static const double _dodgeStaminaCost = 5;
  static const double _dodgeHungerCost = 2;

  double get _hungerRatio => widget.playerMaxHunger > 0 ? widget.playerHunger / widget.playerMaxHunger : 0;
  bool get _isLowHunger => _hungerRatio < 0.25;
  bool get _isCriticalHunger => _hungerRatio < 0.10;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _walkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _attackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _enemyAttackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _deathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    
    _encounterProgressController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _enemyChargeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

    _startWalking();
  }

  @override
  void didUpdateWidget(GhettoEnvironment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeBoss != null && oldWidget.activeBoss == null) {
      _startBossEncounter();
    }
  }

  void _startBossEncounter() {
    _encounterProgressController.stop();
    _startEncounter(isBoss: true);
  }

  void _startWalking() {
    _attackTimer?.cancel();
    _enemyAttackTimer?.cancel();
    _attackController.stop();
    _attackController.value = 0;
    _enemyAttackController.stop();
    _enemyAttackController.value = 0;
    _deathController.stop();
    _deathController.value = 0;
    _enemyChargeController.stop();
    _enemyChargeController.value = 0;

    setState(() {
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasHit = false;
      _playerWasDefeated = false;
      _playerMissed = false;
      _enemyHealth = 0;
      _isFighting = false;
      _currentEnemy = null;
    });

    _scrollController.repeat();
    _walkController.repeat(reverse: true);
    _trainingTimer?.cancel();
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      widget.onStatsGained(strength: 0, speed: 0.25, endurance: 0);
      
      double recovery = widget.stats.staminaRecovery;
      if (_isLowHunger) recovery *= 0.5;
      
      widget.onNeedsRecovered(stamina: recovery, hunger: -0.45);
    });

    _encounterProgressController.forward(from: 0).then((_) {
      if (mounted && widget.activeBoss == null && !_isFighting) {
        _startEncounter();
      }
    });
  }

  void _startEncounter({bool isBoss = false}) {
    if (isBoss && widget.activeBoss != null) {
      _currentEnemy = Enemy(
        name: widget.activeBoss!.name,
        health: widget.activeBoss!.health,
        damage: widget.activeBoss!.damage,
        attackDelay: widget.activeBoss!.attackDelay,
        dodgeChance: widget.activeBoss!.dodgeChance,
        themeColor: widget.activeBoss!.themeColor,
      );
    } else {
      _enemyNumber++;
      _currentEnemy = _generateRandomEnemy(_enemyNumber);
    }
    
    _enemyChargeController.duration = _currentEnemy!.attackDelay;

    Future.microtask(() {
      if (mounted) widget.onNewEnemyApproached();
    });

    setState(() {
      _isFighting = true;
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasDefeated = false;
      _playerMissed = false;
      _enemyHealth = _currentEnemy!.health;
    });

    _scrollController.stop();
    _walkController.value = 0.5; 
    _walkController.stop();
    _trainingTimer?.cancel();
    _encounterProgressController.stop();

    _schedulePlayerAttack();

    _enemyAttackTimer?.cancel();
    _startEnemyAttackCycle();
  }

  Enemy _generateRandomEnemy(int level) {
    final typeIndex = _random.nextInt(4);
    final enemyType = EnemyType.values[typeIndex];
    
    switch (enemyType) {
      case EnemyType.fast:
        return Enemy(
          name: 'PUNK',
          type: EnemyType.fast,
          health: 5 + (level * 1.5).floor(),
          damage: 1 + (level / 5).floor(),
          attackDelay: const Duration(milliseconds: 700),
          dodgeChance: 0.35,
          themeColor: Colors.yellowAccent,
        );
      case EnemyType.tank:
        return Enemy(
          name: 'BRUISER',
          type: EnemyType.tank,
          health: 15 + (level * 3.5).floor(),
          damage: 4 + (level / 2.5).floor(),
          attackDelay: const Duration(milliseconds: 2200),
          dodgeChance: 0.0,
          themeColor: Colors.blueAccent,
        );
      case EnemyType.counter:
        return Enemy(
          name: 'REBEL',
          type: EnemyType.counter,
          health: 8 + (level * 2).floor(),
          damage: 2 + (level / 4).floor(),
          attackDelay: const Duration(milliseconds: 1400),
          counterChance: 0.4,
          themeColor: Colors.deepPurpleAccent,
        );
      case EnemyType.regular:
      default:
        return Enemy(
          name: 'THUG',
          type: EnemyType.regular,
          health: 8 + (level * 2.2).floor(),
          damage: 2 + (level / 3.5).floor(),
          attackDelay: const Duration(milliseconds: 1300),
        );
    }
  }

  void _startEnemyAttackCycle() {
    _enemyChargeController.forward(from: 0).then((_) {
      if (mounted && _isFighting && !_isEnemyDying) {
        _enemyAttackPlayer();
        _startEnemyAttackCycle();
      }
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
    if (!_isFighting || _attackController.isAnimating || _currentEnemy == null) return;

    if (!widget.onStaminaSpent(8)) {
      widget.onStatsGained(strength: 0, speed: 0, endurance: 0.35);
      return;
    }

    if (_random.nextDouble() < _currentEnemy!.dodgeChance) {
      await _attackController.forward(from: 0);
      return;
    }

    if (_isCriticalHunger && _random.nextDouble() < 0.25) {
      setState(() => _playerMissed = true);
      await _attackController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _playerMissed = false);
      });
      return;
    }

    await _attackController.forward(from: 0);
    if (!mounted || !_isFighting) return;

    int damage = widget.stats.attackDamage;
    if (_isLowHunger) damage = (damage * 0.8).floor().clamp(1, 999);

    setState(() {
      _enemyHealth -= damage;
      _enemyWasHit = true;
      if (_enemyHealth <= 0) {
        _attackTimer?.cancel();
        _enemyChargeController.stop();
        _isFighting = false;
        _isEnemyDying = true;
      }
    });

    double gainMult = widget.activeBoss != null ? 3.0 : 1.0;
    widget.onStatsGained(strength: 0.65 * gainMult, speed: 0.12 * gainMult, endurance: 0);

    // COUNTER ATTACK LOGIC
    if (_enemyHealth > 0 && _random.nextDouble() < _currentEnemy!.counterChance) {
       _enemyAttackPlayer(isCounter: true);
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    if (_enemyHealth <= 0) {
      await _deathController.forward(from: 0);
      if (mounted) {
        if (widget.activeBoss != null) widget.onBossDefeated?.call();
        _startWalking(); 
      }
    }
  }

  Future<void> _enemyAttackPlayer({bool isCounter = false}) async {
    if (!_isFighting || (_enemyAttackController.isAnimating && !isCounter) || _isEnemyDying || _currentEnemy == null) return;

    if (isCounter) {
        // Sudden strike visual
        _enemyAttackController.forward(from: 0.5);
    } else {
        await _enemyAttackController.forward(from: 0);
    }
    
    if (!mounted || !_isFighting || _isEnemyDying) return;

    if (_random.nextDouble() < widget.stats.dodgeChance && _payDodgeCost()) {
      widget.onStatsGained(strength: 0, speed: 0.9, endurance: 0);
      setState(() => _playerWasHit = true);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) setState(() => _playerWasHit = false);
      });
      return;
    }

    int damage = _currentEnemy!.damage;

    if (_isLowHunger) damage = (damage * 1.3).ceil();

    final willDefeatPlayer = widget.playerHealth - damage <= 0;
    widget.onPlayerDamaged(damage);
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.8);
    
    double stmRecovery = widget.stats.staminaRecovery * 0.35;
    if (_isLowHunger) stmRecovery *= 0.5;
    
    widget.onNeedsRecovered(stamina: stmRecovery, hunger: -0.25);

    setState(() => _playerWasHit = true);

    if (willDefeatPlayer) {
      _handlePlayerDefeated();
      return;
    }

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _playerWasHit = false);
    });
  }

  bool _payDodgeCost() {
    if (widget.onStaminaSpent(_dodgeStaminaCost)) return true;
    if (widget.playerHunger >= _dodgeHungerCost) {
      widget.onNeedsRecovered(stamina: 0, hunger: -_dodgeHungerCost);
      return true;
    }
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.25);
    return false;
  }

  void _handlePlayerDefeated() {
    final wasBossFight = widget.activeBoss != null;
    _encounterProgressController.stop();
    _attackTimer?.cancel();
    _enemyChargeController.stop();
    _trainingTimer?.cancel();

    widget.onPlayerDefeated();

    setState(() {
      _isFighting = false;
      _isEnemyDying = false;
      _playerWasDefeated = true;
      _enemyHealth = _currentEnemy?.health ?? 0;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        if (wasBossFight) {
          _startWalking();
        } else {
          setState(() {
            _isFighting = true;
            _playerWasHit = false;
            _playerWasDefeated = false;
          });
          _schedulePlayerAttack();
          _startEnemyAttackCycle();
        }
      }
    });
  }

  @override
  void dispose() {
    _attackTimer?.cancel();
    _trainingTimer?.cancel();
    _scrollController.dispose();
    _walkController.dispose();
    _attackController.dispose();
    _enemyAttackController.dispose();
    _deathController.dispose();
    _encounterProgressController.dispose();
    _enemyChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
          ),
        ),

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
                    SizedBox(width: sceneWidth, child: const StreetSceneLayer()),
                    SizedBox(width: sceneWidth, child: const StreetSceneLayer()),
                  ],
                ),
              ),
            );
          },
        ),

        Positioned(
          top: 80,
          left: 20,
          right: 20,
          child: PlayerHealthBar(
            health: widget.playerHealth,
            maxHealth: widget.playerMaxHealth,
            stamina: widget.playerStamina,
            maxStamina: widget.playerMaxStamina,
            hunger: widget.playerHunger,
            maxHunger: widget.playerMaxHunger,
            wasHit: _playerWasHit,
            damage: widget.stats.attackDamage,
            dodge: (widget.stats.dodgeChance * 100).toInt(),
          ),
        ),

        if (!_isFighting && !_isEnemyDying && !_playerWasDefeated)
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  const Text('SEARCHING FOR RIVALS...', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 150,
                    child: AnimatedBuilder(
                      animation: _encounterProgressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _encounterProgressController.value,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white54),
                          minHeight: 2,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_isLowHunger)
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _isCriticalHunger ? Colors.redAccent : Colors.orangeAccent, width: 1),
                ),
                child: Text(
                  _isCriticalHunger ? 'CRITICAL HUNGER: SHAKY STATE' : 'LOW HUNGER: REDUCED STATS',
                  style: TextStyle(
                    color: _isCriticalHunger ? Colors.redAccent : Colors.orangeAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 45.0, left: 60.0), 
            child: AnimatedBuilder(
              animation: Listenable.merge([_walkController, _attackController, _enemyAttackController]),
              builder: (context, child) {
                final attackProgress = math.sin(_attackController.value * math.pi);
                final hitShake = _playerWasHit ? math.sin(_enemyAttackController.value * math.pi * 8) * 6 : 0.0;
                final missShake = _playerMissed ? math.sin(_attackController.value * math.pi * 12) * 5 : 0.0;
                
                return Opacity(
                  opacity: _playerWasHit ? 0.72 : 1,
                  child: Transform.translate(
                    offset: Offset(
                      (_isFighting ? attackProgress * 52 : 0) + hitShake + missShake,
                      _isFighting ? -attackProgress * 4 : -_walkController.value * 8,
                    ),
                    child: Transform.rotate(
                      angle: _isFighting ? attackProgress * 0.18 : (_walkController.value - 0.5) * 0.05,
                      child: child,
                    ),
                  ),
                );
              },
              child: const HeroCharacterPlaceholder(),
            ),
          ),
        ),

        if (_playerMissed)
          Positioned(
            bottom: 120,
            left: 100,
            child: const Text(
              'MISS!',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),

        if ((_isFighting || _isEnemyDying || _playerWasDefeated) && _currentEnemy != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 45.0, right: 60.0),
              child: AnimatedBuilder(
                animation: Listenable.merge([_attackController, _enemyAttackController, _deathController]),
                builder: (context, child) {
                  final hitShake = _enemyWasHit ? math.sin(_attackController.value * math.pi * 8) * 6 : 0.0;
                  final enemyAttackProgress = math.sin(_enemyAttackController.value * math.pi);
                  final fallProgress = Curves.easeIn.transform(_deathController.value);
                  return Opacity(
                    opacity: (1 - fallProgress).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(hitShake - enemyAttackProgress * 40 + fallProgress * 50, -enemyAttackProgress * 4 + fallProgress * 100),
                      child: Transform.rotate(
                        angle: -enemyAttackProgress * 0.14 + fallProgress * math.pi / 2.5,
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
                    enemy: _currentEnemy!,
                    enemyNumber: widget.activeBoss != null ? 0 : _enemyNumber,
                    wasHit: _enemyWasHit,
                    chargeProgress: _enemyChargeController,
                  ),
                ),
              ),
            ),
          ),

        if (_isEnemyDying || _playerWasDefeated)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isEnemyDying ? (widget.activeBoss != null ? 'BOSS DEFEATED!' : 'ENEMY DEFEATED') : 'RECOVERING',
                style: TextStyle(
                  color: _isEnemyDying ? Colors.amberAccent : Colors.redAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
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
  final int damage;
  final int dodge;

  const PlayerHealthBar({
    super.key,
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.hunger,
    required this.maxHunger,
    required this.wasHit,
    required this.damage,
    required this.dodge,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, maxHealth);
    final healthPercent = maxHealth == 0 ? 0.0 : visibleHealth / maxHealth;
    final staminaPercent = maxStamina == 0 ? 0.0 : stamina.clamp(0, maxStamina) / maxStamina;
    final hungerPercent = maxHunger == 0 ? 0.0 : hunger.clamp(0, maxHunger) / maxHunger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PLAYER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text('ATK: $damage  DDG: $dodge%', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: healthPercent,
            backgroundColor: Colors.black54,
            valueColor: AlwaysStoppedAnimation<Color>(wasHit ? Colors.white : Colors.lightGreenAccent),
          ),
        ),
        const SizedBox(height: 3),
        Text('HP: $visibleHealth/$maxHealth', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _buildNeedBar('STM', staminaPercent, Colors.cyanAccent),
        const SizedBox(height: 3),
        _buildNeedBar('HNG', hungerPercent, hungerPercent < 0.25 ? Colors.redAccent : Colors.orangeAccent),
      ],
    );
  }

  Widget _buildNeedBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 35, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 5,
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
        Container(
          width: 30, 
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withValues(alpha: 0.8),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 40, 
          height: 55, 
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: const Center(
            child: Text('HERO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 9)),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 24, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Container(width: 12, height: 24, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(3))),
          ],
        ),
      ],
    );
  }
}

class EnemyCharacterPlaceholder extends StatelessWidget {
  final int health;
  final Enemy enemy;
  final int enemyNumber;
  final bool wasHit;
  final AnimationController chargeProgress;

  const EnemyCharacterPlaceholder({
    super.key,
    required this.health,
    required this.enemy,
    required this.enemyNumber,
    required this.wasHit,
    required this.chargeProgress,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, enemy.health);
    final healthPercent = enemy.health == 0 ? 0.0 : visibleHealth / enemy.health;
    final displayColor = enemy.themeColor;
    final isBoss = enemy.type == EnemyType.regular && enemy.name != 'THUG' && enemy.name != 'PUNK' && enemy.name != 'BRUISER' && enemy.name != 'REBEL'; 

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isBoss ? 'BOSS: ${enemy.name}' : '${enemy.name} #$enemyNumber', style: TextStyle(color: displayColor, fontWeight: FontWeight.bold, fontSize: isBoss ? 14 : 12)),
            const SizedBox(width: 8),
            Text('ATK: ${enemy.damage}', style: TextStyle(color: displayColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        if (enemy.type != EnemyType.regular)
           Text(enemy.type.name.toUpperCase(), style: TextStyle(color: displayColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 3),
        SizedBox(
          width: isBoss ? 90 : 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: isBoss ? 8 : 6,
              value: healthPercent,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(wasHit ? Colors.white : displayColor),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: isBoss ? 90 : 60,
          child: AnimatedBuilder(
            animation: chargeProgress,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: chargeProgress.value,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent.withValues(alpha: 0.6)),
                minHeight: 2,
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isBoss ? 44 : 30,
          height: isBoss ? 44 : 30,
          decoration: BoxDecoration(
            color: isBoss ? Colors.black : Colors.red[800],
            shape: BoxShape.circle,
            border: isBoss ? Border.all(color: displayColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: displayColor.withValues(alpha: 0.5),
                blurRadius: isBoss ? 18 : 12,
                spreadRadius: isBoss ? 4 : 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isBoss ? 60 : 40,
          height: isBoss ? 85 : 55,
          decoration: BoxDecoration(
            color: isBoss ? Colors.black : Colors.red[900],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: displayColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Text(isBoss ? 'BOSS' : 'ENEMY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 9)),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 18, height: 24, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(3))),
            SizedBox(width: isBoss ? 12 : 8),
            Container(width: 18, height: 24, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(3))),
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
        Positioned(
          bottom: 60, 
          left: 0,
          right: 0,
          height: 170,
          child: CustomPaint(
            painter: BrickWallPainter(),
            child: Stack(
              children: [
                Positioned(top: 15, right: 60, child: _buildWindow()),
                Positioned(top: 60, left: 220, child: _buildWindow()),
                Positioned(left: 20, top: 0, bottom: 0, child: _buildPipes()),
                Positioned(left: 350, top: 0, bottom: 0, child: _buildPipes()),
                const Positioned(top: 50, left: 40, child: GraffitiText(text: 'S-RANK\nONLY', angle: -0.15, color: Colors.redAccent)),
                const Positioned(top: 30, left: 280, child: GraffitiText(text: 'IDLE', angle: 0.1, color: Colors.greenAccent, fontSize: 22)),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: CustomPaint(painter: AsphaltPainter()),
        ),

        Positioned(right: 80, bottom: 60, child: _buildStreetLamp()),
        Positioned(left: 90, bottom: 55, child: _buildDumpster()),
        Positioned(left: 450, bottom: 60, child: _buildStreetLamp()),
      ],
    );
  }

  Widget _buildWindow() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.black87, width: 3),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
          Container(height: 3, color: Colors.black87),
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _buildPipes() {
    return Container(
      width: 10,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          left: BorderSide(color: Colors.black54, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStreetLamp() {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 170,
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
          width: 70,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(child: Container(width: 55, height: 1.5, color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Icon(Icons.delete_outline, size: 28, color: Colors.grey[800]),
      ],
    );
  }
}
