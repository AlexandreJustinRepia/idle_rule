import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';
import '../../models/world_session.dart';
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

enum _DamageIndicatorTarget { player, enemy }

class _DamageIndicator {
  final int id;
  final int amount;
  final _DamageIndicatorTarget target;
  final int targetIndex;

  const _DamageIndicator({
    required this.id,
    required this.amount,
    required this.target,
    this.targetIndex = 0,
  });
}

class GhettoEnvironment extends StatefulWidget {
  final PlayerStats stats;
  final int playerHealth;
  final int playerMaxHealth;
  final double playerStamina;
  final double playerMaxStamina;
  final double playerHunger;
  final double playerMaxHunger;
  final String backgroundAsset;
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
  final GameCharacterSession? activePlayerChallenge;
  final VoidCallback? onPlayerChallengeDefeated;
  final void Function(int amount)? onMoneyGained;
  final bool hasGang;
  final List<Ally> gangMembers;
  final bool isPlayerInFormation;
  final bool Function(Ally ally)? onGangMemberRecruited;
  final void Function(Ally ally)? onGangMemberDismissed;
  final PendingTurfConquest? pendingTurfConquest;
  final TurfAttackResult Function(String territoryId)?
  onSoloTurfConquestCleared;
  final TurfAttackResult Function(String territoryId)? onSoloTurfConquestFailed;
  final bool hasSafeHouse;
  final bool isHostileStreet;
  final List<Gang> rivalGangs;
  final bool isActive;
  final CharacterCustomization? customization;
  final String? streetControllingGangName;

  const GhettoEnvironment({
    super.key,
    required this.stats,
    required this.playerHealth,
    required this.playerMaxHealth,
    required this.playerStamina,
    required this.playerMaxStamina,
    required this.playerHunger,
    required this.playerMaxHunger,
    this.backgroundAsset = 'assets/background/ghetto.png',
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
    this.activePlayerChallenge,
    this.onPlayerChallengeDefeated,
    this.onMoneyGained,
    this.hasGang = false,
    this.gangMembers = const [],
    this.isPlayerInFormation = true,
    this.onGangMemberRecruited,
    this.onGangMemberDismissed,
    this.pendingTurfConquest,
    this.onSoloTurfConquestCleared,
    this.onSoloTurfConquestFailed,
    this.hasSafeHouse = false,
    this.isHostileStreet = false,
    this.rivalGangs = const [],
    required this.isActive,
    this.customization,
    this.streetControllingGangName,
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
  bool _isDefeatAnimating = false;
  bool _playerMissed = false;
  bool _isResting = true;
  bool _isAtHome = true;
  bool _isEncounterChoice = false;
  bool _isTalking = false;
  bool _isConquestEncounter = false;
  bool _civilianFightProvoked = false;
  bool _isPlayerChallenge = false;
  String _currentDialogue = "";
  String _talkState = "choices";



  final List<Ally> _allies = [];
  final List<Enemy> _enemies = [];
  final List<Enemy> _dyingEnemies = [];

  final Map<Ally, AnimationController> _allyChargeControllers = {};
  final Map<Ally, AnimationController> _allyAttackControllers = {};
  final Map<Enemy, AnimationController> _enemyChargeControllers = {};
  final Map<Enemy, AnimationController> _enemyAttackControllers = {};
  final Map<Enemy, int> _enemyOriginalIndices = {};

  final Map<Ally, Offset> _allySpawnOffsets = {};
  final Set<Ally> _initializedAllies = {};

  int _enemyNumber = 0;
  double _encounterTotalThreat = 0;
  Timer? _attackTimer;
  Timer? _trainingTimer;
  String _introEnemyName = "";
  dynamic _selectedCombatant;
  Enemy? _playerTarget;
  String? _activeSoloConquestId;
  int _nextDamageIndicatorId = 1;
  final List<_DamageIndicator> _damageIndicators = [];

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
    _initializedAllies.addAll(_allies);
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
    if (widget.pendingTurfConquest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startSoloTurfConquest(widget.pendingTurfConquest!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant GhettoEnvironment oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pending = widget.pendingTurfConquest;
    if (pending != null &&
        pending.territoryId != oldWidget.pendingTurfConquest?.territoryId &&
        pending.territoryId != _activeSoloConquestId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startSoloTurfConquest(pending);
      });
    }

    if (!widget.hasSafeHouse && oldWidget.hasSafeHouse && _isAtHome) {
      setState(() {
        _isAtHome = false;
        _isResting = false;
        _isTransitioning = false;
        _scrollController.stop();
        _walkController.stop();
        _walkController.value = 0;
      });
    }

    final bossJustActivated =
        widget.activeBoss != null && oldWidget.activeBoss == null;
    final playerChallengeJustActivated =
        widget.activePlayerChallenge != null &&
        oldWidget.activePlayerChallenge == null;

    if (playerChallengeJustActivated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isFighting ||
            _isRecruiting ||
            _isEnemyDying ||
            _playerWasDefeated ||
            _isIntroAnimating ||
            _isTransitioning ||
            _isEncounterChoice ||
            _isTalking) {
          return;
        }
        final challenge = widget.activePlayerChallenge;
        if (challenge == null) return;
        if (_isAtHome) {
          _exitHouse().then((_) {
            if (mounted) _startEncounter(playerChallenge: challenge);
          });
        } else {
          _startEncounter(playerChallenge: challenge);
        }
      });
    } else if (bossJustActivated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isFighting ||
            _isRecruiting ||
            _isEnemyDying ||
            _playerWasDefeated ||
            _isIntroAnimating ||
            _isTransitioning ||
            _isEncounterChoice ||
            _isTalking) {
          return;
        }
        if (_isAtHome) {
          _exitHouse().then((_) {
            if (mounted) _startEncounter(isBoss: true);
          });
        } else {
          _startEncounter(isBoss: true);
        }
      });
    }

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
      if (!_initializedAllies.contains(ally)) {
        _assignSpawnOffset(ally);
      }
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

  String _introSlamTitle() {
    if (_enemies.isEmpty) return _introEnemyName;
    final enemy = _enemies.first;
    if (enemy.isBoss) return 'Boss';

    switch (enemy.npcType) {
      case NpcType.civilian:
        return 'Civilian';
      case NpcType.thug:
        return 'Thug';
      case NpcType.gangMember:
        return 'Gang Member';
      case NpcType.merchant:
        return 'Merchant';
      case NpcType.cop:
        return 'Cop';
      case NpcType.playerCharacter:
        return enemy.name;
    }
  }

  void _assignSpawnOffset(Ally ally) {
    final random = math.Random();
    final offset = Offset(
      random.nextDouble() * 280.0 + 20.0,
      random.nextDouble() * 200.0 + 20.0,
    );
    setState(() {
      _allySpawnOffsets[ally] = offset;
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _allySpawnOffsets.remove(ally);
        });
      }
    });
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
        !_isTalking &&
        !_walkController.isAnimating;

    final showSafeHouse = _isAtHome && !_isTransitioning && widget.hasSafeHouse;

    return Stack(
      children: [
        if (showSafeHouse)
          const GhettoSafeHouseOverlay()
        else
          GhettoBackground(
            scrollAnimation: _scrollController,
            sceneWidth: sceneWidth,
            backgroundAsset: widget.backgroundAsset,
          ),

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
            spawnOffset: _allySpawnOffsets[_allies[i]],
            onTap: () {
              if (!_isFighting || _allies[i].hp <= 0) return;
              setState(() {
                _selectedCombatant = _selectedCombatant == _allies[i]
                    ? null
                    : _allies[i];
              });
            },
          ),

        if (widget.isPlayerInFormation)
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
            customization: widget.customization,
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
              isBoss: _enemies[i].isBoss,
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

        for (final indicator in _damageIndicators)
          _DamageIndicatorView(
            key: ValueKey(indicator.id),
            indicator: indicator,
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
                  if (widget.hasSafeHouse)
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
            title: _introSlamTitle(),
            subtitle: "Territory Raid",
          ),

        if (_isEncounterChoice)
          EncounterChoiceOverlay(
            npcName: _introEnemyName,
            npcType: _enemies.isNotEmpty ? _enemies.first.npcType : NpcType.civilian,
            gangName: _enemies.isNotEmpty && _enemies.first.npcType == NpcType.gangMember 
                ? (_isConquestEncounter ? "Rival Gang" : widget.streetControllingGangName) 
                : null,
            onFight: _onChooseFight,
            onTalk: _isConquestEncounter ? null : _onChooseTalk,
          ),

        if (_isTalking)
          EncounterTalkOverlay(
            npcName: _enemies.isNotEmpty ? _enemies.first.name : "Stranger",
            npcType: _enemies.isNotEmpty ? _enemies.first.npcType : NpcType.civilian,
            gangName: _enemies.isNotEmpty && _enemies.first.npcType == NpcType.gangMember 
                ? (_isConquestEncounter ? "Rival Gang" : widget.streetControllingGangName) 
                : null,
            infoText: _currentDialogue,
            talkState: _talkState,
            onProvoke: () {
              final npcType = _enemies.isNotEmpty ? _enemies.first.npcType : NpcType.civilian;
              String msg = "What did you say to me, punk?! You're dead meat!";
              if (npcType == NpcType.civilian) {
                msg = "P-please don't hurt me! But if you force me, I will fight back!";
              } else if (npcType == NpcType.cop) {
                msg = "You are assaulting a peace officer! Stand down, or face the consequences!";
              } else if (npcType == NpcType.merchant) {
                msg = "Messing with a hard worker? I will protect my stand with my life!";
              }
              setState(() {
                _talkState = "provoked";
                _currentDialogue = msg;
              });
            },
            onCompliment: () {
              final npcType = _enemies.isNotEmpty ? _enemies.first.npcType : NpcType.civilian;
              String msg = "Haha, thanks! You've got good taste. Here, take some cash.";
              double repGain = 0.5;
              int moneyGain = 12;
              
              if (npcType == NpcType.civilian) {
                msg = "Oh, thank you! Most people around here are so aggressive. Here is a small token.";
                repGain = 0.3;
                moneyGain = 6;
              } else if (npcType == NpcType.cop) {
                msg = "Just doing my civic duty. Keep the peace and watch your back out here.";
                repGain = 1.0;
                moneyGain = 0;
              } else if (npcType == NpcType.merchant) {
                msg = "Ah, you appreciate quality! Tell you what, take this energy boost on the house.";
                repGain = 0.4;
                moneyGain = 0;
                widget.onNeedsRecovered(stamina: 25.0, hunger: 0.0);
              } else if (npcType == NpcType.gangMember) {
                msg = "Heh, you're not so bad for a newcomer. Don't let me catch you on the turf though.";
                repGain = 0.6;
                moneyGain = 8;
              }
              
              setState(() {
                _talkState = "complimented";
                _currentDialogue = msg;
              });
              if (repGain > 0) widget.onStatsGained(reputation: repGain);
              if (moneyGain > 0) widget.onMoneyGained?.call(moneyGain);
            },
            onRecruit: () {
              final npcType = _enemies.isNotEmpty ? _enemies.first.npcType : NpcType.civilian;
              if (npcType == NpcType.cop) {
                setState(() {
                  _talkState = "provoked";
                  _currentDialogue = "Are you attempting to bribe and recruit a police officer?! That is a felony!";
                });
                return;
              }
              
              if (npcType == NpcType.civilian) {
                setState(() {
                  _talkState = "recruitFailed";
                  _currentDialogue = "I'm just a regular resident. I don't want to get involved in gang activities.";
                });
                return;
              }
              
              if (npcType == NpcType.merchant) {
                setState(() {
                  _talkState = "recruitFailed";
                  _currentDialogue = "And leave my profitable shop? No way, boss. Business is too good.";
                });
                return;
              }

              if (npcType == NpcType.gangMember && widget.stats.reputation < 35.0) {
                setState(() {
                  _talkState = "provoked";
                  _currentDialogue = "Your reputation is pathetic! Why would I join a weak crew like yours? Let's fight!";
                });
                return;
              }
              
              if (widget.hasGang && _allies.length < _effectiveGangCapacity) {
                final npcToRecruit = _enemies.isNotEmpty ? _enemies.first : null;
                if (npcToRecruit != null) {
                  _recruitAlly(npcToRecruit);
                  setState(() {
                    _talkState = "recruited";
                    _currentDialogue = npcType == NpcType.gangMember
                        ? "Fine, you look like a leader with a future. Let's conquer the turf."
                        : "Alright, boss. Let's make some serious money together!";
                  });
                } else {
                  setState(() {
                    _talkState = "recruitFailed";
                    _currentDialogue = "No one here to recruit, boss.";
                  });
                }
              } else {
                setState(() {
                  _talkState = "recruitFailed";
                  _currentDialogue = !widget.hasGang 
                      ? "Create a crew first, then we'll talk." 
                      : "No room in your crew, boss. Let know when you have space.";
                });
              }
            },
            onLeave: () {
              if (_talkState == "provoked") {
                _onChooseFight();
              } else {
                _onFinishTalking();
              }
            },
            canRecruit: widget.hasGang && _allies.length < _effectiveGangCapacity,
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

        if (_isDefeatAnimating)
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

class _DamageIndicatorView extends StatelessWidget {
  final _DamageIndicator indicator;

  const _DamageIndicatorView({super.key, required this.indicator});

  @override
  Widget build(BuildContext context) {
    final isPlayer = indicator.target == _DamageIndicatorTarget.player;
    final right = (72.0 + indicator.targetIndex * 12.0)
        .clamp(0.0, 220.0)
        .toDouble();
    final bottom = isPlayer
        ? 168.0
        : 182.0 + (indicator.targetIndex.isEven ? 10.0 : -4.0);

    return Positioned(
      left: isPlayer ? 78 : null,
      right: isPlayer ? null : right,
      bottom: bottom,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final opacity = value < 0.72 ? 1.0 : (1.0 - value) / 0.28;
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0).toDouble(),
              child: Transform.translate(
                offset: Offset(0, -34 * value),
                child: Transform.scale(
                  scale: 1.2 - value * 0.18,
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            '-${indicator.amount}',
            style: TextStyle(
              color: isPlayer ? Colors.redAccent : const Color(0xFFFFD54F),
              fontSize: isPlayer ? 24 : 22,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 8),
                Shadow(color: Colors.black, offset: Offset(1, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

