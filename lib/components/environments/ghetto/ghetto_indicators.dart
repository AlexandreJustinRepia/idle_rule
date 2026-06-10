import 'package:flutter/material.dart';

class GhettoSearchingIndicator extends StatelessWidget {
  final Animation<double> progress;

  const GhettoSearchingIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 180,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            const Text(
              'SEARCHING FOR RIVALS...',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 150,
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: progress.value,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white54),
                    minHeight: 2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GhettoHungerIndicator extends StatelessWidget {
  final bool isLowHunger;
  final bool isCriticalHunger;

  const GhettoHungerIndicator({
    super.key,
    required this.isLowHunger,
    required this.isCriticalHunger,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLowHunger) return const SizedBox.shrink();

    return Positioned(
      top: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isCriticalHunger ? Colors.redAccent : Colors.orangeAccent,
              width: 1,
            ),
          ),
          child: Text(
            isCriticalHunger ? 'CRITICAL HUNGER: SHAKY STATE' : 'LOW HUNGER: REDUCED STATS',
            style: TextStyle(
              color: isCriticalHunger ? Colors.redAccent : Colors.orangeAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class GhettoBattleStatusOverlay extends StatelessWidget {
  final bool isEnemyDying;
  final bool playerWasDefeated;
  final bool isBoss;
  final bool isRecruiting;

  const GhettoBattleStatusOverlay({
    super.key,
    required this.isEnemyDying,
    required this.playerWasDefeated,
    required this.isBoss,
    this.isRecruiting = false,
  });

  @override
  Widget build(BuildContext context) {
    // Hide the default status overlay when recruiting to avoid clutter
    if (isRecruiting) return const SizedBox.shrink();
    if (!isEnemyDying && !playerWasDefeated) return const SizedBox.shrink();

    String text = 'RECOVERING';
    Color color = Colors.redAccent;

    if (isEnemyDying) {
      text = isBoss ? 'BOSS DEFEATED!' : 'ENEMY DEFEATED';
      color = Colors.amberAccent;
    }

    return Positioned(
      bottom: 220, // Moved up slightly
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
      ),
    );
  }
}
