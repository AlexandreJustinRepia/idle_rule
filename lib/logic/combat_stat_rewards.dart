import '../models/enemy.dart';

/// Scales combat stat gains by enemy threat — weak foes give little, tough fights pay well.
class CombatStatRewards {
  static const double _referenceThreat = 12.0;

  static double enemyThreat(Enemy enemy) {
    var threat = enemy.maxHp * 0.12 + enemy.atk * 1.4;

    switch (enemy.type) {
      case EnemyType.tank:
        threat *= 1.4;
      case EnemyType.fast:
        threat *= 1.2;
      case EnemyType.counter:
        threat *= 1.25;
      case EnemyType.regular:
        break;
    }

    threat *= 1.0 +
        (enemy.dodgeChance * 0.4) +
        (enemy.counterChance * 0.35) +
        (enemy.comboChance * 0.2);
    return threat;
  }

  static double encounterThreat(Iterable<Enemy> enemies) {
    return enemies.fold(0.0, (sum, enemy) => sum + enemyThreat(enemy));
  }

  static double _activeGroupMultiplier(int activeCount) {
    if (activeCount <= 1) return 1.0;
    return 1.0 + (activeCount - 1) * 0.18;
  }

  static double _threatMultiplier(
    double threat, {
    double min = 0.12,
    double max = 3.5,
  }) {
    return (threat / _referenceThreat).clamp(min, max);
  }

  static ({double strength, double speed, double endurance}) perHitGains({
    required Enemy target,
    required List<Enemy> activeEnemies,
    required bool isBossFight,
  }) {
    final threatMult = _threatMultiplier(enemyThreat(target));
    final groupMult = _activeGroupMultiplier(activeEnemies.length);
    final bossMult = isBossFight ? 1.6 : 1.0;
    final mult = threatMult * groupMult * bossMult;

    return (
      strength: 0.42 * mult,
      speed: 0.075 * mult,
      endurance: 0.0,
    );
  }

  static ({double strength, double speed, double endurance}) damageTakenGains(
    Enemy attacker,
  ) {
    final mult = _threatMultiplier(enemyThreat(attacker), min: 0.2, max: 2.8);
    return (
      strength: 0.0,
      speed: 0.0,
      endurance: 0.55 * mult,
    );
  }

  static ({double strength, double speed, double endurance}) dodgeGains(
    Enemy attacker,
  ) {
    final mult = _threatMultiplier(enemyThreat(attacker), min: 0.25, max: 2.5);
    return (
      strength: 0.0,
      speed: 0.65 * mult,
      endurance: 0.0,
    );
  }

  static ({double strength, double speed, double endurance}) killBonus(
    Enemy defeated,
  ) {
    final mult = _threatMultiplier(enemyThreat(defeated), min: 0.15, max: 3.0);
    return (
      strength: 0.35 * mult,
      speed: 0.12 * mult,
      endurance: 0.18 * mult,
    );
  }

  static double encounterReputationReward(double totalThreat) {
    return (totalThreat * 0.045).clamp(0.12, 2.5);
  }
}
