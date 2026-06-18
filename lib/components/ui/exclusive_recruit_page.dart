import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

class ExclusiveRecruitPage extends StatefulWidget {
  final GameController gameController;

  const ExclusiveRecruitPage({super.key, required this.gameController});

  @override
  State<ExclusiveRecruitPage> createState() => _ExclusiveRecruitPageState();
}

class _ExclusiveRecruitPageState extends State<ExclusiveRecruitPage> {
  late List<({Ally ally, int cost})> _candidates;
  final Set<int> _recruitedIndices = {};

  @override
  void initState() {
    super.initState();
    _generateCandidates();
  }

  void _generateCandidates() {
    setState(() {
      _candidates = widget.gameController.generateExclusiveCandidates(6);
      _recruitedIndices.clear();
    });
  }

  void _recruit(int index) {
    final candidate = _candidates[index];
    if (!widget.gameController.canRecruitExclusive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MAX 3 EXCLUSIVE LEADERS ALLOWED'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }
    final success = widget.gameController.recruitSpecificExclusiveMember(
      candidate.ally,
      candidate.cost,
    );
    if (success) {
      setState(() => _recruitedIndices.add(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${candidate.ally.name.toUpperCase()} JOINS YOUR CREW',
          ),
          duration: const Duration(milliseconds: 900),
          backgroundColor: const Color(0xFF1A1A22),
        ),
      );
    } else if (widget.gameController.money < candidate.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NOT ENOUGH MONEY'),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, _) {
        final gang = widget.gameController.gang;
        final primaryColor = gang?.primaryColor ?? const Color(0xFFE24B4A);
        final exclusiveCount = widget.gameController.exclusiveMemberCount;
        final canRecruitMore = widget.gameController.canRecruitExclusive;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXCLUSIVE ROSTER',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'LEADERS $exclusiveCount / 3',
                  style: TextStyle(
                    color: canRecruitMore
                        ? primaryColor.withValues(alpha: 0.8)
                        : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: _generateCandidates,
                  icon: Icon(Icons.refresh, size: 16, color: primaryColor),
                  label: Text(
                    'REFRESH',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Header info bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Exclusive leaders are elite fighters outside your command cap. Max 3 at a time.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$${widget.gameController.money}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Candidate grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];
                    final recruited = _recruitedIndices.contains(index);
                    final canAfford =
                        widget.gameController.money >= candidate.cost;
                    return _ExclusiveCandidateCard(
                      ally: candidate.ally,
                      cost: candidate.cost,
                      primaryColor: primaryColor,
                      recruited: recruited,
                      canAfford: canAfford,
                      canRecruitMore: canRecruitMore,
                      onRecruit: recruited ? null : () => _recruit(index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExclusiveCandidateCard extends StatelessWidget {
  final Ally ally;
  final int cost;
  final Color primaryColor;
  final bool recruited;
  final bool canAfford;
  final bool canRecruitMore;
  final VoidCallback? onRecruit;

  const _ExclusiveCandidateCard({
    required this.ally,
    required this.cost,
    required this.primaryColor,
    required this.recruited,
    required this.canAfford,
    required this.canRecruitMore,
    required this.onRecruit,
  });

  String get _specialty {
    if (ally.dodgeChance > 0.2) return 'GHOST';
    if (ally.atk > 10) return 'ENFORCER';
    if (ally.maxHp > 80) return 'TANK';
    if (ally.attackDelay.inMilliseconds < 900) return 'STRIKER';
    return 'BRAWLER';
  }

  IconData get _specialtyIcon {
    switch (_specialty) {
      case 'GHOST':
        return Icons.visibility_off;
      case 'ENFORCER':
        return Icons.sports_martial_arts;
      case 'TANK':
        return Icons.shield;
      case 'STRIKER':
        return Icons.bolt;
      default:
        return Icons.local_fire_department;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = recruited ? Colors.white24 : ally.themeColor;
    final initials = ally.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    return AnimatedOpacity(
      opacity: recruited ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111118),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recruited
                ? Colors.white12
                : color.withValues(alpha: 0.45),
            width: recruited ? 1 : 1.5,
          ),
          boxShadow: recruited
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // Avatar circle with initials
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: recruited
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
                            )
                          : Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  // Specialty badge
                  Positioned(
                    bottom: 6,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_specialtyIcon, color: color, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            _specialty,
                            style: TextStyle(
                              color: color,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ally.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _StatRow(
                      label: 'ATK',
                      value: ally.atk,
                      maxValue: 20,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 4),
                    _StatRow(
                      label: 'HP',
                      value: ally.maxHp ~/ 5,
                      maxValue: 20,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 4),
                    _StatRow(
                      label: 'DGE',
                      value: (ally.dodgeChance * 100).round(),
                      maxValue: 40,
                      color: Colors.cyanAccent,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (canAfford && canRecruitMore && !recruited)
                            ? onRecruit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: recruited
                              ? Colors.white12
                              : !canRecruitMore
                              ? Colors.white12
                              : !canAfford
                              ? Colors.white12
                              : color,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white12,
                          disabledForegroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          recruited
                              ? 'RECRUITED'
                              : !canRecruitMore
                              ? 'FULL'
                              : '\$$cost',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
