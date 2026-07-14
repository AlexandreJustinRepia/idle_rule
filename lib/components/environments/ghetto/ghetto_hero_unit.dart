import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoHeroUnit extends StatelessWidget {
  final Animation<double> walkAnimation;
  final Animation<double> attackAnimation;
  final Animation<double> enemyAttackAnimation;
  final Animation<double> idleAnimation;
  final bool isFighting;
  final bool wasHit;
  final bool missed;
  final bool isDefeated;
  final bool isSelected;
  final VoidCallback? onTap;
  final CharacterCustomization? customization;

  const GhettoHeroUnit({
    super.key,
    required this.walkAnimation,
    required this.attackAnimation,
    required this.enemyAttackAnimation,
    required this.idleAnimation,
    required this.isFighting,
    required this.wasHit,
    required this.missed,
    this.isDefeated = false,
    this.isSelected = false,
    this.onTap,
    this.customization,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 45.0, left: 60.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            walkAnimation,
            attackAnimation,
            enemyAttackAnimation,
            idleAnimation,
          ]),
          builder: (context, _) {
            final attackProgress = math.sin(attackAnimation.value * math.pi);
            final hitShake = wasHit
                ? math.sin(enemyAttackAnimation.value * math.pi * 8) * 6
                : 0.0;
            final missShake = missed
                ? math.sin(attackAnimation.value * math.pi * 12) * 5
                : 0.0;

            return Opacity(
              opacity: wasHit || isDefeated ? 0.72 : 1,
              child: Transform.translate(
                offset: Offset(
                  (isFighting ? attackProgress * 52 : 0) + hitShake + missShake,
                  isDefeated
                      ? 10
                      : (isFighting
                            ? -attackProgress * 4
                            : -walkAnimation.value * 8),
                ),
                child: Transform.rotate(
                  angle: isDefeated
                      ? -math.pi /
                            2 // Fall over
                      : (isFighting
                            ? attackProgress * 0.18
                            : (walkAnimation.value - 0.5) * 0.05),
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      decoration: isSelected
                          ? BoxDecoration(
                              border: Border.all(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            )
                          : null,
                      padding: isSelected
                          ? const EdgeInsets.all(4)
                          : EdgeInsets.zero,
                      child: HeroCharacterPlaceholder(
                        walkProgress: walkAnimation.value,
                        idleProgress: idleAnimation.value,
                        punchProgress: attackAnimation.value,
                        customization: customization,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
