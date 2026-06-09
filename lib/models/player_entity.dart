import 'combat_entity.dart';
import 'player_stats.dart';

class PlayerEntity implements CombatEntity {
  @override
  String get name => 'HERO';

  int _hp;
  final int _maxHp;
  final PlayerStats stats;

  @override
  int get hp => _hp;
  @override
  set hp(int value) => _hp = value;

  @override
  int get maxHp => _maxHp;

  @override
  int get atk => stats.attackDamage;

  @override
  Duration get attackDelay => stats.attackDelay;

  @override
  double get dodgeChance => stats.dodgeChance;

  @override
  ActionState actionState;

  @override
  CombatEntity? target;

  PlayerEntity({
    required int hp,
    required int maxHp,
    required this.stats,
    this.actionState = ActionState.idle,
  })  : _hp = hp,
        _maxHp = maxHp;
}
