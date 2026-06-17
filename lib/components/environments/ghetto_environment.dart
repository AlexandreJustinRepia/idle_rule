import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game_state.dart';
import '../../logic/combat_engine.dart';
import '../../logic/combat_stat_rewards.dart';
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
part 'ghetto/ghetto_environment_actions.dart';

class GhettoEnvironment extends StatefulWidget {
  final PlayerStats stats;
  final int playerHealth;
  final int playerMaxHealth;
  final double playerStamina;
  final double playerMaxStamina;
  final double playerHunger;
  final double playerMaxHunger;
  final void Function({
    double strength,
    double speed,
    double endurance,
    double reputation,
  })
  onStatsGained;
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
  final bool hasGang;
  final List<Ally> gangMembers;
  final bool Function(Ally ally)? onGangMemberRecruited;
  final void Function(Ally ally)? onGangMemberDismissed;

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
    this.hasGang = false,
    this.gangMembers = const [],
    this.onGangMemberRecruited,
    this.onGangMemberDismissed,
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
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;

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
  double _encounterTotalThreat = 0;
  Timer? _attackTimer;
  Timer? _trainingTimer;
  String _introEnemyName = "";
  dynamic _selectedCombatant;
  Enemy? _playerTarget;

  // Combat and encounter actions are implemented in the _GhettoEnvironmentActions extension.

  @override
  void initState() {
    super.initState();

    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _playerHitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _deathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _defeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _idleAnimation = CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    );

    _allies.addAll(widget.gangMembers);
    for (final ally in _allies) {
      _allyChargeControllers[ally] = AnimationController(
        vsync: this,
        duration: ally.attackDelay,
      );
      _allyAttackControllers[ally] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    }

    _startHomeLogic();
  }

  @override
  void didUpdateWidget(covariant GhettoEnvironment oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final ally in widget.gangMembers) {
      if (_allies.contains(ally)) continue;
      _allies.add(ally);
      _allyChargeControllers[ally] = AnimationController(
        vsync: this,
        duration: ally.attackDelay,
      );
      _allyAttackControllers[ally] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void dispose() {
    _attackTimer?.cancel();
    _trainingTimer?.cancel();
    _scrollController.dispose();
    _walkController.dispose();
    _attackController.dispose();
    _playerHitController.dispose();
    _deathController.dispose();
    _introController.dispose();
    _transitionController.dispose();
    _defeatController.dispose();
    _idleController.dispose();
    for (final controller in _allyChargeControllers.values) {
      controller.dispose();
    }
    for (final controller in _allyAttackControllers.values) {
      controller.dispose();
    }
    for (final controller in _enemyChargeControllers.values) {
      controller.dispose();
    }
    for (final controller in _enemyAttackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isIdle =
        !_isFighting &&
        !_isEnemyDying &&
        !_playerWasDefeated &&
        !_isRecruiting &&
        !_isIntroAnimating &&
        !_isTransitioning &&
        !_isEncounterChoice &&
        !_isTalking;

    return Stack(
      children: [
        GhettoBackground(
          scrollAnimation: _scrollController,
          sceneWidth: sceneWidth,
        ),

        if (_isAtHome && !_isTransitioning) const GhettoSafeHouseOverlay(),

        for (int i = 0; i < _allies.length; i++)
          GhettoAllyUnit(
            index: i,
            ally: _allies[i],
            walkAnimation: _walkController,
            attackAnimation:
                _allyAttackControllers[_allies[i]] ?? _attackController,
            chargeAnimation: _allyChargeControllers[_allies[i]],
            idleAnimation: _idleAnimation,
            isFighting: _isFighting,
            isSelected: _selectedCombatant == _allies[i],
            onTap: () {
              if (!_isFighting || _allies[i].hp <= 0) return;
              setState(() {
                _selectedCombatant = _selectedCombatant == _allies[i]
                    ? null
                    : _allies[i];
              });
            },
          ),

        GhettoHeroUnit(
          walkAnimation: _walkController,
          attackAnimation: _attackController,
          enemyAttackAnimation: _playerHitController,
          idleAnimation: _idleAnimation,
          isFighting: _isFighting,
          wasHit: _playerWasHit,
          missed: _playerMissed,
          isDefeated: widget.playerHealth <= 0 || _playerWasDefeated,
          isSelected: _selectedCombatant == 'player',
          onTap: () {
            if (!_isFighting || widget.playerHealth <= 0) return;
            setState(() {
              _selectedCombatant = _selectedCombatant == 'player'
                  ? null
                  : 'player';
            });
          },
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
              enemyAttackAnimation:
                  _enemyAttackControllers[_enemies[i]] ?? _playerHitController,
              deathAnimation: _deathController,
              enemyChargeController:
                  _enemyChargeControllers[_enemies[i]] ?? _playerHitController,
              idleAnimation: _idleAnimation,
              onTap: _attackEnemy,
              isBoss: widget.activeBoss != null && i == 0,
              targetingColors: [
                if (_playerTarget == _enemies[i]) Colors.redAccent,
                ..._allies
                    .where((ally) => ally.target == _enemies[i] && ally.hp > 0)
                    .map((ally) => ally.themeColor),
              ],
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
            attackAnimation: const AlwaysStoppedAnimation<double>(0.0),
            enemyAttackAnimation: const AlwaysStoppedAnimation<double>(0.0),
            deathAnimation: const AlwaysStoppedAnimation<double>(0.0),
            enemyChargeController: const AlwaysStoppedAnimation<double>(0.0),
            idleAnimation: const AlwaysStoppedAnimation<double>(0.0),
            onTap: (_) => _onRecruitTapped(enemy),
          ),

        Positioned(
          top: 80,
          left: 20,
          right: 20,
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
            gangCapacity: _effectiveGangCapacity,
          ),
        ),

        if (isIdle)
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
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

        GhettoHungerIndicator(
          isLowHunger: _isLowHunger,
          isCriticalHunger: _isCriticalHunger,
        ),

        if (_playerMissed)
          const Positioned(
            bottom: 120,
            left: 100,
            child: Text(
              'MISS!',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),

        GhettoBattleStatusOverlay(
          isEnemyDying: _isEnemyDying,
          playerWasDefeated: _playerWasDefeated,
          isBoss: widget.activeBoss != null,
          isRecruiting: _isRecruiting,
        ),

        if (!_isFighting &&
            !_isRecruiting &&
            !_isEnemyDying &&
            !_playerWasDefeated &&
            widget.activeBoss == null &&
            _isBossReady &&
            _isAtHome)
          Positioned(
            bottom: 220,
            right: 20,
            child: FightBossButton(
              onPressed: () => widget.onStartBossFight?.call(),
              nextBossName:
                  gameBosses[widget.bossIndex % gameBosses.length].name,
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
            gangCapacity: _effectiveGangCapacity,
            hasGang: widget.hasGang,
            onRecruitTapped: _onRecruitTapped,
            onDismissDyingEnemy: _onDismissDyingEnemy,
            onDismissAlly: _dismissAlly,
            onAutoRecruit: _onAutoRecruit,
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
