import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoEnemyUnit extends StatelessWidget {
  final bool isFighting;
  final bool isEnemyDying;
  final bool playerWasDefeated;
  final Enemy enemy;
  final int enemyNumber;
  final bool enemyWasHit;
  final Animation<double> attackAnimation;
  final Animation<double> enemyAttackAnimation;
  final Animation<double> deathAnimation;
  final Animation<double> enemyChargeController;
  final Animation<double> idleAnimation;
  final ValueChanged<Enemy> onTap;
  final bool isBoss;
  final int index;
  final List<Color> targetingColors;

  const GhettoEnemyUnit({
    super.key,
    required this.isFighting,
    required this.isEnemyDying,
    required this.playerWasDefeated,
    required this.enemy,
    required this.enemyNumber,
    required this.enemyWasHit,
    required this.attackAnimation,
    required this.enemyAttackAnimation,
    required this.deathAnimation,
    required this.enemyChargeController,
    required this.idleAnimation,
    required this.onTap,
    this.isBoss = false,
    this.index = 0,
    this.targetingColors = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 48.0 + ((index % 2 == 0) ? 10.0 : -4.0), // Stagger vertically for depth
          right: (60.0 + (index * 12.0)).clamp(0.0, 200.0), // Formation behind the front enemy
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([attackAnimation, enemyAttackAnimation, deathAnimation, enemyChargeController, idleAnimation]),
          builder: (context, child) {
            final hitShake = enemyWasHit ? math.sin(attackAnimation.value * math.pi * 8) * 6 : 0.0;
            final enemyAttackProgress = math.sin(enemyAttackAnimation.value * math.pi);
            final isThisEnemyDying = isEnemyDying || enemy.hp <= 0;
            final fallProgress = isThisEnemyDying ? 1.0 : 0.0;
            
            return Opacity(
              opacity: 1.0,
              child: Transform.translate(
                offset: Offset(hitShake - enemyAttackProgress * 40 + fallProgress * 50, -enemyAttackProgress * 4 + fallProgress * 100),
                child: Transform.rotate(
                  angle: -enemyAttackProgress * 0.14 + fallProgress * math.pi / 2.5,
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      child!,
                      if (targetingColors.isNotEmpty && !isThisEnemyDying)
                        Positioned(
                          top: -12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: targetingColors.map((color) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.8),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: GestureDetector(
            onTap: () => onTap(enemy),
            child: EnemyCharacterPlaceholder(
              health: enemy.hp,
              enemy: enemy,
              enemyNumber: isBoss ? 0 : enemyNumber,
              wasHit: enemyWasHit,
              chargeProgress: enemyChargeController,
              idleProgress: idleAnimation.value,
              punchProgress: enemyAttackAnimation.value,
            ),
          ),
        ),
      ),
    );
  }
}
