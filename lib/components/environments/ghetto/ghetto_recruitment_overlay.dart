import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoRecruitmentOverlay extends StatelessWidget {
  final List<Ally> allies;
  final List<Enemy> dyingEnemies;
  final int gangCapacity;
  final Animation<double> hitController;
  final Function(Enemy) onRecruitTapped;
  final Function(Enemy) onDismissDyingEnemy;
  final Function(Ally) onDismissAlly;
  final VoidCallback onFinishRecruitment;

  const GhettoRecruitmentOverlay({
    super.key,
    required this.allies,
    required this.dyingEnemies,
    required this.gangCapacity,
    required this.hitController,
    required this.onRecruitTapped,
    required this.onDismissDyingEnemy,
    required this.onDismissAlly,
    required this.onFinishRecruitment,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "BATTLE WON!",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "RECRUIT MEMBERS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4))],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  "GANG: ${allies.length} / $gangCapacity",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              if (allies.isNotEmpty) ...[
                const Text("CURRENT GANG", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: allies.length,
                    itemBuilder: (context, index) {
                      final ally = allies[index];
                      return _buildAllyDismissCard(ally);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const Text("NEW RECRUITS", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text("← SKIP     RECRUIT →", style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              SizedBox(
                height: 185,
                child: dyingEnemies.isEmpty
                  ? const Center(child: Text("NO RECRUITS LEFT", style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)))
                  : Stack(
                      alignment: Alignment.center,
                      children: dyingEnemies.reversed.map((enemy) {
                        return Dismissible(
                          key: ValueKey(enemy.name + enemy.hashCode.toString()),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              onRecruitTapped(enemy);
                            } else {
                              onDismissDyingEnemy(enemy);
                            }
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: const Text("RECRUIT", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: const Text("SKIP", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                          child: _buildRecruitCard(enemy),
                        );
                      }).toList(),
                    ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: ElevatedButton(
                  onPressed: onFinishRecruitment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B71F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllyDismissCard(Ally ally) {
    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ally.name, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 10),
              Text(" ${ally.atk}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => onDismissAlly(ally),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("DISMISS", style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitCard(Enemy enemy) {
    final bool isFull = allies.length >= gangCapacity;

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enemy.themeColor.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: enemy.themeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: FittedBox(
              child: EnemyCharacterPlaceholder(
                health: enemy.health,
                enemy: enemy,
                enemyNumber: 0,
                wasHit: false,
                chargeProgress: hitController,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enemy.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 16),
              Text(
                " ${enemy.damage} ATK",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isFull ? Colors.orangeAccent.withValues(alpha: 0.9) : Colors.blueAccent.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Center(
              child: Text(
                isFull ? "REPLACE WEAKEST" : "RECRUIT  ➡️",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
