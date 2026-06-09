import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../shared/character_placeholders.dart';

class GhettoEnemyUnit extends StatelessWidget {
  final bool isFighting;
  final bool isEnemyDying;
  final bool playerWasDefeated;
  final Enemy? currentEnemy;
  final int enemyHealth;
  final int enemyNumber;
  final bool enemyWasHit;
  final AnimationController attackAnimation;
  final AnimationController enemyAttackAnimation;
  final AnimationController deathAnimation;
  final AnimationController enemyChargeController;
  final VoidCallback onTap;
  final bool isBoss;

  const GhettoEnemyUnit({
    super.key,
    required this.isFighting,
    required this.isEnemyDying,
    required this.playerWasDefeated,
    required this.currentEnemy,
    required this.enemyHealth,
    required this.enemyNumber,
    required this.enemyWasHit,
    required this.attackAnimation,
    required this.enemyAttackAnimation,
    required this.deathAnimation,
    required this.enemyChargeController,
    required this.onTap,
    this.isBoss = false,
  });

  @override
  Widget build(BuildContext context) {
    if ((!isFighting && !isEnemyDying && !playerWasDefeated) || currentEnemy == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 45.0, right: 60.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([attackAnimation, enemyAttackAnimation, deathAnimation]),
          builder: (context, child) {
            final hitShake = enemyWasHit ? math.sin(attackAnimation.value * math.pi * 8) * 6 : 0.0;
            final enemyAttackProgress = math.sin(enemyAttackAnimation.value * math.pi);
            final fallProgress = Curves.easeIn.transform(deathAnimation.value);
            return Opacity(
              opacity: (1 - fallProgress).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(hitShake - enemyAttackProgress * 40 + fallProgress * 50, -enemyAttackProgress * 4 + fallProgress * 100),
                child: Transform.rotate(
                  angle: -enemyAttackProgress * 0.14 + fallProgress * math.pi / 2.5,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          },
          child: GestureDetector(
            onTap: onTap,
            child: EnemyCharacterPlaceholder(
              health: enemyHealth,
              enemy: currentEnemy!,
              enemyNumber: isBoss ? 0 : enemyNumber,
              wasHit: enemyWasHit,
              chargeProgress: enemyChargeController,
            ),
          ),
        ),
      ),
    );
  }
}
