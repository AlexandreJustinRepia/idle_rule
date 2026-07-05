import 'package:flutter/material.dart';

import '../../controllers/game_controller.dart';
import '../../game_state.dart';

const Map<int, String> gangTierImageAssets = {
  1: 'assets/gang_members/tier_1.png',
  2: 'assets/gang_members/tier_2.png',
  3: 'assets/gang_members/tier_3.png',
  4: 'assets/gang_members/tier_4.png',
  5: 'assets/gang_members/tier_5.png',
};

String formatGangTrainingDuration(Duration duration) {
  if (duration.inMinutes >= 1) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
  }
  return '${duration.inSeconds}s';
}

class GangTrainingJobCard extends StatelessWidget {
  final GangTrainingJob job;
  final Gang gang;

  const GangTrainingJobCard({super.key, required this.job, required this.gang});

  @override
  Widget build(BuildContext context) {
    final remaining = formatGangTrainingDuration(job.remaining);

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
}

class RecruitTierImageSlot extends StatelessWidget {
  final RecruitTier tier;
  final Gang gang;
  final bool unlocked;

  const RecruitTierImageSlot({
    super.key,
    required this.tier,
    required this.gang,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = gangTierImageAssets[tier.tier];

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (assetPath == null)
              RecruitTierPlaceholder(tier: tier, gang: gang, unlocked: unlocked)
            else
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    RecruitTierPlaceholder(
                      tier: tier,
                      gang: gang,
                      unlocked: unlocked,
                    ),
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
}

class RecruitTierPlaceholder extends StatelessWidget {
  final RecruitTier tier;
  final Gang gang;
  final bool unlocked;

  const RecruitTierPlaceholder({
    super.key,
    required this.tier,
    required this.gang,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
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
}

class GangTrainingCountButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const GangTrainingCountButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
}

class GangMemberThumbnail extends StatelessWidget {
  final Ally member;
  final bool small;

  const GangMemberThumbnail({
    super.key,
    required this.member,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 48.0 : 64.0;
    final assetPath = member.isExclusive
        ? null
        : gangTierImageAssets[member.tier];

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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(small ? 8 : 12),
              child: assetPath == null
                  ? Center(
                      child: Icon(
                        member.isExclusive
                            ? Icons.workspace_premium
                            : Icons.person,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: small ? 23 : 32,
                      ),
                    )
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: small ? 23 : 32,
                        ),
                      ),
                    ),
            ),
          ),
          if (assetPath != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.38),
                    ],
                  ),
                ),
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
}

class GangTrainingStatPill extends StatelessWidget {
  final String label;
  final int value;

  const GangTrainingStatPill({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class GangTrainingEmptyMembersCard extends StatelessWidget {
  const GangTrainingEmptyMembersCard({super.key});

  @override
  Widget build(BuildContext context) {
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
}
