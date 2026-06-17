import 'package:flutter/material.dart';
import '../../../game_state.dart';

class GhettoRecruitmentOverlay extends StatelessWidget {
  final List<Ally> allies;
  final List<Enemy> dyingEnemies;
  final int gangCapacity;
  final bool hasGang;
  final Function(Enemy) onRecruitTapped;
  final Function(Enemy) onDismissDyingEnemy;
  final Function(Ally) onDismissAlly;
  final VoidCallback onAutoRecruit;
  final VoidCallback onFinishRecruitment;

  const GhettoRecruitmentOverlay({
    super.key,
    required this.allies,
    required this.dyingEnemies,
    required this.gangCapacity,
    required this.hasGang,
    required this.onRecruitTapped,
    required this.onDismissDyingEnemy,
    required this.onDismissAlly,
    required this.onAutoRecruit,
    required this.onFinishRecruitment,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              if (!hasGang) _buildNoGangBanner(),
              if (allies.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildSectionLabel('CURRENT GANG'),
                const SizedBox(height: 6),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allies.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => _buildAllyChip(allies[index]),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'NEW RECRUITS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: (!hasGang || dyingEnemies.isEmpty) ? null : onAutoRecruit,
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: const Text('AUTO RECRUIT'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE24B4A),
                        disabledForegroundColor: Colors.white24,
                        side: BorderSide(
                          color: dyingEnemies.isEmpty
                              ? Colors.white12
                              : const Color(0xFFE24B4A).withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: dyingEnemies.isEmpty
                    ? const Center(
                        child: Text(
                          'NO RECRUITS LEFT',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: dyingEnemies.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _buildRecruitCard(dyingEnemies[index]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFinishRecruitment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B4A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoGangBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16161C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE24B4A).withValues(alpha: 0.4)),
        ),
        child: const Row(
          children: [
            Icon(Icons.group_off, color: Color(0xFFE24B4A), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Create a gang on the Gangs tab before you can recruit members.',
                style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          const Text(
            'BATTLE WON',
            style: TextStyle(
              color: Color(0xFFE24B4A),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'RECRUIT MEMBERS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF16161C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              'GANG ${allies.length} / $gangCapacity',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildAllyChip(Ally ally) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16161C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ally.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${ally.atk} ATK · ${ally.maxHp} HP',
            style: const TextStyle(color: Colors.white54, fontSize: 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => onDismissAlly(ally),
            child: const Text(
              'DISMISS',
              style: TextStyle(
                color: Color(0xFFE24B4A),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitCard(Enemy enemy) {
    final isFull = allies.length >= gangCapacity;
    final canRecruit = hasGang && gangCapacity > 0;
    final typeLabel = enemy.type.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121218),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enemy.themeColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enemy.themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: enemy.themeColor.withValues(alpha: 0.4)),
                ),
                child: Icon(
                  _typeIcon(enemy.type),
                  color: enemy.themeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enemy.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: enemy.themeColor.withValues(alpha: 0.9),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatChip('HP', '${enemy.health}', Colors.greenAccent),
              const SizedBox(width: 8),
              _buildStatChip('ATK', '${enemy.damage}', Colors.orangeAccent),
              const SizedBox(width: 8),
              _buildStatChip(
                'DGE',
                '${(enemy.dodgeChance * 100).round()}%',
                Colors.cyanAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onDismissDyingEnemy(enemy),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: canRecruit ? () => onRecruitTapped(enemy) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !canRecruit
                        ? Colors.white12
                        : isFull
                            ? Colors.orangeAccent
                            : const Color(0xFF3B71F3),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    !canRecruit
                        ? 'NO GANG'
                        : isFull
                            ? 'REPLACE'
                            : 'RECRUIT',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(EnemyType type) {
    switch (type) {
      case EnemyType.fast:
        return Icons.bolt;
      case EnemyType.tank:
        return Icons.shield;
      case EnemyType.counter:
        return Icons.sync;
      case EnemyType.regular:
        return Icons.person;
    }
  }
}
