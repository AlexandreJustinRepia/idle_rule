enum ActionState { idle, walking, attacking, hit, recovering, dying, dead }

/// A unified interface for all combat units (Player, Enemy, Ally).
abstract class CombatEntity {
  String get name;
  int get hp;
  set hp(int value);
  int get maxHp;
  int get atk;
  Duration get attackDelay;
  double get dodgeChance;
  ActionState get actionState;
  set actionState(ActionState value);
  CombatEntity? get target;
  set target(CombatEntity? value);
}
