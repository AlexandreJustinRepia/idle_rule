import '../models/combat_entity.dart';
import '../models/player_entity.dart';
import '../models/ally.dart';
import '../models/enemy.dart';

/// Manages the state of all participants in combat.
/// This fulfills the "Foundation" of Step 2: player, allies[], enemies[].
class CombatManager {
  /// The main player entity.
  PlayerEntity? player;

  /// List of active allies helping the player.
  final List<Ally> allies = [];

  /// List of active enemies the player and allies are fighting.
  final List<Enemy> enemies = [];

  /// Initializes the combat manager with a player.
  void initialize(PlayerEntity playerEntity) {
    player = playerEntity;
  }

  /// Adds an ally to the combat field.
  void spawnAlly(Ally ally) {
    allies.add(ally);
  }

  /// Adds an enemy to the combat field.
  void spawnEnemy(Enemy enemy) {
    enemies.add(enemy);
  }

  /// Clears defeated entities or resets the field.
  void clearCombat() {
    enemies.clear();
    // Allies might persist across encounters depending on game design,
    // but we can clear them if they are temporary summons.
  }

  /// Helper to get all combatants on the field for logic processing.
  List<CombatEntity> get allEntities => [
    if (player != null) player as CombatEntity,
    ...allies,
    ...enemies,
  ];
}
