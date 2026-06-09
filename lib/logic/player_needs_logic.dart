class PlayerNeedsLogic {
  static double getHungerRatio(double hunger, double maxHunger) =>
      maxHunger > 0 ? hunger / maxHunger : 0;

  static bool isLowHunger(double hunger, double maxHunger) =>
      getHungerRatio(hunger, maxHunger) < 0.25;

  static bool isCriticalHunger(double hunger, double maxHunger) =>
      getHungerRatio(hunger, maxHunger) < 0.10;

  static double getRecoveryMultiplier(double hunger, double maxHunger) {
    if (isCriticalHunger(hunger, maxHunger)) return 0.3;
    if (isLowHunger(hunger, maxHunger)) return 0.5;
    return 1.0;
  }
}
