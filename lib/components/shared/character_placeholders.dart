import 'package:flutter/material.dart';
import '../../game_state.dart';
import 'character_painters.dart';

// ---------------------------------------------------------------------------
// HERO
// ---------------------------------------------------------------------------
class HeroCharacterPlaceholder extends StatelessWidget {
  final double walkProgress;
  final double idleProgress;
  const HeroCharacterPlaceholder({super.key, this.walkProgress = 0.0, this.idleProgress = 0.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(52, 112),
      painter: HeroPainter(accentColor: Colors.blueAccent, walkProgress: walkProgress, idleProgress: idleProgress),
    );
  }
}

// ---------------------------------------------------------------------------
// ALLY
// ---------------------------------------------------------------------------
class AllyCharacterPlaceholder extends StatelessWidget {
  final String name;
  final Color themeColor;
  final Animation<double>? chargeProgress;
  final int hp;
  final int maxHp;
  final double walkProgress;
  final double idleProgress;

  const AllyCharacterPlaceholder({
    super.key,
    required this.name,
    required this.themeColor,
    this.chargeProgress,
    required this.hp,
    required this.maxHp,
    this.walkProgress = 0.0,
    this.idleProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final healthPercent = (hp / maxHp).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HP bar
        SizedBox(
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: healthPercent,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(
                healthPercent > 0.5 ? Colors.greenAccent : Colors.orangeAccent,
              ),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Charge bar
        if (chargeProgress != null)
          SizedBox(
            width: 40,
            child: AnimatedBuilder(
              animation: chargeProgress!,
              builder: (context, _) => LinearProgressIndicator(
                value: chargeProgress!.value,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(themeColor.withValues(alpha: 0.7)),
                minHeight: 2,
              ),
            ),
          ),
        const SizedBox(height: 3),
        // Drawn character
        CustomPaint(
          size: const Size(44, 95),
          painter: AllyPainter(accentColor: themeColor, label: name, walkProgress: walkProgress, idleProgress: idleProgress),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ENEMY
// ---------------------------------------------------------------------------
class EnemyCharacterPlaceholder extends StatelessWidget {
  final int health;
  final Enemy enemy;
  final int enemyNumber;
  final bool wasHit;
  final Animation<double> chargeProgress;
  final double walkProgress;
  final double idleProgress;

  const EnemyCharacterPlaceholder({
    super.key,
    required this.health,
    required this.enemy,
    required this.enemyNumber,
    required this.wasHit,
    required this.chargeProgress,
    this.walkProgress = 0.0,
    this.idleProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHealth = health.clamp(0, enemy.health);
    final healthPercent = enemy.health == 0 ? 0.0 : visibleHealth / enemy.health;
    final displayColor = enemy.themeColor;
    final isBoss =
        enemy.type == EnemyType.regular &&
        enemy.name != 'THUG' &&
        enemy.name != 'PUNK' &&
        enemy.name != 'BRUISER' &&
        enemy.name != 'REBEL';

    final charW = isBoss ? 80.0 : 58.0;
    final charH = isBoss ? 140.0 : 105.0;
    final barW = isBoss ? 90.0 : 64.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + ATK row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBoss ? 'BOSS: ${enemy.name}' : '${enemy.name} #$enemyNumber',
              style: TextStyle(
                color: displayColor,
                fontWeight: FontWeight.bold,
                fontSize: isBoss ? 13 : 11,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'ATK: ${enemy.damage}',
              style: TextStyle(
                color: displayColor.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (enemy.type != EnemyType.regular)
          Text(
            enemy.type.name.toUpperCase(),
            style: TextStyle(
              color: displayColor,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        const SizedBox(height: 3),
        // HP bar
        SizedBox(
          width: barW,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: isBoss ? 7 : 5,
              value: healthPercent,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation<Color>(wasHit ? Colors.white : displayColor),
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Drawn character
        AnimatedBuilder(
          animation: chargeProgress,
          builder: (context, _) => CustomPaint(
            size: Size(charW, charH),
            painter: EnemyPainter(
              accentColor: displayColor,
              isBoss: isBoss,
              wasHit: wasHit,
              chargeValue: chargeProgress.value,
              walkProgress: walkProgress,
              idleProgress: idleProgress,
            ),
          ),
        ),
      ],
    );
  }
}
