import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoAllyUnit extends StatelessWidget {
  final Ally ally;
  final Animation<double> walkAnimation;
  final Animation<double> attackAnimation;
  final Animation<double>? chargeAnimation;
  final bool isFighting;
  final int index;

  const GhettoAllyUnit({
    super.key,
    required this.ally,
    required this.walkAnimation,
    required this.attackAnimation,
    this.chargeAnimation,
    required this.isFighting,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (ally.hp <= 0) return const SizedBox.shrink();

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
            if (chargeAnimation != null) chargeAnimation!,
          ]),
          builder: (context, child) {
            final attackProgress = math.sin(attackAnimation.value * math.pi);
            
            return Transform.translate(
              offset: Offset(
                attackProgress * 30, // Lunges forward when attacking
                isFighting ? 0 : -walkAnimation.value * 7,
              ),
              child: Transform.rotate(
                angle: isFighting ? (attackProgress * 0.1) : (walkAnimation.value - 0.5) * 0.04,
                child: child,
              ),
            );
          },
          child: AllyCharacterPlaceholder(
            name: ally.name,
            themeColor: ally.themeColor,
            chargeProgress: chargeAnimation,
            hp: ally.hp,
            maxHp: ally.maxHp,
          ),
        ),
      ),
    );
  }
}
