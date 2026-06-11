import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game_state.dart';
import '../../logic/combat_engine.dart';
import '../../logic/player_needs_logic.dart';
import '../ui/player_health_bar.dart';
import '../ui/fight_boss_button.dart';
import '../ui/action_card.dart';
import '../ui/cinematic_slam_overlay.dart';
import '../ui/encounter_choice_overlay.dart';
import '../ui/encounter_talk_overlay.dart';
import 'ghetto/ghetto_background.dart';
import 'ghetto/ghetto_enemy_factory.dart';
import 'ghetto/ghetto_enemy_unit.dart';
import 'ghetto/ghetto_hero_unit.dart';
import 'ghetto/ghetto_indicators.dart';
import 'ghetto/ghetto_ally_unit.dart';
import 'ghetto/ghetto_recruitment_overlay.dart';
import 'ghetto/ghetto_safe_house_overlay.dart';
import 'ghetto/ghetto_transition_overlay.dart';

class GhettoEnvironment extends StatefulWidget {
  final PlayerStats stats;
  final int playerHealth;
  final int playerMaxHealth;
  final double playerStamina;
  final double playerMaxStamina;
  final double playerHunger;
  final double playerMaxHunger;
  final void Function({double strength, double speed, double endurance, double reputation}) onStatsGained;
  final void Function(int damage) onPlayerDamaged;
  final VoidCallback onPlayerDefeated;
  final VoidCallback onNewEnemyApproached;
  final bool Function(double amount) onStaminaSpent;
  final void Function({double stamina, double hunger}) onNeedsRecovered;
  final Boss? activeBoss;
  final VoidCallback? onBossDefeated;
  final VoidCallback? onStartBossFight;
  final int bossIndex;
  final void Function(int amount)? onMoneyGained;

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
    this.onStartBossFight,
    this.bossIndex = 0,
    this.onMoneyGained,
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
  late AnimationController _introController;
  late AnimationController _transitionController;
  late AnimationController _defeatController;

  final double sceneWidth = 900.0;

  bool _isFighting = false;
  bool _isEnemyDying = false;
  bool _isRecruiting = false;
  bool _isIntroAnimating = false;
  bool _isTransitioning = false;
  bool _enemyWasHit = false;
  bool _playerWasHit = false;
  bool _playerWasDefeated = false;
  bool _playerMissed = false;
  bool _isResting = true; 
  bool _isAtHome = true;
  bool _isEncounterChoice = false;
  bool _isTalking = false;
  String _currentDialogue = "";
  
  final List<String> _randomInfo = [
    "The Gym is a great place to build endurance, but it costs money.",
    "Bosses hit hard! Make sure you recruit allies before facing them.",
    "If you run out of stamina, your attacks will miss more often.",
    "Reputation determines how many gang members you can recruit.",
    "Eating food recovers hunger and stamina.",
  ];

  final List<Ally> _allies = [];
  final List<Enemy> _enemies = [];
  final List<Enemy> _dyingEnemies = [];
  
  final Map<Ally, AnimationController> _allyChargeControllers = {};
  final Map<Ally, AnimationController> _allyAttackControllers = {};
  final Map<Enemy, AnimationController> _enemyChargeControllers = {};
  final Map<Enemy, AnimationController> _enemyAttackControllers = {};
  final Map<Enemy, int> _enemyOriginalIndices = {};

  int _enemyNumber = 0;
  Timer? _attackTimer;
  Timer? _trainingTimer;
  String _introEnemyName = "";

  bool get _isLowHunger => PlayerNeedsLogic.isLowHunger(widget.playerHunger, widget.playerMaxHunger);
  bool get _isCriticalHunger => PlayerNeedsLogic.isCriticalHunger(widget.playerHunger, widget.playerMaxHunger);
  
  bool get _isBossReady {
    return widget.stats.strength >= 25.0 && _allies.length >= 2 && _isAtHome;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _walkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _attackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _playerHitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _deathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _transitionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _defeatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

    _startHomeLogic();
  }

  @override
  void didUpdateWidget(GhettoEnvironment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeBoss != null && oldWidget.activeBoss == null) {
      _startBossEncounter();
    }
  }

  void _startBossEncounter() {
    _startEncounter(isBoss: true);
  }

  void _startHomeLogic() {
    _stopAllCombatAnimations();
    setState(() {
      _isAtHome = true;
      _isResting = true; // Auto-rest at home
      _isFighting = false;
      _isEnemyDying = false;
      _isRecruiting = false;
      _isIntroAnimating = false;
      _isTransitioning = false;
      _isEncounterChoice = false;
      _isTalking = false;
      _playerWasDefeated = false;
      _enemies.clear();
      _dyingEnemies.clear();
      _scrollController.stop();
      _walkController.stop();
      _walkController.value = 0;
    });

    _trainingTimer?.cancel();
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isAtHome && _isResting) {
        // High recovery logic at home
        double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(widget.playerHunger, widget.playerMaxHunger);
        widget.onNeedsRecovered(stamina: widget.stats.staminaRecovery * 4.0 * recoveryMult, hunger: -0.05);
        
        if (widget.playerHealth < widget.playerMaxHealth) {
           widget.onPlayerDamaged(- (widget.playerMaxHealth * 0.08).ceil());
        }

        for (var ally in _allies) {
          if (ally.hp < ally.maxHp) {
            setState(() {
              ally.hp = (ally.hp + (ally.maxHp * 0.15).ceil()).clamp(0, ally.maxHp);
            });
          }
        }
      } else if (!_isAtHome && !_isFighting && !_isRecruiting) {
        // Stats decay on street - no auto recovery
        widget.onNeedsRecovered(stamina: -0.2, hunger: -0.6);
      }
    });
  }

  void _enterHouse() {
    _startHomeLogic();
  }

  Future<void> _exitHouse() async {
    setState(() {
      _isTransitioning = true;
    });
    // Character walks toward door animation
    _walkController.repeat(reverse: true);
    await _transitionController.forward(from: 0);
    
    if (mounted) {
      setState(() {
        _isAtHome = false;
        _isResting = false;
        _isTransitioning = false;
        _scrollController.stop();
        _walkController.stop();
        _walkController.value = 0;
        _transitionController.reset();
      });
    }
  }

  void _startExploring() {
    setState(() {
      _isResting = false;
      _scrollController.repeat();
      _walkController.repeat(reverse: true);
    });
    
    // Discovery animation after a short walk
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_isFighting && !_isRecruiting && !_isAtHome && !_isResting) {
        _startEncounter();
      }
    });
  }

  void _stopAllCombatAnimations() {
    _attackTimer?.cancel();
    _playerHitController.stop();
    _deathController.stop();
    _introController.stop();
    _transitionController.stop();
    _defeatController.stop();
    for (var c in _allyChargeControllers.values) {
      c.stop();
      c.value = 0;
    }
    for (var c in _allyAttackControllers.values) {
      c.stop();
      c.value = 0;
    }
    for (var c in _enemyChargeControllers.values) {
      c.stop();
      c.value = 0;
    }
    for (var c in _enemyAttackControllers.values) {
      c.stop();
      c.value = 0;
    }
    _attackController.stop();
    _attackController.value = 0;
  }

  void _recruitAlly(Enemy enemy) {
    if (_allies.length >= widget.stats.gangCapacity) {
      Ally weakest = _allies.reduce((a, b) => (a.atk + a.maxHp) < (b.atk + b.maxHp) ? a : b);
      _dismissAlly(weakest);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('REPLACED ${weakest.name} WITH ${enemy.name}'), duration: const Duration(seconds: 2)),
      );
    }

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
    });
  }

  Future<void> _startEncounter({bool isBoss = false}) async {
    _enemies.clear();
    _dyingEnemies.clear();
    _enemyOriginalIndices.clear();
    for (var c in _enemyChargeControllers.values) {
      c.dispose();
    }
    _enemyChargeControllers.clear();
    for (var c in _enemyAttackControllers.values) {
      c.dispose();
    }
    _enemyAttackControllers.clear();

    String mainName = "";
    if (isBoss && widget.activeBoss != null) {
      final enemy = Enemy(
        name: widget.activeBoss!.name,
        health: widget.activeBoss!.health,
        damage: widget.activeBoss!.damage,
        attackDelay: widget.activeBoss!.attackDelay,
        dodgeChance: widget.activeBoss!.dodgeChance,
        themeColor: widget.activeBoss!.themeColor,
      );
      _enemies.add(enemy);
      _enemyOriginalIndices[enemy] = 0;
      mainName = enemy.name;
    } else {
      int minEnemies = 1 + (widget.stats.reputation / 30).floor();
      int maxEnemies = 3 + (widget.stats.reputation / 15).floor();
      maxEnemies = maxEnemies.clamp(1, 8);
      minEnemies = minEnemies.clamp(1, maxEnemies);

      int count = math.Random().nextInt(maxEnemies - minEnemies + 1) + minEnemies;
      for (int i = 0; i < count; i++) {
        _enemyNumber++;
        final enemy = GhettoEnemyFactory.generateRandomEnemy(_enemyNumber, widget.stats);
        _enemies.add(enemy);
        _enemyOriginalIndices[enemy] = i;
        if (i == 0) mainName = enemy.name;
      }
    }

    for (var enemy in _enemies) {
      _enemyChargeControllers[enemy] = AnimationController(vsync: this, duration: enemy.attackDelay);
      _enemyAttackControllers[enemy] = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    }

    _scrollController.stop();
    _walkController.value = 0.5;
    _walkController.stop();
    _trainingTimer?.cancel();

    setState(() {
      _introEnemyName = mainName;
      _isIntroAnimating = true;
    });

    await _introController.forward(from: 0);
    
    if (mounted) {
      setState(() {
        _isIntroAnimating = false;
        
        if (isBoss) {
          _isFighting = true;
          _isEnemyDying = false;
          _isRecruiting = false;
          _enemyWasHit = true; 
          _playerWasHit = false;
          _playerWasDefeated = false;
          _playerMissed = false;
          _isResting = false;
        } else {
          _isEncounterChoice = true;
        }
      });
      
      if (isBoss) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _enemyWasHit = false);
        });

        Future.microtask(() { if (mounted) widget.onNewEnemyApproached(); });
        
        _schedulePlayerAttack();
        _startAllyCombat();
        for (var enemy in _enemies) {
          _startEnemyCharge(enemy);
        }
      }
    }
  }

  void _onChooseFight() {
    setState(() {
      _isEncounterChoice = false;
      _isFighting = true;
      _isEnemyDying = false;
      _isRecruiting = false;
      _enemyWasHit = true; 
      _playerWasHit = false;
      _playerWasDefeated = false;
      _playerMissed = false;
      _isResting = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    Future.microtask(() { if (mounted) widget.onNewEnemyApproached(); });
    
    _schedulePlayerAttack();
    _startAllyCombat();
    for (var enemy in _enemies) {
      _startEnemyCharge(enemy);
    }
  }

  void _onChooseTalk() {
    setState(() {
      _isEncounterChoice = false;
      _isTalking = true;
      _currentDialogue = _randomInfo[math.Random().nextInt(_randomInfo.length)];
    });
  }

  void _onFinishTalking() {
    setState(() {
      _isTalking = false;
      _enemies.clear();
      _scrollController.repeat();
      _walkController.repeat(reverse: true);
    });
    widget.onStatsGained(reputation: 0.2);
    widget.onMoneyGained?.call(2);
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_isFighting && !_isRecruiting && !_isAtHome && !_isResting && !_isEncounterChoice && !_isTalking) {
        _startEncounter();
      }
    });
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
    for (var ally in _allies) {
      _scheduleAllyAttack(ally);
    }
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
      if (target.hp <= 0) {
        _handleEnemyDefeat(target);
      }
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    if (_isEnemyDying && _enemies.isEmpty) {
      _enterRecruitmentPhase();
    }
  }

  void _handleEnemyDefeat(Enemy enemy) {
    _enemyChargeControllers[enemy]?.stop();
    _enemyAttackControllers[enemy]?.stop(); 
    _enemies.remove(enemy);
    _dyingEnemies.add(enemy);

    widget.onMoneyGained?.call(15 + (widget.bossIndex * 5));

    if (_enemies.isEmpty) {
      _isFighting = false;
      _isEnemyDying = true;
    }
  }

  void _enterRecruitmentPhase() {
    setState(() {
      _isRecruiting = true;
    });
    widget.onStatsGained(reputation: 1.0);
  }

  void _onRecruitTapped(Enemy enemy) {
    if (!_isRecruiting) return;
    _recruitAlly(enemy);
    setState(() {
      _dyingEnemies.remove(enemy);
    });
  }

  void _dismissAlly(Ally ally) {
    setState(() {
      _allies.remove(ally);
      _allyChargeControllers[ally]?.dispose();
      _allyChargeControllers.remove(ally);
      _allyAttackControllers[ally]?.dispose();
      _allyAttackControllers.remove(ally);
    });
  }

  void _finishRecruitment() async {
    setState(() {
      _isRecruiting = false;
      _isEnemyDying = false;
      _dyingEnemies.clear();
    });
    
    await _deathController.forward(from: 0);
    if (mounted) {
      if (widget.activeBoss != null) widget.onBossDefeated?.call();
      _stopAllCombatAnimations();
      setState(() {
        _isFighting = false;
        _isResting = false; 
        _scrollController.stop();
        _walkController.stop();
        _walkController.value = 0;
      });
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
      if (target.hp <= 0) {
        _handleEnemyDefeat(target);
      }
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
      _enterRecruitmentPhase();
    }
  }

  Future<void> _enemyAttackPlayer(Enemy enemy) async {
    if (!_isFighting || _isEnemyDying || !_enemies.contains(enemy)) return;
    
    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted || !_isFighting || _isEnemyDying || !_enemies.contains(enemy)) return;

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

  bool _payDodgeCost() {
    if (widget.onStaminaSpent(5)) return true;
    if (widget.playerHunger >= 2) {
      widget.onNeedsRecovered(stamina: 0, hunger: -2);
      return true;
    }
    widget.onStatsGained(strength: 0, speed: 0, endurance: 0.25);
    return false;
  }

  Future<void> _enemyAttackAlly(Enemy enemy, Ally ally) async {
    if (!_isFighting || _isEnemyDying || ally.hp <= 0 || !_enemies.contains(enemy)) return;
    
    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted || !_isFighting || _isEnemyDying || !_allies.contains(ally) || !_enemies.contains(enemy)) return;

    int damage = CombatEngine.calculateEnemyDamage(enemy.damage, _isLowHunger);
    setState(() {
      ally.hp = (ally.hp - damage).clamp(0, ally.maxHp);
    });
  }

  Future<void> _handlePlayerDefeated() async {
    _stopAllCombatAnimations();
    widget.onPlayerDefeated();

    setState(() {
      for (var enemy in _enemies) { enemy.hp = enemy.maxHp; }
      for (var ally in _allies) { ally.hp = ally.maxHp; }

      _isFighting = false;
      _isEnemyDying = false;
      _playerWasDefeated = true;
    });

    await _defeatController.forward(from: 0);

    if (mounted) {
      _startHomeLogic(); 
    }
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
    _introController.dispose();
    _transitionController.dispose();
    _defeatController.dispose();
    for (var c in _allyChargeControllers.values) {
      c.dispose();
    }
    for (var c in _allyAttackControllers.values) {
      c.dispose();
    }
    for (var c in _enemyChargeControllers.values) {
      c.dispose();
    }
    for (var c in _enemyAttackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isIdle = !_isFighting && !_isEnemyDying && !_playerWasDefeated && !_isRecruiting && !_isIntroAnimating && !_isTransitioning && !_isEncounterChoice && !_isTalking;

    return Stack(
      children: [
        GhettoBackground(scrollAnimation: _scrollController, sceneWidth: sceneWidth),
        
        if (_isAtHome && !_isTransitioning)
          const GhettoSafeHouseOverlay(),

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
          isDefeated: _playerWasDefeated,
        ),
        
        if (!_isAtHome)
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
            index: _enemyOriginalIndices[enemy] ?? 0,
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
            onTap: () => _onRecruitTapped(enemy),
          ),

        Positioned(
          top: 80, left: 20, right: 20,
          child: PlayerHealthBar(
            health: widget.playerHealth,
            maxHealth: widget.playerMaxHealth,
            stamina: widget.playerStamina,
            maxStamina: widget.stats.maxStamina,
            hunger: widget.playerHunger,
            maxHunger: widget.stats.maxHunger,
            reputation: widget.stats.reputation,
            wasHit: _playerWasHit,
            damage: widget.stats.attackDamage,
            dodge: (widget.stats.dodgeChance * 100).toInt(),
            gangCapacity: widget.stats.gangCapacity,
          ),
        ),
        
        if (isIdle)
          Positioned(
            bottom: 120, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isAtHome) ...[
                   ActionCard(
                    icon: Icons.logout,
                    label: "EXIT",
                    onTap: _exitHouse,
                    color: Colors.redAccent,
                  ),
                ] else ...[
                   ActionCard(
                    icon: Icons.home,
                    label: "ENTER HOUSE",
                    onTap: _enterHouse,
                    color: Colors.blueGrey,
                  ),
                  ActionCard(
                    icon: Icons.search,
                    label: "EXPLORE",
                    onTap: _startExploring,
                    color: Colors.blueAccent,
                  ),
                ],
              ],
            ),
          ),
        
        GhettoHungerIndicator(isLowHunger: _isLowHunger, isCriticalHunger: _isCriticalHunger),
        
        if (_playerMissed)
          const Positioned(bottom: 120, left: 100, child: Text('MISS!', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16))),

        GhettoBattleStatusOverlay(
          isEnemyDying: _isEnemyDying, 
          playerWasDefeated: _playerWasDefeated, 
          isBoss: widget.activeBoss != null,
          isRecruiting: _isRecruiting,
        ),

        if (!_isFighting && !_isRecruiting && !_isEnemyDying && !_playerWasDefeated && widget.activeBoss == null && _isBossReady && _isAtHome)
          Positioned(
            bottom: 220,
            right: 20,
            child: FightBossButton(
              onPressed: () => widget.onStartBossFight?.call(),
              nextBossName: gameBosses[widget.bossIndex % gameBosses.length].name,
            ),
          ),

        if (_isIntroAnimating)
          CinematicSlamOverlay(
            animation: _introController, 
            title: _introEnemyName,
            subtitle: "Ghetto District",
          ),

        if (_isEncounterChoice)
          EncounterChoiceOverlay(
            npcName: _introEnemyName,
            onFight: _onChooseFight,
            onTalk: _onChooseTalk,
          ),

        if (_isTalking)
          EncounterTalkOverlay(
            infoText: _currentDialogue,
            onLeave: _onFinishTalking,
          ),

        if (_isRecruiting)
          GhettoRecruitmentOverlay(
            allies: _allies,
            dyingEnemies: _dyingEnemies,
            gangCapacity: widget.stats.gangCapacity,
            hitController: _playerHitController,
            onRecruitTapped: _onRecruitTapped,
            onDismissAlly: _dismissAlly,
            onFinishRecruitment: _finishRecruitment,
          ),

        if (_playerWasDefeated)
          CinematicSlamOverlay(
            animation: _defeatController,
            title: "Washed Out",
            subtitle: "Ghetto Streets",
            titleColor: Colors.red,
            accentColor: Colors.black,
          ),

        if (_isTransitioning)
          GhettoTransitionOverlay(animation: _transitionController),
      ],
    );
  }
}
