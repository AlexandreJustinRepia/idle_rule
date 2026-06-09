import 'package:flutter/material.dart';
import '../../../game_state.dart';

class HeroCharacterPlaceholder extends StatelessWidget {
  const HeroCharacterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30, 
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withValues(alpha: 0.8),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 40, 
          height: 55, 
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: const Center(
            child: Text('HERO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 9)),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 24, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Container(width: 12, height: 24, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(3))),
          ],
        ),
      ],
    );
  }
}

class EnemyCharacterPlaceholder extends StatelessWidget {
  final int health;
  final Enemy enemy;
  final int enemyNumber;
  final bool wasHit;
  final AnimationController chargeProgress;

  const EnemyCharacterPlaceholder({
    super.key,
    required this.health,
    required this.enemy,
    required this.enemyNumber,
    required this.wasHit,
    required this.chargeProgress,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, enemy.health);
    final healthPercent = enemy.health == 0 ? 0.0 : visibleHealth / enemy.health;
    final displayColor = enemy.themeColor;
    final isBoss = enemy.type == EnemyType.regular && enemy.name != 'THUG' && enemy.name != 'PUNK' && enemy.name != 'BRUISER' && enemy.name != 'REBEL'; 

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isBoss ? 'BOSS: ${enemy.name}' : '${enemy.name} #$enemyNumber', style: TextStyle(color: displayColor, fontWeight: FontWeight.bold, fontSize: isBoss ? 14 : 12)),
            const SizedBox(width: 8),
            Text('ATK: ${enemy.damage}', style: TextStyle(color: displayColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        if (enemy.type != EnemyType.regular)
           Text(enemy.type.name.toUpperCase(), style: TextStyle(color: displayColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 3),
        SizedBox(
          width: isBoss ? 90 : 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: isBoss ? 8 : 6,
              value: healthPercent,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(wasHit ? Colors.white : displayColor),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: isBoss ? 90 : 60,
          child: AnimatedBuilder(
            animation: chargeProgress,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: chargeProgress.value,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent.withValues(alpha: 0.6)),
                minHeight: 2,
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isBoss ? 44 : 30,
          height: isBoss ? 44 : 30,
          decoration: BoxDecoration(
            color: isBoss ? Colors.black : Colors.red[800],
            shape: BoxShape.circle,
            border: isBoss ? Border.all(color: displayColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: displayColor.withValues(alpha: 0.5),
                blurRadius: isBoss ? 18 : 12,
                spreadRadius: isBoss ? 4 : 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isBoss ? 60 : 40,
          height: isBoss ? 85 : 55,
          decoration: BoxDecoration(
            color: isBoss ? Colors.black : Colors.red[900],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: displayColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Text(isBoss ? 'BOSS' : 'ENEMY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 9)),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 18, height: 24, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(3))),
            SizedBox(width: isBoss ? 12 : 8),
            Container(width: 18, height: 24, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(3))),
          ],
        ),
      ],
    );
  }
}
