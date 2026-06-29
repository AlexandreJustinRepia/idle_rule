import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

class GangTrainingPage extends StatelessWidget {
  final GameController gameController;

  const GangTrainingPage({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    final gang = gameController.gang;
    if (gang == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: Text('Create a gang first.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          'TRAINING ROOM',
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: gameController,
        builder: (context, child) {
          final job = gameController.gangTrainingJob;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              children: [
                Text(
                  'RECRUIT & BATCH TRAINING',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: gang.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (job != null) ...[
                  _buildTrainingJobCard(job, gang),
                  const SizedBox(height: 10),
                ],
                ...RecruitTiers.all.map(
                  (tier) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildRecruitTierCard(tier, gang),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'INDIVIDUAL DRILLS',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: gang.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (gameController.gangMembers.isEmpty)
                  _buildEmptyMembersCard()
                else
                  ...gameController.gangMembers.map((member) => _buildMemberCard(member, gang)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrainingJobCard(GangTrainingJob job, Gang gang) {
    final remaining = _formatDuration(job.remaining);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF34C759).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Color(0xFF34C759), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'TRAINING ${job.count}x ${job.tier.name.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Text(
            remaining == '0s' ? 'DONE' : remaining,
            style: const TextStyle(
              color: Color(0xFF34C759),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitTierCard(RecruitTier tier, Gang gang) {
    const count = 5;
    final unlocked = gameController.isRecruitTierUnlocked(tier);
    final busy = gameController.gangTrainingJob != null;
    final cost = tier.cost * count;
    final canTrain = unlocked && !busy && gameController.money >= cost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? gang.primaryColor.withValues(alpha: 0.25)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: unlocked
                  ? gang.primaryColor.withValues(alpha: 0.15)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'T${tier.tier}',
                style: TextStyle(
                  color: unlocked ? gang.primaryColor : Colors.white30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name.toUpperCase(),
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unlocked
                      ? '${tier.description}  ${_formatDuration(tier.trainingTime)} batch'
                      : 'Unlock: ${tier.unlockText}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canTrain
                ? () => gameController.startRecruitTraining(tier, count: count)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: gang.primaryColor,
              foregroundColor: gang.accentColor,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'x$count \$$cost',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Ally member, Gang gang) {
    final cost = gameController.trainingCostFor(member);
    final canTrain = member.canTrain && gameController.money >= cost;
    final currentTier = RecruitTiers.byTier(member.tier);
    final nextTier = gameController.nextRecruitTierFor(member);
    final promotionCost = gameController.promotionCostFor(member);
    final canPromote =
        gameController.canPromoteGangMember(member) &&
        gameController.money >= promotionCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.isExclusive
              ? gang.primaryColor.withValues(alpha: 0.45)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: member.themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              member.isExclusive ? Icons.workspace_premium : Icons.person,
              color: member.themeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  member.isExclusive
                      ? 'EXCLUSIVE LEADER'
                      : 'T${currentTier.tier} ${currentTier.name.toUpperCase()}',
                  style: TextStyle(
                    color: member.themeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PWR ${member.power}  ATK ${member.atk}  HP ${member.maxHp}  TRAIN ${member.trainingLevel}/${member.maxTrainingLevel}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: member.maxTrainingLevel == 0
                        ? 1
                        : member.trainingLevel / member.maxTrainingLevel,
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      member.themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: canTrain
                ? () => gameController.trainGangMember(member)
                : canPromote
                ? () => gameController.promoteGangMember(member)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: member.themeColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              minimumSize: const Size(72, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              member.canTrain
                  ? '\$$cost'
                  : canPromote
                  ? 'T${nextTier!.tier} \$$promotionCost'
                  : 'MAX',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text(
        'No members yet. Recruit a crew, recruit defeated enemies from Street, or buy an exclusive leader.',
        style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
    }
    return '${duration.inSeconds}s';
  }
}
