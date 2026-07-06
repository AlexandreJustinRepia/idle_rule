import 'package:flutter/material.dart';
import '../../game_state.dart';
import 'ghetto_environment.dart';

/// Hub for all street-based environments (districts).
/// This allows switching between Ghetto and future districts like 'Downtown' or 'Harbor'.
class StreetEnvironment extends StatelessWidget {
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
  final bool isActive;

  const StreetEnvironment({
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
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Logic for switching districts can be added here.
    // For now, we only have the Ghetto District.
    return GhettoEnvironment(
      stats: stats,
      playerHealth: playerHealth,
      playerMaxHealth: playerMaxHealth,
      playerStamina: playerStamina,
      playerMaxStamina: playerMaxStamina,
      playerHunger: playerHunger,
      playerMaxHunger: playerMaxHunger,
      onStatsGained: onStatsGained,
      onPlayerDamaged: onPlayerDamaged,
      onPlayerDefeated: onPlayerDefeated,
      onNewEnemyApproached: onNewEnemyApproached,
      onStaminaSpent: onStaminaSpent,
      onNeedsRecovered: onNeedsRecovered,
      activeBoss: activeBoss,
      onBossDefeated: onBossDefeated,
      onStartBossFight: onStartBossFight,
      bossIndex: bossIndex,
      onMoneyGained: onMoneyGained,
      isActive: isActive,
    );
  }
}
