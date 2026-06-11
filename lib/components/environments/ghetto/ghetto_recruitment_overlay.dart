import 'package:flutter/material.dart';
import '../../../game_state.dart';
import '../../shared/character_placeholders.dart';

class GhettoRecruitmentOverlay extends StatelessWidget {
  final List<Ally> allies;
  final List<Enemy> dyingEnemies;
  final int gangCapacity;
  final Animation<double> hitController;
  final Function(Enemy) onRecruitTapped;
  final Function(Ally) onDismissAlly;
  final VoidCallback onFinishRecruitment;

  const GhettoRecruitmentOverlay({
    super.key,
    required this.allies,
    required this.dyingEnemies,
    required this.gangCapacity,
    required this.hitController,
    required this.onRecruitTapped,
    required this.onDismissAlly,
    required this.onFinishRecruitment,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      "BATTLE WON!",
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "RECRUIT MEMBERS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        "GANG SIZE: ${allies.length} / $gangCapacity",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    if (allies.isNotEmpty) ...[
                      const Text("CURRENT GANG", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          itemCount: allies.length,
                          itemBuilder: (context, index) {
                            final ally = allies[index];
                            return _buildAllyDismissCard(ally);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text("NEW RECRUITS", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: dyingEnemies.isEmpty 
                        ? const Center(child: Text("NO RECRUITS LEFT", style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            itemCount: dyingEnemies.length,
                            itemBuilder: (context, index) {
                              final enemy = dyingEnemies[index];
                              return _buildRecruitCard(enemy);
                            },
                          ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 20),
              child: ElevatedButton(
                onPressed: onFinishRecruitment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B71F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  elevation: 10,
                  shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllyDismissCard(Ally ally) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ally.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 12),
              Text(" ${ally.atk}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onDismissAlly(ally),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("DISMISS", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitCard(Enemy enemy) {
    final bool isFull = allies.length >= gangCapacity;
    
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: enemy.themeColor.withValues(alpha: 0.7),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: enemy.themeColor.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
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
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 16),
              Text(
                " ${enemy.damage}",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => onRecruitTapped(enemy),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isFull ? Colors.orangeAccent.withValues(alpha: 0.9) : Colors.blueAccent.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  isFull ? "REPLACE WEAKEST" : "RECRUIT",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
