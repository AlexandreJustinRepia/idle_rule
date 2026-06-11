import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoAllyUnit extends StatelessWidget {
  final Ally ally;
  final Animation<double> walkAnimation;
  final Animation<double> attackAnimation;
  final Animation<double>? chargeAnimation;
  final Animation<double> idleAnimation;
  final bool isFighting;
  final int index;

  const GhettoAllyUnit({
    super.key,
    required this.ally,
    required this.walkAnimation,
    required this.attackAnimation,
    this.chargeAnimation,
    required this.idleAnimation,
    required this.isFighting,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 45.0, 
          left: 15.0 + (index * 40.0), // Offset based on index
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            walkAnimation,
            attackAnimation,
            chargeAnimation,
            idleAnimation,
          ]),
          builder: (context, _) {
            final attackProgress = math.sin(attackAnimation.value * math.pi);
            final isDefeated = ally.hp <= 0;
            
            return Transform.translate(
              offset: Offset(
                attackProgress * 30, // Lunges forward when attacking
                isFighting ? (isDefeated ? 5 : 0) : -walkAnimation.value * 7,
              ),
              child: Transform.rotate(
                angle: isDefeated 
                  ? -math.pi / 2.2 // Laying down if defeated
                  : isFighting ? (attackProgress * 0.1) : (walkAnimation.value - 0.5) * 0.04,
                child: AllyCharacterPlaceholder(
                  name: ally.name,
                  themeColor: ally.themeColor,
                  chargeProgress: chargeAnimation,
                  hp: ally.hp,
                  maxHp: ally.maxHp,
                  walkProgress: walkAnimation.value,
                  idleProgress: idleAnimation.value,
                  punchProgress: attackAnimation.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
