import 'package:flutter/material.dart';
import '../game_state.dart';

class GameController extends ChangeNotifier {
  PlayerStats _stats = const PlayerStats();
  int _playerHealth = 30;
  late double _playerStamina;
  late double _playerHunger;
  Boss? _activeBoss;
  int _bossIndex = 0;

  GameController() {
    _playerStamina = _stats.maxStamina;
    _playerHunger = _stats.maxHunger;
  }

  PlayerStats get stats => _stats;
  int get playerHealth => _playerHealth;
  double get playerStamina => _playerStamina;
  double get playerHunger => _playerHunger;
  Boss? get activeBoss => _activeBoss;
  int get bossIndex => _bossIndex;

  void gainStats({double strength = 0, double speed = 0, double endurance = 0}) {
    final previousMaxStamina = _stats.maxStamina;
    final previousMaxHunger = _stats.maxHunger;
    
    _stats = _stats.gain(strength: strength, speed: speed, endurance: endurance);
    
    _playerHealth = _playerHealth.clamp(0, _stats.maxHealth).toInt();
    _playerStamina = (_playerStamina + (_stats.maxStamina - previousMaxStamina)).clamp(0, _stats.maxStamina);
    _playerHunger = (_playerHunger + (_stats.maxHunger - previousMaxHunger)).clamp(0, _stats.maxHunger);
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
    _playerHealth = _stats.maxHealth;
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
    notifyListeners();
  }
}
