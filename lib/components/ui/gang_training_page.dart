import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

class GangTrainingPage extends StatefulWidget {
  final GameController gameController;

  const GangTrainingPage({super.key, required this.gameController});

  @override
  State<GangTrainingPage> createState() => _GangTrainingPageState();
}

class _GangTrainingPageState extends State<GangTrainingPage> {
  static const int _minBatchCount = 1;
  static const int _maxBatchCount = 20;
  static const Map<int, String> _tierImageAssets = {
    // Add images here later, for example:
    // 1: 'assets/gang_members/tier_1.png',
  };

  final PageController _tierPageController = PageController(
    viewportFraction: 0.9,
  );
  final PageController _memberPageController = PageController(
    viewportFraction: 0.88,
  );
  final Map<int, int> _batchCounts = {
    for (final tier in RecruitTiers.all) tier.tier: 5,
  };
  int _selectedTierIndex = 0;
  int _selectedMemberIndex = 0;

  GameController get gameController => widget.gameController;

  @override
  void dispose() {
    _tierPageController.dispose();
    _memberPageController.dispose();
    super.dispose();
  }

  void _adjustBatchCount(RecruitTier tier, int delta) {
    setState(() {
      final current = _batchCounts[tier.tier] ?? 5;
      _batchCounts[tier.tier] = (current + delta).clamp(
        _minBatchCount,
        _maxBatchCount,
      );
    });
  }

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
          final members = gameController.gangMembers;
          if (_selectedMemberIndex >= members.length && members.isNotEmpty) {
            _selectedMemberIndex = members.length - 1;
          }

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
                _buildRecruitTierCards(gang),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'INDIVIDUAL DRILLS',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 20,
                          color: gang.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    if (members.isNotEmpty)
                      Text(
                        '${_selectedMemberIndex + 1} / ${members.length}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (members.isEmpty)
                  _buildEmptyMembersCard()
                else
                  _buildMemberCarousel(members, gang),
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

  Widget _buildRecruitTierCards(Gang gang) {
    return Column(
      children: [
        SizedBox(
          height: 326,
          child: PageView.builder(
            controller: _tierPageController,
            itemCount: RecruitTiers.all.length,
            onPageChanged: (index) => setState(() {
              _selectedTierIndex = index;
            }),
            itemBuilder: (context, index) {
              final tier = RecruitTiers.all[index];
              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.only(
                  left: 4,
                  right: 4,
                  top: index == _selectedTierIndex ? 0 : 8,
                  bottom: index == _selectedTierIndex ? 0 : 8,
                ),
                child: _buildRecruitTierCard(tier, gang),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(RecruitTiers.all.length, (index) {
            final tier = RecruitTiers.all[index];
            final selected = index == _selectedTierIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  _tierPageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 42 : 30,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? gang.primaryColor.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? gang.primaryColor : Colors.white12,
                    ),
                  ),
                  child: Text(
                    'T${tier.tier}',
                    style: TextStyle(
                      color: selected ? gang.primaryColor : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecruitTierCard(RecruitTier tier, Gang gang) {
    final count = _batchCounts[tier.tier] ?? 5;
    final unlocked = gameController.isRecruitTierUnlocked(tier);
    final ladderReady = gameController.canStartRecruitTrainingTier(tier);
    final busy = gameController.gangTrainingJob != null;
    final cost = tier.cost * count;
    final canTrain = ladderReady && !busy && gameController.money >= cost;
    final lockedText = gameController.recruitTrainingLockedText(tier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ladderReady
              ? gang.primaryColor.withValues(alpha: 0.35)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTierImageSlot(tier, gang, unlocked)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lockedText.isEmpty
                          ? '${tier.description}  ${_formatDuration(tier.trainingTime)} batch'
                          : lockedText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        height: 1.25,
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
              _buildCountButton(
                icon: Icons.remove,
                enabled: !busy && count > _minBatchCount,
                onPressed: () => _adjustBatchCount(tier, -1),
              ),
              Container(
                width: 58,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'x$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              _buildCountButton(
                icon: Icons.add,
                enabled: !busy && count < _maxBatchCount,
                onPressed: () => _adjustBatchCount(tier, 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: canTrain
                      ? () => gameController.startRecruitTraining(
                          tier,
                          count: count,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gang.primaryColor,
                    foregroundColor: gang.accentColor,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'x$count \$$cost',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
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

  Widget _buildTierImageSlot(RecruitTier tier, Gang gang, bool unlocked) {
    final assetPath = _tierImageAssets[tier.tier];

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (assetPath == null)
              _buildTierPlaceholder(tier, gang, unlocked)
            else
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildTierPlaceholder(tier, gang, unlocked),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: unlocked ? gang.primaryColor : Colors.white24,
                  ),
                ),
                child: Text(
                  'TIER ${tier.tier}',
                  style: TextStyle(
                    color: unlocked ? gang.primaryColor : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierPlaceholder(RecruitTier tier, Gang gang, bool unlocked) {
    final color = unlocked ? gang.primaryColor : Colors.white24;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: unlocked ? 0.42 : 0.12),
            const Color(0xFF202027),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.groups_2,
          color: color.withValues(alpha: unlocked ? 0.95 : 0.45),
          size: 52,
        ),
      ),
    );
  }

  Widget _buildCountButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.filled(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
          disabledForegroundColor: Colors.white24,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildMemberCarousel(List<Ally> members, Gang gang) {
    return Column(
      children: [
        SizedBox(
          height: 244,
          child: PageView.builder(
            controller: _memberPageController,
            itemCount: members.length,
            onPageChanged: (index) => setState(() {
              _selectedMemberIndex = index;
            }),
            itemBuilder: (context, index) {
              final member = members[index];
              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.only(
                  left: 4,
                  right: 4,
                  top: index == _selectedMemberIndex ? 0 : 8,
                  bottom: index == _selectedMemberIndex ? 0 : 8,
                ),
                child: _buildMemberCard(member, gang),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final member = members[index];
              final selected = index == _selectedMemberIndex;
              return GestureDetector(
                onTap: () {
                  _memberPageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected
                        ? member.themeColor.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? member.themeColor : Colors.white12,
                    ),
                  ),
                  child: _buildMemberThumbnail(member, small: true),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: members.length,
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemberThumbnail(member),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildStatPill('PWR', member.power),
                        _buildStatPill('ATK', member.atk),
                        _buildStatPill('HP', member.maxHp),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'TRAIN ${member.trainingLevel}/${member.maxTrainingLevel}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
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
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                member.canTrain
                    ? 'TRAIN \$$cost'
                    : canPromote
                    ? 'UPGRADE TO T${nextTier!.tier} \$$promotionCost'
                    : 'MAXED OUT',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberThumbnail(Ally member, {bool small = false}) {
    final size = small ? 48.0 : 64.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            member.themeColor.withValues(alpha: 0.65),
            const Color(0xFF232329),
          ],
        ),
        border: Border.all(color: member.themeColor.withValues(alpha: 0.7)),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              member.isExclusive ? Icons.workspace_premium : Icons.person,
              color: Colors.white.withValues(alpha: 0.9),
              size: small ? 23 : 32,
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: small ? 4 : 5,
                vertical: small ? 1 : 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                member.isExclusive ? 'EX' : 'T${member.tier}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: small ? 8 : 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
