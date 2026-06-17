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

  bool recruitGangMember(Ally ally) {
    if (!hasGang || gangMemberCapacity <= 0) return false;
    if (_gangMembers.contains(ally)) return true;
    if (_gangMembers.length >= gangMemberCapacity) {
      _gangMembers.sort((a, b) => (a.atk + a.maxHp).compareTo(b.atk + b.maxHp));
      _gangMembers.removeAt(0);
    }
    _gangMembers.add(ally);
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

  bool recruitRandomExclusiveMember() {
    if (!hasGang || _gangMembers.length >= gangMemberCapacity) return false;
    const cost = 250;
    if (_money < cost) return false;

    _money -= cost;
    _gangMembers.add(_createExclusiveMember());
    notifyListeners();
    return true;
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
