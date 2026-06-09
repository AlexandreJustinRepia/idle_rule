import 'dart:async';
import 'package:flutter/material.dart';
import '../../game_state.dart';
import '../../logic/combat_engine.dart';
import '../../logic/player_needs_logic.dart';
import '../ui/player_health_bar.dart';
import 'ghetto/ghetto_background.dart';
import 'ghetto/ghetto_enemy_factory.dart';
import 'ghetto/ghetto_enemy_unit.dart';
import 'ghetto/ghetto_hero_unit.dart';
import 'ghetto/ghetto_indicators.dart';
import 'ghetto/ghetto_ally_unit.dart';

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
  late AnimationController _allyAttackController;
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

  // FOUNDATION: Combat lists
  final List<Ally> _allies = [];
  final List<Enemy> _enemies = [];
  final Map<Ally, Timer?> _allyAttackTimers = {};

  int _enemyNumber = 0;
  int _enemyHealth = 0;
  Enemy? _currentEnemy;
  Timer? _attackTimer;
  Timer? _enemyAttackTimer;
  Timer? _trainingTimer;

  bool get _isLowHunger => PlayerNeedsLogic.isLowHunger(widget.playerHunger, widget.playerMaxHunger);
  bool get _isCriticalHunger => PlayerNeedsLogic.isCriticalHunger(widget.playerHunger, widget.playerMaxHunger);

  @override
  void initState() {
    super.initState();
    // Initialize one ally (Homie)
    _allies.add(Ally(
      name: 'Homie',
      hp: 100,
      maxHp: 100,
      atk: 4,
      attackDelay: const Duration(milliseconds: 2100),
      themeColor: Colors.greenAccent,
    ));

    _scrollController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _walkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _attackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _allyAttackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
    _stopAllCombatAnimations();
    setState(() {
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasHit = false;
      _playerWasDefeated = false;
      _playerMissed = false;
      _enemyHealth = 0;
      _isFighting = false;
      _currentEnemy = null;
      _enemies.clear();
    });

    _scrollController.repeat();
    _walkController.repeat(reverse: true);
    _trainingTimer?.cancel();
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      widget.onStatsGained(strength: 0, speed: 0.25, endurance: 0);
      double recovery = widget.stats.staminaRecovery * PlayerNeedsLogic.getRecoveryMultiplier(widget.playerHunger, widget.playerMaxHunger);
      widget.onNeedsRecovered(stamina: recovery, hunger: -0.45);
    });

    _encounterProgressController.forward(from: 0).then((_) {
      if (mounted && widget.activeBoss == null && !_isFighting) {
        _startEncounter();
      }
    });
  }

  void _stopAllCombatAnimations() {
    _attackTimer?.cancel();
    _enemyAttackTimer?.cancel();
    for (var timer in _allyAttackTimers.values) {
      timer?.cancel();
    }
    _allyAttackTimers.clear();

    for (var controller in [_attackController, _allyAttackController, _enemyAttackController, _deathController, _enemyChargeController]) {
      controller.stop();
      controller.value = 0;
    }
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
      _currentEnemy = GhettoEnemyFactory.generateRandomEnemy(_enemyNumber, widget.stats);
    }

    _enemies.clear();
    if (_currentEnemy != null) {
      _enemies.add(_currentEnemy!);
    }

    _enemyChargeController.duration = _currentEnemy!.attackDelay;
    Future.microtask(() {
      if (mounted) {
        widget.onNewEnemyApproached();
      }
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
    _startAllyCombat();
    
    _enemyAttackTimer?.cancel();
    _startEnemyAttackCycle();
  }

  void _startAllyCombat() {
    for (var ally in _allies) {
      _scheduleAllyAttack(ally);
    }
  }

  void _scheduleAllyAttack(Ally ally) {
    _allyAttackTimers[ally]?.cancel();
    _allyAttackTimers[ally] = Timer(ally.attackDelay, () async {
      if (mounted && _isFighting) {
        await _attackEnemyFromAlly(ally);
        _scheduleAllyAttack(ally);
      }
    });
  }

  Future<void> _attackEnemyFromAlly(Ally ally) async {
    if (!_isFighting || _enemies.isEmpty || ally.hp <= 0) return;

    // Ally AI: Target current enemy (v1)
    final target = _enemies.first;

    if (CombatEngine.rollDodge(target.dodgeChance)) {
      return;
    }

    // Trigger ally attack animation
    _allyAttackController.forward(from: 0);

    int damage = ally.atk;

    setState(() {
      target.hp -= damage;
      if (target == _currentEnemy) {
        _enemyHealth = target.hp;
      }
      _enemyWasHit = true;
      
      if (target.hp <= 0) {
        if (target == _currentEnemy) {
          _isFighting = false;
          _isEnemyDying = true;
          _enemyChargeController.stop();
        }
        _enemies.remove(target);
      }
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _enemyWasHit = false);
      }
    });

    if (_isEnemyDying) {
      await _deathController.forward(from: 0);
      if (mounted) {
        if (widget.activeBoss != null) widget.onBossDefeated?.call();
        _startWalking();
      }
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

    if (CombatEngine.rollDodge(_currentEnemy!.dodgeChance)) {
      await _attackController.forward(from: 0);
      return;
    }

    if (CombatEngine.rollMiss(_isCriticalHunger)) {
      setState(() => _playerMissed = true);
      await _attackController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _playerMissed = false);
        }
      });
      return;
    }

    await _attackController.forward(from: 0);
    if (!mounted || !_isFighting) return;

    int damage = CombatEngine.calculatePlayerDamage(widget.stats, _isLowHunger);

    setState(() {
      _enemyHealth -= damage;
      _currentEnemy!.hp = _enemyHealth;
      _enemyWasHit = true;
      if (_enemyHealth <= 0) {
        _isFighting = false;
        _isEnemyDying = true;
        _enemyChargeController.stop();
      }
    });

    double gainMult = widget.activeBoss != null ? 3.0 : 1.0;
    widget.onStatsGained(strength: 0.65 * gainMult, speed: 0.12 * gainMult, endurance: 0);

    if (_enemyHealth > 0 && CombatEngine.rollDodge(_currentEnemy!.counterChance)) {
      _enemyAttackPlayer(isCounter: true);
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _enemyWasHit = false);
      }
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
      _enemyAttackController.forward(from: 0.5);
    } else {
      await _enemyAttackController.forward(from: 0);
    }

    if (!mounted || !_isFighting || _isEnemyDying) return;

    if (CombatEngine.rollDodge(widget.stats.dodgeChance) && _payDodgeCost()) {
      widget.onStatsGained(strength: 0, speed: 0.9, endurance: 0);
      setState(() => _playerWasHit = true);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) {
          setState(() => _playerWasHit = false);
        }
      });
      return;
    }

    int damage = CombatEngine.calculateEnemyDamage(_currentEnemy!.damage, _isLowHunger);

    final willDefeatPlayer = widget.playerHealth - damage <= 0;
    widget.onPlayerDamaged(damage);
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.8);
    
    double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(widget.playerHunger, widget.playerMaxHunger);
    widget.onNeedsRecovered(stamina: widget.stats.staminaRecovery * 0.35 * recoveryMult, hunger: -0.25);

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
    if (widget.onStaminaSpent(5)) {
      return true;
    }
    if (widget.playerHunger >= 2) {
      widget.onNeedsRecovered(stamina: 0, hunger: -2);
      return true;
    }
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.25);
    return false;
  }

  void _handlePlayerDefeated() {
    final wasBossFight = widget.activeBoss != null;
    _stopAllCombatAnimations();
    _encounterProgressController.stop();
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
    _stopAllCombatAnimations();
    _trainingTimer?.cancel();
    _scrollController.dispose();
    _walkController.dispose();
    _attackController.dispose();
    _allyAttackController.dispose();
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
        GhettoBackground(scrollAnimation: _scrollController, sceneWidth: sceneWidth),
        Positioned(
          top: 80, left: 20, right: 20,
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
          GhettoSearchingIndicator(progress: _encounterProgressController),
        GhettoHungerIndicator(isLowHunger: _isLowHunger, isCriticalHunger: _isCriticalHunger),
        
        // Ally Display
        for (var ally in _allies)
          GhettoAllyUnit(
            ally: ally,
            walkAnimation: _walkController,
            attackAnimation: _allyAttackController,
            isFighting: _isFighting,
          ),

        GhettoHeroUnit(
          walkAnimation: _walkController, attackAnimation: _attackController,
          enemyAttackAnimation: _enemyAttackController, isFighting: _isFighting,
          wasHit: _playerWasHit, missed: _playerMissed,
        ),
        if (_playerMissed)
          const Positioned(bottom: 120, left: 100, child: Text('MISS!', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16))),
        GhettoEnemyUnit(
          isFighting: _isFighting, isEnemyDying: _isEnemyDying, playerWasDefeated: _playerWasDefeated,
          currentEnemy: _currentEnemy, enemyHealth: _enemyHealth, enemyNumber: _enemyNumber,
          enemyWasHit: _enemyWasHit, attackAnimation: _attackController,
          enemyAttackAnimation: _enemyAttackController, deathAnimation: _deathController,
          enemyChargeController: _enemyChargeController, onTap: _attackEnemy,
          isBoss: widget.activeBoss != null,
        ),
        GhettoBattleStatusOverlay(isEnemyDying: _isEnemyDying, playerWasDefeated: _playerWasDefeated, isBoss: widget.activeBoss != null),
      ],
    );
  }
}
