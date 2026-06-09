import 'dart:async';
import 'dart:math' as math;
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
  late AnimationController _playerHitController; 
  late AnimationController _deathController;
  late AnimationController _encounterProgressController;

  final double sceneWidth = 900.0;

  bool _isFighting = false;
  bool _isEnemyDying = false;
  bool _enemyWasHit = false;
  bool _playerWasHit = false;
  bool _playerWasDefeated = false;
  bool _playerMissed = false;

  final List<Ally> _allies = [];
  final List<Enemy> _enemies = [];
  final List<Enemy> _dyingEnemies = [];
  
  final Map<Ally, AnimationController> _allyChargeControllers = {};
  final Map<Ally, AnimationController> _allyAttackControllers = {};
  final Map<Enemy, AnimationController> _enemyChargeControllers = {};
  final Map<Enemy, AnimationController> _enemyAttackControllers = {};

  int _enemyNumber = 0;
  Timer? _attackTimer;
  Timer? _trainingTimer;

  bool get _isLowHunger => PlayerNeedsLogic.isLowHunger(widget.playerHunger, widget.playerMaxHunger);
  bool get _isCriticalHunger => PlayerNeedsLogic.isCriticalHunger(widget.playerHunger, widget.playerMaxHunger);

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _walkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _attackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _playerHitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _deathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _encounterProgressController = AnimationController(vsync: this, duration: const Duration(seconds: 4));

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
      _isFighting = false;
      _enemies.clear();
      _dyingEnemies.clear();
      for (var c in _enemyChargeControllers.values) c.dispose();
      _enemyChargeControllers.clear();
      for (var c in _enemyAttackControllers.values) c.dispose();
      _enemyAttackControllers.clear();
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
    _playerHitController.stop();
    _deathController.stop();
    for (var c in _allyChargeControllers.values) { c.stop(); c.value = 0; }
    for (var c in _allyAttackControllers.values) { c.stop(); c.value = 0; }
    for (var c in _enemyChargeControllers.values) { c.stop(); c.value = 0; }
    for (var c in _enemyAttackControllers.values) { c.stop(); c.value = 0; }
    _attackController.stop();
    _attackController.value = 0;
  }

  void _recruitEnemy(Enemy enemy) {
    final allyAtk = (enemy.damage * 0.5).floor().clamp(1, 999);
    final allyMaxHp = (enemy.health * 0.7).floor().clamp(1, 9999);
    final allyDelay = Duration(milliseconds: (enemy.attackDelay.inMilliseconds * 1.2).round());

    final newAlly = Ally(
      name: enemy.name,
      hp: allyMaxHp,
      maxHp: allyMaxHp,
      atk: allyAtk,
      attackDelay: allyDelay,
      themeColor: Colors.blueAccent,
    );

    setState(() {
      _allies.add(newAlly);
      _allyChargeControllers[newAlly] = AnimationController(vsync: this, duration: newAlly.attackDelay);
      _allyAttackControllers[newAlly] = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
      if (_isFighting) {
        _scheduleAllyAttack(newAlly);
      }
    });
  }

  void _startEncounter({bool isBoss = false}) {
    _enemies.clear();
    _dyingEnemies.clear();
    for (var c in _enemyChargeControllers.values) c.dispose();
    _enemyChargeControllers.clear();
    for (var c in _enemyAttackControllers.values) c.dispose();
    _enemyAttackControllers.clear();

    if (isBoss && widget.activeBoss != null) {
      _enemies.add(Enemy(
        name: widget.activeBoss!.name,
        health: widget.activeBoss!.health,
        damage: widget.activeBoss!.damage,
        attackDelay: widget.activeBoss!.attackDelay,
        dodgeChance: widget.activeBoss!.dodgeChance,
        themeColor: widget.activeBoss!.themeColor,
      ));
    } else {
      int count = (math.Random().nextInt(3) + 1);
      for (int i = 0; i < count; i++) {
        _enemyNumber++;
        _enemies.add(GhettoEnemyFactory.generateRandomEnemy(_enemyNumber, widget.stats));
      }
    }

    for (var enemy in _enemies) {
      _enemyChargeControllers[enemy] = AnimationController(vsync: this, duration: enemy.attackDelay);
      _enemyAttackControllers[enemy] = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    }

    Future.microtask(() { if (mounted) widget.onNewEnemyApproached(); });

    setState(() {
      _isFighting = true;
      _isEnemyDying = false;
      _enemyWasHit = false;
      _playerWasDefeated = false;
      _playerMissed = false;
    });

    _scrollController.stop();
    _walkController.value = 0.5;
    _walkController.stop();
    _trainingTimer?.cancel();
    _encounterProgressController.stop();
    
    _schedulePlayerAttack();
    _startAllyCombat();
    for (var enemy in _enemies) { _startEnemyCharge(enemy); }
  }

  void _startEnemyCharge(Enemy enemy) {
    _enemyChargeControllers[enemy]?.forward(from: 0).then((_) {
      if (mounted && _isFighting && _enemies.contains(enemy)) {
        _onEnemyAttack(enemy);
        _startEnemyCharge(enemy);
      }
    });
  }

  Future<void> _onEnemyAttack(Enemy enemy) async {
    List<dynamic> targets = [null, ..._allies];
    var target = targets[math.Random().nextInt(targets.length)];
    if (target == null) {
      await _enemyAttackPlayer(enemy);
    } else {
      await _enemyAttackAlly(enemy, target as Ally);
    }
  }

  void _startAllyCombat() {
    for (var ally in _allies) { _scheduleAllyAttack(ally); }
  }

  void _scheduleAllyAttack(Ally ally) {
    _allyChargeControllers[ally]?.forward(from: 0).then((_) {
      if (mounted && _isFighting && _allies.contains(ally)) {
        _attackEnemyFromAlly(ally);
        _scheduleAllyAttack(ally);
      }
    });
  }

  Future<void> _attackEnemyFromAlly(Ally ally) async {
    if (!_isFighting || _enemies.isEmpty || ally.hp <= 0) return;
    final target = _enemies.first;
    if (CombatEngine.rollDodge(target.dodgeChance)) return;

    _allyAttackControllers[ally]?.forward(from: 0);
    int damage = CombatEngine.calculateAllyDamage(ally.atk, _isLowHunger);

    setState(() {
      target.hp -= damage;
      _enemyWasHit = true;
      if (target.hp <= 0) { _handleEnemyDefeat(target); }
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    if (_isEnemyDying && _enemies.isEmpty) {
      await _deathController.forward(from: 0);
      if (mounted) {
        if (widget.activeBoss != null) widget.onBossDefeated?.call();
        _startWalking();
      }
    }
  }

  void _handleEnemyDefeat(Enemy enemy) {
    _enemyChargeControllers[enemy]?.stop();
    _enemies.remove(enemy);
    _dyingEnemies.add(enemy);
    _recruitEnemy(enemy); 

    if (_enemies.isEmpty) {
      _isFighting = false;
      _isEnemyDying = true;
    }
  }

  void _schedulePlayerAttack() {
    _attackTimer?.cancel();
    _attackTimer = Timer(widget.stats.attackDelay, () async {
      await _attackEnemy();
      if (mounted && _isFighting) { _schedulePlayerAttack(); }
    });
  }

  Future<void> _attackEnemy() async {
    if (!_isFighting || _attackController.isAnimating || _enemies.isEmpty) return;
    if (!widget.onStaminaSpent(8)) {
      widget.onStatsGained(strength: 0, speed: 0, endurance: 0.35);
      return;
    }

    final target = _enemies.first;
    if (CombatEngine.rollDodge(target.dodgeChance)) {
      await _attackController.forward(from: 0);
      return;
    }

    if (CombatEngine.rollMiss(_isCriticalHunger)) {
      setState(() => _playerMissed = true);
      await _attackController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _playerMissed = false);
      });
      return;
    }

    await _attackController.forward(from: 0);
    if (!mounted || !_isFighting) return;

    int damage = CombatEngine.calculatePlayerDamage(widget.stats, _isLowHunger);
    setState(() {
      target.hp -= damage;
      _enemyWasHit = true;
      if (target.hp <= 0) { _handleEnemyDefeat(target); }
    });

    double gainMult = widget.activeBoss != null ? 3.0 : 1.0;
    widget.onStatsGained(strength: 0.65 * gainMult, speed: 0.12 * gainMult, endurance: 0);

    if (_enemies.isNotEmpty && CombatEngine.rollDodge(_enemies.first.counterChance)) {
      _onEnemyAttack(_enemies.first);
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    if (_isEnemyDying && _enemies.isEmpty) {
      await _deathController.forward(from: 0);
      if (mounted) {
        if (widget.activeBoss != null) widget.onBossDefeated?.call();
        _startWalking();
      }
    }
  }

  Future<void> _enemyAttackPlayer(Enemy enemy) async {
    if (!_isFighting || _isEnemyDying) return;
    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted || !_isFighting || _isEnemyDying) return;

    if (CombatEngine.rollDodge(widget.stats.dodgeChance) && _payDodgeCost()) {
      widget.onStatsGained(strength: 0, speed: 0.9, endurance: 0);
      setState(() => _playerWasHit = true);
      _playerHitController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) setState(() => _playerWasHit = false);
      });
      return;
    }

    int damage = CombatEngine.calculateEnemyDamage(enemy.damage, _isLowHunger);
    final willDefeatPlayer = widget.playerHealth - damage <= 0;
    widget.onPlayerDamaged(damage);
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.8);
    
    double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(widget.playerHunger, widget.playerMaxHunger);
    widget.onNeedsRecovered(stamina: widget.stats.staminaRecovery * 0.35 * recoveryMult, hunger: -0.25);

    setState(() => _playerWasHit = true);
    _playerHitController.forward(from: 0);
    if (willDefeatPlayer) { _handlePlayerDefeated(); return; }

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _playerWasHit = false);
    });
  }

  Future<void> _enemyAttackAlly(Enemy enemy, Ally ally) async {
    if (!_isFighting || _isEnemyDying) return;
    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted || !_isFighting || _isEnemyDying || !_allies.contains(ally)) return;

    int damage = CombatEngine.calculateEnemyDamage(enemy.damage, _isLowHunger);
    setState(() {
      ally.hp -= damage;
      if (ally.hp <= 0) {
        _allies.remove(ally);
        _allyChargeControllers[ally]?.dispose();
        _allyChargeControllers.remove(ally);
        _allyAttackControllers[ally]?.dispose();
        _allyAttackControllers.remove(ally);
      }
    });
  }

  bool _payDodgeCost() {
    if (widget.onStaminaSpent(5)) return true;
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
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        if (wasBossFight) { _startWalking(); }
        else {
          setState(() {
            _isFighting = true;
            _playerWasHit = false;
            _playerWasDefeated = false;
          });
          _schedulePlayerAttack();
          _startAllyCombat();
          for (var enemy in _enemies) _startEnemyCharge(enemy);
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
    _playerHitController.dispose();
    _deathController.dispose();
    _encounterProgressController.dispose();
    for (var c in _allyChargeControllers.values) c.dispose();
    for (var c in _allyAttackControllers.values) c.dispose();
    for (var c in _enemyChargeControllers.values) c.dispose();
    for (var c in _enemyAttackControllers.values) c.dispose();
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
        
        for (int i = 0; i < _allies.length; i++)
          GhettoAllyUnit(
            index: i,
            ally: _allies[i],
            walkAnimation: _walkController,
            attackAnimation: _allyAttackControllers[_allies[i]] ?? _attackController,
            chargeAnimation: _allyChargeControllers[_allies[i]],
            isFighting: _isFighting,
          ),

        GhettoHeroUnit(
          walkAnimation: _walkController, attackAnimation: _attackController,
          enemyAttackAnimation: _playerHitController, isFighting: _isFighting,
          wasHit: _playerWasHit, missed: _playerMissed,
        ),
        
        if (_playerMissed)
          const Positioned(bottom: 120, left: 100, child: Text('MISS!', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16))),
        
        for (int i = 0; i < _enemies.length; i++)
          GhettoEnemyUnit(
            index: i,
            enemy: _enemies[i],
            enemyNumber: _enemyNumber - (_enemies.length - 1) + i,
            isFighting: _isFighting,
            isEnemyDying: false,
            playerWasDefeated: _playerWasDefeated,
            enemyWasHit: _enemyWasHit && i == 0,
            attackAnimation: _attackController,
            enemyAttackAnimation: _enemyAttackControllers[_enemies[i]] ?? _playerHitController,
            deathAnimation: _deathController,
            enemyChargeController: _enemyChargeControllers[_enemies[i]] ?? _playerHitController,
            onTap: _attackEnemy,
            isBoss: widget.activeBoss != null && i == 0,
          ),

        for (var enemy in _dyingEnemies)
          GhettoEnemyUnit(
            index: 0,
            enemy: enemy,
            enemyNumber: 0,
            isFighting: false,
            isEnemyDying: true,
            playerWasDefeated: false,
            enemyWasHit: false,
            attackAnimation: _attackController,
            enemyAttackAnimation: _playerHitController,
            deathAnimation: _deathController,
            enemyChargeController: _playerHitController,
            onTap: () {},
          ),

        GhettoBattleStatusOverlay(isEnemyDying: _isEnemyDying, playerWasDefeated: _playerWasDefeated, isBoss: widget.activeBoss != null),
      ],
    );
  }
}
