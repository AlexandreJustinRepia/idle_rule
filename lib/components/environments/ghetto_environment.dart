import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game_state.dart';
import '../ui/player_health_bar.dart';
import 'shared/graffiti_text.dart';
import 'shared/environment_painters.dart';
import 'shared/character_placeholders.dart';
import 'shared/street_scene_layer.dart';

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
