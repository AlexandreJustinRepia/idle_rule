// ignore_for_file: invalid_use_of_protected_member

part of '../ghetto_environment.dart';

extension _GhettoEnvironmentActions on _GhettoEnvironmentState {
  bool get _isLowHunger =>
      PlayerNeedsLogic.isLowHunger(widget.playerHunger, widget.playerMaxHunger);
  bool get _isCriticalHunger => PlayerNeedsLogic.isCriticalHunger(
    widget.playerHunger,
    widget.playerMaxHunger,
  );
  bool get _isBossReady {
    return widget.stats.strength >= 25.0 && _allies.length >= 2 && _isAtHome;
  }

  int get _effectiveGangCapacity =>
      widget.hasGang ? widget.stats.gangCapacity : 0;
  bool get _isBossFight => widget.activeBoss != null;

  void _applyCombatGains({
    required double strength,
    required double speed,
    required double endurance,
  }) {
    if (strength == 0 && speed == 0 && endurance == 0) return;
    widget.onStatsGained(
      strength: strength,
      speed: speed,
      endurance: endurance,
    );
  }

  void _applyRewardBundle(
    ({double strength, double speed, double endurance}) gains,
  ) {
    _applyCombatGains(
      strength: gains.strength,
      speed: gains.speed,
      endurance: gains.endurance,
    );
  }

  Future<void> _startSoloTurfConquest(PendingTurfConquest request) async {
    if (_activeSoloConquestId == request.territoryId &&
        (_isFighting || _isIntroAnimating || _isRecruiting)) {
      return;
    }
    _activeSoloConquestId = request.territoryId;
    _isConquestEncounter = true;

    if (_isAtHome) {
      await _exitHouse();
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CLEAR ${request.territoryName.toUpperCase()} TO CLAIM IT SOLO',
        ),
        backgroundColor: const Color(0xFFE24B4A),
        duration: const Duration(milliseconds: 1800),
      ),
    );

    await _startEncounter(conquest: request);
  }

  void _finishSoloTurfConquest() {
    final territoryId = _activeSoloConquestId;
    if (territoryId == null) return;
    _activeSoloConquestId = null;

    final result = widget.onSoloTurfConquestCleared?.call(territoryId);
    if (result == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TURF SECURED - ${result.leaderReaction}'),
        backgroundColor: Colors.green[800],
        duration: const Duration(milliseconds: 2400),
      ),
    );
  }

  void _failSoloTurfConquest() {
    final territoryId = _activeSoloConquestId;
    if (territoryId == null) return;
    _activeSoloConquestId = null;

    final result = widget.onSoloTurfConquestFailed?.call(territoryId);
    if (result == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOLO RAID FAILED - ${result.leaderReaction}'),
        backgroundColor: Colors.red[900],
        duration: const Duration(milliseconds: 2400),
      ),
    );
  }

  void _startHomeLogic() {
    _stopAllCombatAnimations();
    setState(() {
      _isAtHome = true;
      _isResting = true;
      _isFighting = false;
      _isEnemyDying = false;
      _isRecruiting = false;
      _isIntroAnimating = false;
      _isTransitioning = false;
      _isEncounterChoice = false;
      _isTalking = false;
      _playerWasDefeated = false;
      _selectedCombatant = null;
      _playerTarget = null;
      _enemies.clear();
      _dyingEnemies.clear();
      _scrollController.stop();
      _walkController.stop();
      _walkController.value = 0;
    });

    _trainingTimer?.cancel();
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!widget.isActive) return;
      if (_isAtHome && _isResting) {
        double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(
          widget.playerHunger,
          widget.playerMaxHunger,
        );
        bool isRecovering = widget.playerStamina < widget.playerMaxStamina;
        double hungerDrain = isRecovering ? -0.15 : -0.05;
        widget.onNeedsRecovered(
          stamina: widget.stats.staminaRecovery * 4.0 * recoveryMult,
          hunger: hungerDrain,
        );

        if (widget.playerHealth < widget.playerMaxHealth) {
          widget.onPlayerDamaged(-(widget.playerMaxHealth * 0.08).ceil());
        }

        for (var ally in _allies) {
          if (ally.hp < ally.maxHp) {
            setState(() {
              ally.hp = (ally.hp + (ally.maxHp * 0.15).ceil()).clamp(
                0,
                ally.maxHp,
              );
            });
          }
        }
      } else if (!_isAtHome && !_isFighting && !_isRecruiting) {
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

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted &&
          !_isFighting &&
          !_isRecruiting &&
          !_isAtHome &&
          !_isResting) {
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
    if (!widget.hasGang) return;

    if (_allies.length >= _effectiveGangCapacity) {
      Ally weakest = _allies.reduce(
        (a, b) => (a.atk + a.maxHp) < (b.atk + b.maxHp) ? a : b,
      );
      _dismissAlly(weakest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('REPLACED ${weakest.name} WITH ${enemy.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final allyAtk = (enemy.damage * 0.5).floor().clamp(1, 999);
    final allyMaxHp = (enemy.health * 0.7).floor().clamp(1, 9999);
    final allyDelay = Duration(
      milliseconds: (enemy.attackDelay.inMilliseconds * 1.2).round(),
    );

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
      _allyChargeControllers[newAlly] = AnimationController(
        vsync: this,
        duration: newAlly.attackDelay,
      );
      _allyAttackControllers[newAlly] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });
    widget.onGangMemberRecruited?.call(newAlly);
  }

  Future<void> _startEncounter({
    bool isBoss = false,
    PendingTurfConquest? conquest,
  }) async {
    _enemies.clear();
    _dyingEnemies.clear();
    _enemyOriginalIndices.clear();
    _selectedCombatant = null;
    _playerTarget = null;
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
        isBoss: true,
      );
      _enemies.add(enemy);
      _enemyOriginalIndices[enemy] = 0;
      mainName = enemy.name;
    } else if (conquest != null) {
      Gang? occupyingGang;
      if (conquest.occupyingGangName != null) {
        try {
          occupyingGang = widget.rivalGangs.firstWhere(
            (g) => g.name == conquest.occupyingGangName,
          );
        } catch (_) {}
      }

      if (conquest.isBossChallenge) {
        final bossName = (occupyingGang?.leaderName.isNotEmpty == true)
            ? occupyingGang!.leaderName
            : '${conquest.occupyingGangName} Boss';
        final boss = Enemy(
          name: bossName,
          health: (120 + conquest.territoryDefense * 1.5).round(),
          damage: (12 + conquest.territoryDefense * 0.15).round(),
          attackDelay: const Duration(milliseconds: 1600),
          dodgeChance: 0.15,
          themeColor: occupyingGang?.primaryColor ?? Colors.redAccent,
          isBoss: true,
        );
        _enemies.add(boss);

        final guardCount = 2;
        final levelBase = (conquest.territoryDefense / 18).ceil().clamp(1, 99);
        for (int i = 0; i < guardCount; i++) {
          _enemyNumber++;
          final enemy = GhettoEnemyFactory.generateRandomEnemy(
            levelBase + i,
            widget.stats,
          );
          _enemies.add(enemy.copyWith(
            themeColor: occupyingGang?.primaryColor ?? enemy.themeColor,
          ));
        }
      } else {
        final count = (conquest.territoryDefense / 35).ceil().clamp(2, 8);
        final levelBase = (conquest.territoryDefense / 18).ceil().clamp(1, 99);
        for (int i = 0; i < count; i++) {
          _enemyNumber++;
          final enemy = GhettoEnemyFactory.generateRandomEnemy(
            levelBase + i,
            widget.stats,
          );
          _enemies.add(occupyingGang != null
              ? enemy.copyWith(themeColor: occupyingGang.primaryColor)
              : enemy);
        }
      }

      _enemies.sort((a, b) {
        final powerA = a.damage + a.health;
        final powerB = b.damage + b.health;
        return powerB.compareTo(powerA);
      });

      for (int i = 0; i < _enemies.length; i++) {
        _enemyOriginalIndices[_enemies[i]] = i;
      }
      // Show the names of the NPC gang members occupying the territory
      if (_enemies.isEmpty) {
        mainName = '${conquest.territoryName} Crew';
      } else if (_enemies.length == 1) {
        mainName = _enemies[0].name;
      } else if (_enemies.length == 2) {
        mainName = '${_enemies[0].name} & ${_enemies[1].name}';
      } else {
        final extra = _enemies.length - 2;
        mainName = '${_enemies[0].name}, ${_enemies[1].name} & $extra more';
      }
    } else {
      int minEnemies = 1 + (widget.stats.reputation / 30).floor();
      int maxEnemies = 3 + (widget.stats.reputation / 15).floor();
      maxEnemies = maxEnemies.clamp(1, 8);
      minEnemies = minEnemies.clamp(1, maxEnemies);

      int count =
          math.Random().nextInt(maxEnemies - minEnemies + 1) + minEnemies;
      for (int i = 0; i < count; i++) {
        _enemyNumber++;
        final enemy = GhettoEnemyFactory.generateRandomEnemy(
          _enemyNumber,
          widget.stats,
        );
        _enemies.add(enemy);
      }

      // Sort enemies so the strongest is at the front (index 0)
      _enemies.sort((a, b) {
        final powerA = a.damage + a.health;
        final powerB = b.damage + b.health;
        return powerB.compareTo(powerA);
      });

      // Reassign indices after sorting
      for (int i = 0; i < _enemies.length; i++) {
        _enemyOriginalIndices[_enemies[i]] = i;
        if (i == 0) mainName = _enemies[i].name;
      }
    }

    for (var enemy in _enemies) {
      _enemyChargeControllers[enemy] = AnimationController(
        vsync: this,
        duration: enemy.attackDelay,
      );
      _enemyAttackControllers[enemy] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
    }

    _encounterTotalThreat = CombatStatRewards.encounterThreat(_enemies);

    _scrollController.stop();
    _walkController.value = 0.5;
    _walkController.stop();
    _trainingTimer?.cancel();

    if (isBoss || conquest != null || widget.isHostileStreet) {
      setState(() {
        _introEnemyName = mainName;
        _isIntroAnimating = true;
      });

      await _introController.forward(from: 0);

      if (mounted) {
        setState(() {
          _isIntroAnimating = false;
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

        Future.microtask(() {
          if (mounted) widget.onNewEnemyApproached();
        });

        _schedulePlayerAttack();
        _startAllyCombat();
        for (var enemy in _enemies) {
          _startEnemyCharge(enemy);
        }
      }
    } else {
      setState(() {
        _introEnemyName = mainName;
        _isEncounterChoice = true;
        _isConquestEncounter = false;
      });
    }
  }

  Future<void> _onChooseFight() async {
    setState(() {
      _isEncounterChoice = false;
      _isIntroAnimating = true;
    });

    await _introController.forward(from: 0);

    if (mounted) {
      setState(() {
        _isIntroAnimating = false;
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

      Future.microtask(() {
        if (mounted) widget.onNewEnemyApproached();
      });

      _schedulePlayerAttack();
      _startAllyCombat();
      for (var enemy in _enemies) {
        _startEnemyCharge(enemy);
      }
    }
  }

  void _onChooseTalk() {
    if (_isConquestEncounter) {
      return;
    }
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
      if (mounted &&
          !_isFighting &&
          !_isRecruiting &&
          !_isAtHome &&
          !_isResting &&
          !_isEncounterChoice &&
          !_isTalking) {
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
    List<dynamic> aliveTargets = [];
    if (widget.isPlayerInFormation && widget.playerHealth > 0) {
      aliveTargets.add(null);
    }
    for (var ally in _allies) {
      if (ally.hp > 0) {
        aliveTargets.add(ally);
      }
    }

    if (aliveTargets.isEmpty) {
      _handlePlayerDefeated();
      return;
    }

    var target = aliveTargets[math.Random().nextInt(aliveTargets.length)];
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
      if (mounted && _isFighting && _allies.contains(ally) && ally.hp > 0) {
        _attackEnemyFromAlly(ally);
        _scheduleAllyAttack(ally);
      }
    });
  }

  Future<void> _attackEnemyFromAlly(Ally ally) async {
    if (!_isFighting || _enemies.isEmpty || ally.hp <= 0) return;

    Enemy target;
    if (ally.target is Enemy && _enemies.contains(ally.target)) {
      target = ally.target as Enemy;
    } else {
      target = _enemies.first;
    }

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
    if (_playerTarget == enemy) {
      _playerTarget = null;
    }
    for (var ally in _allies) {
      if (ally.target == enemy) {
        ally.target = null;
      }
    }

    widget.onMoneyGained?.call(15 + (widget.bossIndex * 5));

    _applyRewardBundle(CombatStatRewards.killBonus(enemy));

    if (_enemies.isEmpty) {
      _isFighting = false;
      _isEnemyDying = true;
    }
  }

  void _enterRecruitmentPhase() {
    setState(() {
      _isRecruiting = true;
    });
    widget.onStatsGained(
      reputation: CombatStatRewards.encounterReputationReward(
        _encounterTotalThreat,
      ),
    );
  }

  void _onRecruitTapped(Enemy enemy) {
    if (!_isRecruiting || !widget.hasGang) return;
    _recruitAlly(enemy);
    setState(() {
      _dyingEnemies.remove(enemy);
    });
  }

  double _recruitPower(Enemy enemy) {
    return enemy.damage * 0.5 + enemy.health * 0.7;
  }

  void _onAutoRecruit() {
    if (!_isRecruiting || _dyingEnemies.isEmpty || !widget.hasGang) return;

    final sorted = List<Enemy>.from(_dyingEnemies)
      ..sort((a, b) => _recruitPower(b).compareTo(_recruitPower(a)));

    final openSlots = _effectiveGangCapacity - _allies.length;
    final recruitCount = openSlots > 0 ? openSlots : 1;

    for (var i = 0; i < recruitCount && i < sorted.length; i++) {
      final enemy = sorted[i];
      if (!_dyingEnemies.contains(enemy)) continue;
      _onRecruitTapped(enemy);
    }
  }

  void _onDismissDyingEnemy(Enemy enemy) {
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
    widget.onGangMemberDismissed?.call(ally);
  }

  Future<void> _finishRecruitment() async {
    setState(() {
      _isRecruiting = false;
      _isEnemyDying = false;
      _dyingEnemies.clear();
    });

    await _deathController.forward(from: 0);
    if (mounted) {
      if (widget.activeBoss != null) widget.onBossDefeated?.call();
      if (_activeSoloConquestId != null) _finishSoloTurfConquest();
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
    if (!widget.isPlayerInFormation || widget.playerHealth <= 0) return;
    _attackTimer = Timer(widget.stats.attackDelay, () async {
      if (widget.playerHealth <= 0) return;
      await _autoAttackEnemy();
      if (mounted && _isFighting && widget.playerHealth > 0) {
        _schedulePlayerAttack();
      }
    });
  }

  Future<void> _attackEnemy(Enemy tappedEnemy) async {
    if (!widget.isPlayerInFormation) return;
    if (!_isFighting || _enemies.isEmpty) return;

    if (_selectedCombatant != null) {
      setState(() {
        if (_selectedCombatant == 'player') {
          _playerTarget = tappedEnemy;
        } else if (_selectedCombatant is Ally) {
          (_selectedCombatant as Ally).target = tappedEnemy;
        }
        _selectedCombatant = null;
      });
      return;
    }

    if (_allies.isEmpty) {
      setState(() {
        _playerTarget = tappedEnemy;
      });
    }

    if (_attackController.isAnimating) return;
    if (!widget.onStaminaSpent(8)) {
      _applyCombatGains(strength: 0, speed: 0, endurance: 0.2);
      return;
    }

    Enemy target = tappedEnemy;
    if (!_enemies.contains(target)) {
      target = _enemies.first;
    }

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
    if (!mounted || !_isFighting) {
      return;
    }

    int damage = CombatEngine.calculatePlayerDamage(widget.stats, _isLowHunger);
    setState(() {
      target.hp -= damage;
      _enemyWasHit = true;
      if (target.hp <= 0) {
        _handleEnemyDefeat(target);
      }
    });

    _applyRewardBundle(
      CombatStatRewards.perHitGains(
        target: target,
        activeEnemies: _enemies,
        isBossFight: _isBossFight,
      ),
    );

    if (_enemies.isNotEmpty &&
        CombatEngine.rollDodge(_enemies.first.counterChance)) {
      _onEnemyAttack(_enemies.first);
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _enemyWasHit = false);
    });

    if (_isEnemyDying && _enemies.isEmpty) {
      _enterRecruitmentPhase();
    }
  }

  Future<void> _autoAttackEnemy() async {
    if (!_isFighting || _attackController.isAnimating || _enemies.isEmpty) {
      return;
    }

    Enemy target;
    if (_playerTarget != null && _enemies.contains(_playerTarget)) {
      target = _playerTarget!;
    } else {
      target = _enemies.first;
    }

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
    if (!mounted || !_isFighting) {
      return;
    }

    int damage = CombatEngine.calculatePlayerDamage(widget.stats, _isLowHunger);
    setState(() {
      target.hp -= damage;
      _enemyWasHit = true;
      if (target.hp <= 0) {
        _handleEnemyDefeat(target);
      }
    });

    _applyRewardBundle(
      CombatStatRewards.perHitGains(
        target: target,
        activeEnemies: _enemies,
        isBossFight: _isBossFight,
      ),
    );

    if (_enemies.isNotEmpty &&
        CombatEngine.rollDodge(_enemies.first.counterChance)) {
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
    if (!_isFighting || _isEnemyDying || !_enemies.contains(enemy)) {
      return;
    }

    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted ||
        !_isFighting ||
        _isEnemyDying ||
        !_enemies.contains(enemy)) {
      return;
    }

    if (CombatEngine.rollDodge(widget.stats.dodgeChance) && _payDodgeCost()) {
      _applyRewardBundle(CombatStatRewards.dodgeGains(enemy));
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
    _applyRewardBundle(CombatStatRewards.damageTakenGains(enemy));

    double recoveryMult = PlayerNeedsLogic.getRecoveryMultiplier(
      widget.playerHunger,
      widget.playerMaxHunger,
    );
    widget.onNeedsRecovered(
      stamina: widget.stats.staminaRecovery * 0.35 * recoveryMult,
      hunger: -0.25,
    );

    setState(() => _playerWasHit = true);
    _playerHitController.forward(from: 0);
    if (willDefeatPlayer) {
      bool hasAliveAllies = _allies.any((ally) => ally.hp > 0);
      if (!hasAliveAllies) {
        _handlePlayerDefeated();
        return;
      }
    }

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _playerWasHit = false);
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
    _applyCombatGains(strength: 0, speed: 0, endurance: 0.15);
    return false;
  }

  Future<void> _enemyAttackAlly(Enemy enemy, Ally ally) async {
    if (!_isFighting ||
        _isEnemyDying ||
        ally.hp <= 0 ||
        !_enemies.contains(enemy)) {
      return;
    }

    final controller = _enemyAttackControllers[enemy] ?? _playerHitController;
    await controller.forward(from: 0);

    if (!mounted ||
        !_isFighting ||
        _isEnemyDying ||
        !_allies.contains(ally) ||
        !_enemies.contains(enemy)) {
      return;
    }

    int damage = CombatEngine.calculateEnemyDamage(enemy.damage, _isLowHunger);
    setState(() {
      ally.hp = (ally.hp - damage).clamp(0, ally.maxHp);
    });

    bool isPlayerDefeated = widget.playerHealth <= 0;
    bool hasAliveAllies = _allies.any((a) => a.hp > 0);
    if (isPlayerDefeated && !hasAliveAllies) {
      _handlePlayerDefeated();
    }
  }

  Future<void> _handlePlayerDefeated() async {
    _stopAllCombatAnimations();
    _failSoloTurfConquest();
    widget.onPlayerDefeated();

    setState(() {
      for (var enemy in _enemies) {
        enemy.hp = enemy.maxHp;
      }
      for (var ally in _allies) {
        ally.hp = ally.maxHp;
      }

      _isFighting = false;
      _isEnemyDying = false;
      _playerWasDefeated = true;
    });

    await _defeatController.forward(from: 0);

    if (mounted) {
      _startHomeLogic();
    }
  }
}
