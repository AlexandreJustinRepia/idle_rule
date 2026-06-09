import 'dart:math' as math;
import '../models/player_stats.dart';

class CombatEngine {
  static final math.Random _random = math.Random();

  static int calculatePlayerDamage(PlayerStats stats, bool isLowHunger) {
    int damage = stats.attackDamage;
    return isLowHunger ? (damage * 0.8).floor().clamp(1, 999) : damage;
  }

  static int calculateEnemyDamage(int baseDamage, bool isLowHunger) {
    return isLowHunger ? (baseDamage * 1.3).ceil() : baseDamage;
  }

  static bool rollDodge(double chance) => _random.nextDouble() < chance;
  
  static bool rollMiss(bool isCriticalHunger) {
    if (!isCriticalHunger) return false;
    return _random.nextDouble() < 0.25;
  }
}
