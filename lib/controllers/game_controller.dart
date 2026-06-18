import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../game_state.dart';

class GameController extends ChangeNotifier {
  static final math.Random _random = math.Random();

  PlayerStats _stats = const PlayerStats();
  int _playerHealth = 30;
  late double _playerStamina;
  late double _playerHunger;
  int _money = 0;
  Boss? _activeBoss;
  int _bossIndex = 0;
  String _playerName = '';
  CharacterClass _characterClass = CharacterClasses.allClasses.first;
  Gang? _gang;
  final List<Ally> _gangMembers = [];

  GameController({
    String playerName = '',
    CharacterClass? characterClass,
    PlayerStats? initialStats,
  }) {
    _playerName = playerName;
    _characterClass = characterClass ?? CharacterClasses.allClasses.first;
    if (initialStats != null) {
      _stats = initialStats;
    }
    _playerHealth = _stats.maxHealth;
    _playerStamina = _stats.maxStamina;
    _playerHunger = _stats.maxHunger;
  }

  PlayerStats get stats => _stats;
  int get playerHealth => _playerHealth;
  double get playerStamina => _playerStamina;
  double get playerHunger => _playerHunger;
  int get money => _money;
  Boss? get activeBoss => _activeBoss;
  int get bossIndex => _bossIndex;
  String get playerName => _playerName;
  CharacterClass get characterClass => _characterClass;
  Gang? get gang => _gang;
  bool get hasGang => _gang != null;
  List<Ally> get gangMembers => List.unmodifiable(_gangMembers);
  int get gangMemberCapacity => hasGang ? _stats.gangCapacity : 0;
  int get gangTotalPower =>
      _gangMembers.fold(0, (total, member) => total + member.power);
  int get gangAttackPower =>
      _commandMembers.fold(0, (total, member) => total + member.power);
  int get recruitCrewCost => 40 + (_gangMembers.length * 3);
  int get trainCrewCost => _gangMembers
      .where((member) => member.canTrain)
      .fold(0, (total, member) => total + trainingCostFor(member));

  List<Ally> get _commandMembers {
    final sorted = [..._gangMembers]
      ..sort((a, b) => b.power.compareTo(a.power));
    return sorted.take(gangMemberCapacity).toList();
  }

  bool get meetsGangRequirements =>
      _money >= GangCreationRequirements.moneyCost &&
      _stats.reputation >= GangCreationRequirements.reputationRequired;

  bool createGang({
    required String name,
    required String emblemId,
    required Color primaryColor,
    required Color accentColor,
  }) {
    if (_gang != null) return false;
    if (!meetsGangRequirements) return false;

    final trimmed = name.trim();
    if (trimmed.length < 2) return false;

    _money -= GangCreationRequirements.moneyCost;
    _gang = Gang(
      name: trimmed.toUpperCase(),
      emblemId: emblemId,
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
    notifyListeners();
    return true;
  }

  int trainingCostFor(Ally ally) =>
      (ally.isExclusive ? 90 : 55) * (ally.trainingLevel + 1);

  bool trainGangMember(Ally ally) {
    if (!_gangMembers.contains(ally) || !ally.canTrain) return false;
    final cost = trainingCostFor(ally);
    if (_money < cost) return false;

    _money -= cost;
    ally.train();
    notifyListeners();
    return true;
  }

  bool trainAllGangMembers() {
    final trainableMembers = _gangMembers
        .where((member) => member.canTrain)
        .toList();
    final cost = trainableMembers.fold(
      0,
      (total, member) => total + trainingCostFor(member),
    );
    if (trainableMembers.isEmpty || _money < cost) return false;

    _money -= cost;
    for (final member in trainableMembers) {
      member.train();
    }
    notifyListeners();
    return true;
  }

  bool recruitGangMember(Ally ally) {
    if (!hasGang) return false;
    if (_gangMembers.contains(ally)) return true;
    _gangMembers.add(ally);
    notifyListeners();
    return true;
  }

  bool recruitCrewMembers({int count = 1}) {
    if (!hasGang || count <= 0) return false;
    final totalCost = recruitCrewCost * count;
    if (_money < totalCost) return false;

    _money -= totalCost;
    for (var i = 0; i < count; i++) {
      _gangMembers.add(_createCrewMember());
    }
    notifyListeners();
    return true;
  }

  void dismissGangMember(Ally ally) {
    if (_gangMembers.remove(ally)) {
      notifyListeners();
    }
  }

  Ally _createExclusiveMember() {
    const exclusiveNames = [
      'Kane Voss',
      'Mira Knox',
      'Jax Calder',
      'Rina Vale',
      'Dante Cruz',
      'Nyx Sol',
      'Ari Steel',
      'Vera Riot',
    ];
    final name = exclusiveNames[_random.nextInt(exclusiveNames.length)];
    final rankBoost = 1 + _random.nextInt(4);
    final hp = 42 + rankBoost * 10 + _random.nextInt(10);
    return Ally(
      name: name,
      hp: hp,
      maxHp: hp,
      atk: 4 + rankBoost * 2,
      attackDelay: Duration(milliseconds: 980 - rankBoost * 70),
      dodgeChance: 0.12 + rankBoost * 0.025,
      themeColor: Color.lerp(
        _gang?.primaryColor ?? Colors.purpleAccent,
        Colors.white,
        0.22,
      )!,
      isExclusive: true,
      maxTrainingLevel: 15,
    );
  }

  Ally _createCrewMember() {
    const crewNames = [
      'Street Soldier',
      'Corner Runner',
      'Block Enforcer',
      'Alley Scout',
      'Rookie Guard',
      'Turf Watcher',
    ];
    final name = crewNames[_random.nextInt(crewNames.length)];
    final reputationBoost = (_stats.reputation / 25).floor().clamp(0, 8);
    final hp = 24 + reputationBoost * 3 + _random.nextInt(10);
    return Ally(
      name: '$name ${_gangMembers.length + 1}',
      hp: hp,
      maxHp: hp,
      atk: 2 + reputationBoost + _random.nextInt(3),
      attackDelay: Duration(milliseconds: 1120 - reputationBoost * 25),
      dodgeChance: 0.06 + reputationBoost * 0.008,
      themeColor: _gang?.primaryColor ?? Colors.greenAccent,
      maxTrainingLevel: 8,
    );
  }

  bool recruitRandomExclusiveMember() {
    if (!hasGang) return false;
    const cost = 250;
    if (_money < cost) return false;

    _money -= cost;
    _gangMembers.add(_createExclusiveMember());
    notifyListeners();
    return true;
  }

  double turfTakeoverChance(int territoryDefense) {
    if (!hasGang || gangAttackPower <= 0) return 0;
    final chance = gangAttackPower / (gangAttackPower + territoryDefense);
    return chance.clamp(0.05, 0.95).toDouble();
  }

  bool attemptTurfTakeover(int territoryDefense) {
    if (!hasGang || _gangMembers.isEmpty) return false;
    final chance = turfTakeoverChance(territoryDefense);
    final succeeded = _random.nextDouble() <= chance;
    if (succeeded) {
      gainStats(reputation: 3);
      gainMoney((territoryDefense * 0.8).round());
    } else {
      _money = (_money - (territoryDefense * 0.12).round()).clamp(0, 999999);
      notifyListeners();
    }
    return succeeded;
  }

  void gainStats({
    double strength = 0,
    double speed = 0,
    double endurance = 0,
    double reputation = 0,
  }) {
    final previousMaxStamina = _stats.maxStamina;
    final previousMaxHunger = _stats.maxHunger;

    _stats = _stats.gain(
      strength: strength,
      speed: speed,
      endurance: endurance,
      reputation: reputation,
    );

    _playerHealth = _playerHealth.clamp(0, _stats.maxHealth).toInt();
    _playerStamina = (_playerStamina + (_stats.maxStamina - previousMaxStamina))
        .clamp(0, _stats.maxStamina);
    _playerHunger = (_playerHunger + (_stats.maxHunger - previousMaxHunger))
        .clamp(0, _stats.maxHunger);
    notifyListeners();
  }

  void gainMoney(int amount) {
    _money += amount;
    notifyListeners();
  }

  void debugSetPlayerValues({
    required int money,
    required double strength,
    required double speed,
    required double endurance,
    required double intelligence,
    required double potential,
    required double reputation,
  }) {
    final previousMaxStamina = _stats.maxStamina;
    final previousMaxHunger = _stats.maxHunger;

    _money = money.clamp(0, 999999).toInt();
    _stats = PlayerStats(
      strength: strength.clamp(0, PlayerStats.maxGradeValue).toDouble(),
      speed: speed.clamp(0, PlayerStats.maxGradeValue).toDouble(),
      endurance: endurance.clamp(0, PlayerStats.maxGradeValue).toDouble(),
      intelligence: intelligence.clamp(0, PlayerStats.maxGradeValue).toDouble(),
      potential: potential.clamp(0, PlayerStats.maxGradeValue).toDouble(),
      reputation: reputation.clamp(0, PlayerStats.maxGradeValue).toDouble(),
    );

    _playerHealth = _playerHealth.clamp(0, _stats.maxHealth).toInt();
    _playerStamina = (_playerStamina + (_stats.maxStamina - previousMaxStamina))
        .clamp(0, _stats.maxStamina);
    _playerHunger = (_playerHunger + (_stats.maxHunger - previousMaxHunger))
        .clamp(0, _stats.maxHunger);
    notifyListeners();
  }

  void takeDamage(int damage) {
    _playerHealth = (_playerHealth - damage).clamp(0, _stats.maxHealth).toInt();
    notifyListeners();
  }

  void recoverFromDefeat() {
    _playerHealth = _stats.maxHealth;
    _playerStamina = _stats.maxStamina;
    _playerHunger = _stats.maxHunger;
    _activeBoss = null;
    notifyListeners();
  }

  void recoverHealthForNewEnemy() {
    _playerHealth = _playerHealth.clamp(0, _stats.maxHealth).toInt();
    notifyListeners();
  }

  bool spendStamina(double amount) {
    if (_playerStamina < amount) return false;
    _playerStamina = (_playerStamina - amount).clamp(0, _stats.maxStamina);
    notifyListeners();
    return true;
  }

  void recoverNeeds({double stamina = 0, double hunger = 0}) {
    _playerStamina = (_playerStamina + stamina).clamp(0, _stats.maxStamina);
    _playerHunger = (_playerHunger + hunger).clamp(0, _stats.maxHunger);
    notifyListeners();
  }

  void startBossFight() {
    if (_activeBoss != null) return;
    _activeBoss = gameBosses[_bossIndex % gameBosses.length];
    _playerHealth = _stats.maxHealth;
    notifyListeners();
  }

  void onBossDefeated() {
    _activeBoss = null;
    _bossIndex++;
    // Bosses give a significant reputation and money boost
    gainStats(reputation: 25.0);
    gainMoney(500);
    notifyListeners();
  }

  bool buyItem({
    required int cost,
    double stamina = 0,
    double hunger = 0,
    int health = 0,
  }) {
    if (_money < cost) return false;
    _money -= cost;
    _playerStamina = (_playerStamina + stamina).clamp(0, _stats.maxStamina);
    _playerHunger = (_playerHunger + hunger).clamp(0, _stats.maxHunger);
    _playerHealth = (_playerHealth + health).clamp(0, _stats.maxHealth);
    notifyListeners();
    return true;
  }
}
