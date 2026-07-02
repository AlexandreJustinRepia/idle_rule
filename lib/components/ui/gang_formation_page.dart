import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

class GangFormationPage extends StatelessWidget {
  final GameController gameController;

  const GangFormationPage({super.key, required this.gameController});

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
          'FORMATION CENTER',
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
          final memberCapacity = gameController.gangMemberCapacity;
          final formationSize = gameController.gangFormationSize;
          final formations = gameController.gangFormations;
          final activeFormationIndex = gameController.activeFormationIndex;
          final activeFormation = gameController.activeFormation;
          final exclusiveMembers = gameController.gangMembers
              .where((m) => m.isExclusive)
              .toList();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              children: [
                _buildFormationSelector(
                  gang: gang,
                  formations: formations,
                  activeFormationIndex: activeFormationIndex,
                ),
                const SizedBox(height: 14),
                // Summary Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111116),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: gang.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeFormation.name.toUpperCase(),
                            style: GoogleFonts.bebasNeue(
                              color: Colors.white54,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$formationSize / $memberCapacity Members',
                            style: GoogleFonts.bebasNeue(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: formationSize > 0
                            ? gameController.clearFormation
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white10,
                          disabledForegroundColor: Colors.white24,
                        ),
                        child: const Text('CLEAR ALL'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Player character section
                Text(
                  'LEADER',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: gang.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: const Color(0xFF111116),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'PLAYER CHARACTER (${gameController.playerName})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      'Toggle if you want to fight alongside your crew',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    value: gameController.isPlayerInFormation,
                    activeTrackColor: gang.primaryColor,
                    onChanged: (val) {
                      gameController.togglePlayerInFormation();
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Exclusive members section
                Text(
                  'EXCLUSIVE LEADERS',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: gang.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (exclusiveMembers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No exclusive leaders recruited yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  )
                else
                  ...exclusiveMembers.map((member) {
                    return Card(
                      color: const Color(0xFF111116),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: SwitchListTile(
                        title: Text(
                          member.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'PWR ${member.power} | ATK ${member.atk} | HP ${member.maxHp}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        value: gameController
                            .isExclusiveMemberInActiveFormation(member),
                        activeTrackColor: member.themeColor,
                        onChanged: (val) {
                          gameController.toggleExclusiveMemberFormation(member);
                        },
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Regular troops (Tiers)
                Text(
                  'REGULAR TROOPS',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: gang.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                ...RecruitTiers.all.map((tier) {
                  final available =
                      gameController.gangTierCounts[tier.tier] ?? 0;
                  final selected =
                      gameController.formationCounts[tier.tier] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111116),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected > 0
                            ? gang.primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: gang.primaryColor.withValues(
                              alpha: selected > 0 ? 0.2 : 0.07,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'T${tier.tier}',
                              style: TextStyle(
                                color: selected > 0
                                    ? gang.primaryColor
                                    : Colors.white30,
                                fontWeight: FontWeight.bold,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Available: $available',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: selected > 0
                                  ? () => gameController.setFormationCount(
                                      tier.tier,
                                      selected - 1,
                                    )
                                  : null,
                              icon: const Icon(Icons.remove, size: 16),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white10,
                                disabledBackgroundColor: Colors.transparent,
                              ),
                            ),
                            Text(
                              '$selected',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  available > selected &&
                                      formationSize < memberCapacity
                                  ? () => gameController.setFormationCount(
                                      tier.tier,
                                      selected + 1,
                                    )
                                  : null,
                              icon: const Icon(Icons.add, size: 16),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white10,
                                disabledBackgroundColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormationSelector({
    required Gang gang,
    required List<GangFormation> formations,
    required int activeFormationIndex,
  }) {
    final canAdd = formations.length < GameController.maxGangFormations;
    final canDelete = formations.length > 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'FORMATIONS',
                  style: GoogleFonts.bebasNeue(
                    color: gang.primaryColor,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Add formation',
                onPressed: canAdd ? gameController.addGangFormation : null,
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete active formation',
                onPressed: canDelete
                    ? gameController.deleteActiveGangFormation
                    : null,
                icon: const Icon(Icons.delete_outline, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: formations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final formation = formations[index];
                final selected = index == activeFormationIndex;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => gameController.selectGangFormation(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 116,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? gang.primaryColor.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? gang.primaryColor : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.groups,
                          size: 15,
                          color: selected ? gang.primaryColor : Colors.white38,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            formation.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? gang.primaryColor
                                  : Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
