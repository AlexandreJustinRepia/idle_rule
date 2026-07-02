import 'dart:ui' show Tangent;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';
import 'exclusive_recruit_page.dart';
import 'gang_training_page.dart';
import 'gang_formation_page.dart';

class GangsView extends StatelessWidget {
  final GameController gameController;

  const GangsView({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        final gang = gameController.gang;
        if (gang == null) {
          return GangCreationPanel(gameController: gameController);
        }
        return GangProfilePanel(
          gameController: gameController,
          gang: gang,
          memberCapacity: gameController.gangMemberCapacity,
        );
      },
    );
  }
}

// ─── Gang Badge ───────────────────────────────────────────────────────────────

class GangBadge extends StatelessWidget {
  final Gang gang;
  final double size;

  const GangBadge({super.key, required this.gang, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gang.primaryColor,
            gang.primaryColor.withValues(alpha: 0.65),
          ],
        ),
        border: Border.all(color: gang.accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: gang.primaryColor.withValues(alpha: 0.45),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(gang.emblem, color: gang.accentColor, size: size * 0.42),
    );
  }
}

// ─── Gang Creation Panel ──────────────────────────────────────────────────────

class GangCreationPanel extends StatefulWidget {
  final GameController gameController;

  const GangCreationPanel({super.key, required this.gameController});

  @override
  State<GangCreationPanel> createState() => _GangCreationPanelState();
}

class _GangCreationPanelState extends State<GangCreationPanel> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmblemId = GangEmblems.all.first.id;
  Color _primaryColor = GangColorPresets.primary.first;
  Color _accentColor = GangColorPresets.accent.first;
  String? _error;
  bool _showCreationForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Gang get _previewGang => Gang(
    name: _nameController.text.trim().isEmpty
        ? 'YOUR GANG'
        : _nameController.text.trim().toUpperCase(),
    emblemId: _selectedEmblemId,
    primaryColor: _primaryColor,
    accentColor: _accentColor,
  );

  void _createGang() {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Gang name must be at least 2 characters');
      return;
    }
    if (name.length > 18) {
      setState(() => _error = 'Gang name must be 18 characters or less');
      return;
    }

    setState(() => _error = null);

    if (!widget.gameController.meetsGangRequirements) {
      setState(
        () => _error = 'You do not meet the money or reputation requirements',
      );
      return;
    }

    final created = widget.gameController.createGang(
      name: name,
      emblemId: _selectedEmblemId,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
    );
    if (!created) {
      setState(
        () => _error = 'Could not create gang. Check your requirements.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.gameController;
    final meetsRequirements = controller.meetsGangRequirements;
    final moneyMet = controller.money >= GangCreationRequirements.moneyCost;
    final repMet =
        controller.stats.reputation >=
        GangCreationRequirements.reputationRequired;

    if (!meetsRequirements || !_showCreationForm) {
      return _buildLockedState(
        money: controller.money,
        reputation: controller.stats.reputation,
        moneyMet: moneyMet,
        repMet: repMet,
        meetsRequirements: meetsRequirements,
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CREATE YOUR GANG',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 26,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),
            Center(child: GangBadge(gang: _previewGang, size: 84)),
            const SizedBox(height: 8),
            Text(
              _previewGang.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('GANG NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 18,
              onChanged: (_) => setState(() {
                _error = null;
              }),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: 'Enter gang name',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                filled: true,
                fillColor: const Color(0xFF16161C),
                counterStyle: const TextStyle(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE24B4A)),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 11),
              ),
            ],
            const SizedBox(height: 20),
            _buildLabel('EMBLEM'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: GangEmblems.all.map((emblem) {
                final selected = emblem.id == _selectedEmblemId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmblemId = emblem.id),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? _primaryColor.withValues(alpha: 0.2)
                          : const Color(0xFF16161C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _primaryColor : Colors.white12,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      emblem.icon,
                      color: selected ? _accentColor : Colors.white54,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildLabel('PRIMARY COLOR'),
            const SizedBox(height: 10),
            _buildColorPicker(
              colors: GangColorPresets.primary,
              selected: _primaryColor,
              onSelected: (color) => setState(() => _primaryColor = color),
            ),
            const SizedBox(height: 20),
            _buildLabel('ACCENT COLOR'),
            const SizedBox(height: 10),
            _buildColorPicker(
              colors: GangColorPresets.accent,
              selected: _accentColor,
              onSelected: (color) => setState(() => _accentColor = color),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: meetsRequirements ? _createGang : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE24B4A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  meetsRequirements
                      ? 'CREATE GANG (\$${GangCreationRequirements.moneyCost})'
                      : 'REQUIREMENTS NOT MET',
                  style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedState({
    required int money,
    required double reputation,
    required bool moneyMet,
    required bool repMet,
    required bool meetsRequirements,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.groups_2,
              color: const Color(0xFFE24B4A).withValues(alpha: 0.75),
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              'FOUND YOUR GANG',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 26,
                color: const Color(0xFFE24B4A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Earn enough money and reputation on the street to found your crew.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            _buildRequirementsCard(
              money: money,
              reputation: reputation,
              moneyMet: moneyMet,
              repMet: repMet,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF111116),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Customization unlocks when both requirements are met.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: meetsRequirements
                    ? () => setState(() => _showCreationForm = true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE24B4A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  meetsRequirements ? 'CREATE GANG' : 'REQUIREMENTS NOT MET',
                  style: GoogleFonts.bebasNeue(fontSize: 19, letterSpacing: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildRequirementsCard({
    required int money,
    required double reputation,
    required bool moneyMet,
    required bool repMet,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (moneyMet && repMet)
              ? const Color(0xFF34C759).withValues(alpha: 0.4)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'REQUIREMENTS',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            icon: Icons.attach_money,
            label: 'MONEY',
            current: '\$$money',
            required: '\$${GangCreationRequirements.moneyCost}',
            met: moneyMet,
            progress: (money / GangCreationRequirements.moneyCost).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            icon: Icons.star,
            label: 'REPUTATION',
            current: reputation.toStringAsFixed(1),
            required: GangCreationRequirements.reputationRequired.toStringAsFixed(1),
            met: repMet,
            progress: (reputation / GangCreationRequirements.reputationRequired).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow({
    required IconData icon,
    required String label,
    required String current,
    required String required,
    required bool met,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: met ? const Color(0xFF34C759) : Colors.white38,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Icon(
              met ? Icons.check_circle : Icons.radio_button_unchecked,
              color: met ? const Color(0xFF34C759) : Colors.white24,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              current,
              style: TextStyle(
                color: met ? const Color(0xFF34C759) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '/ $required',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              met ? const Color(0xFF34C759) : const Color(0xFFE24B4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required List<Color> colors,
    required Color selected,
    required ValueChanged<Color> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final isSelected = color.toARGB32() == selected.toARGB32();
        return GestureDetector(
          onTap: () => onSelected(color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white24,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Gang Profile Panel ───────────────────────────────────────────────────────

class GangProfilePanel extends StatelessWidget {
  final GameController gameController;
  final Gang gang;
  final int memberCapacity;

  const GangProfilePanel({
    super.key,
    required this.gameController,
    required this.gang,
    required this.memberCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 112, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'YOUR GANG',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 24,
                color: Colors.white54,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            Center(child: GangBadge(gang: gang, size: 110)),
            const SizedBox(height: 12),
            Text(
              gang.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 32,
                color: gang.primaryColor,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              GangEmblems.byId(gang.emblemId).label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gang.accentColor.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            _buildBuildingCard(),
            const SizedBox(height: 12),
            _buildRecruitExclusiveCard(context),
            const SizedBox(height: 12),
            _buildTrainingRoomCard(context),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GangFormationPage(gameController: gameController),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gang.accentColor.withValues(alpha: 0.15),
                      const Color(0xFF111116),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gang.accentColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.military_tech, color: gang.accentColor, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FORMATION TACTICS',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Configure player presence and active squad layouts',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingCard() {
    final canLevelUp =
        gameController.money >= gameController.upgradeGangBuildingCost;
    final canAdvance =
        gameController.canAdvanceGangBuilding &&
        gameController.money >= gameController.advanceGangBuildingCost;
    final nextStageIndex = (gameController.gangBuildingStage + 1).clamp(
      0,
      GangBuildings.stages.length - 1,
    );
    final nextStage = GangBuildings.stages[nextStageIndex];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gang.primaryColor.withValues(alpha: 0.3)),
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
                  color: gang.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.apartment,
                  color: gang.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameController.gangBuildingName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LV. ${gameController.gangBuildingLevel}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canLevelUp ? gameController.upgradeGangBuilding : null,
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
                  '\$${gameController.upgradeGangBuildingCost}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
          if (gameController.gangBuildingStage < GangBuildings.stages.length - 1) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    gameController.canAdvanceGangBuilding
                        ? 'READY TO UPGRADE INTO ${nextStage.name.toUpperCase()}'
                        : '${nextStage.name.toUpperCase()} UNLOCKS AT LV.${nextStage.minLevel}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: canAdvance ? gameController.advanceGangBuildingStage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gang.primaryColor,
                    disabledForegroundColor: Colors.white24,
                    side: BorderSide(
                      color: gameController.canAdvanceGangBuilding
                          ? gang.primaryColor
                          : Colors.white12,
                    ),
                  ),
                  child: Text('\$${gameController.advanceGangBuildingCost}'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrainingRoomCard(BuildContext context) {
    final isUnlocked = gameController.gangBuildingStage >= 1;
    final nextStage = GangBuildings.stages[1]; // Training Center

    if (!isUnlocked) {
      return _LockedTrainingRoomCard(
        gameController: gameController,
        nextStage: nextStage,
      );
    }

    // Unlocked — navigate to training room
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GangTrainingPage(gameController: gameController),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gang.primaryColor.withValues(alpha: 0.15),
              const Color(0xFF111116),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gang.primaryColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.fitness_center, color: gang.primaryColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRAINING ROOM',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Train crew members, purchase batch recruits, promote leaders',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitExclusiveCard(BuildContext context) {
    final exclusiveCount = gameController.exclusiveMemberCount;
    final canRecruit = gameController.canRecruitExclusive;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExclusiveRecruitPage(gameController: gameController),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gang.primaryColor.withValues(alpha: 0.18),
              const Color(0xFF111116),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gang.primaryColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    gang.primaryColor,
                    gang.primaryColor.withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: gang.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.workspace_premium,
                color: gang.accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXCLUSIVE LEADERS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    canRecruit
                        ? 'Browse & recruit elite leaders ($exclusiveCount/3)'
                        : 'Exclusive slots full (3/3)',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: gang.primaryColor.withValues(alpha: 0.7),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Locked Training Room Card ───────────────────────────────────────

class _LockedTrainingRoomCard extends StatefulWidget {
  final GameController gameController;
  final GangBuildingStage nextStage;

  const _LockedTrainingRoomCard({
    required this.gameController,
    required this.nextStage,
  });

  @override
  State<_LockedTrainingRoomCard> createState() =>
      _LockedTrainingRoomCardState();
}

class _LockedTrainingRoomCardState extends State<_LockedTrainingRoomCard>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _shimmerController;
  late final Animation<double> _breathAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breathAnim = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = widget.gameController.gangBuildingLevel;
    final requiredLevel = widget.nextStage.minLevel;
    final progress = (currentLevel / requiredLevel).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final progressColor = Color.lerp(
      const Color(0xFFE24B4A),
      const Color(0xFFFFCC00),
      progress,
    )!;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _shimmerController]),
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: CustomPaint(
            painter: _ShimmerBorderPainter(
              progress: _shimmerController.value,
              breathe: _breathAnim.value,
              borderRadius: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ───────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFCC00).withValues(
                                alpha: 0.08 + _breathAnim.value * 0.28,
                              ),
                              blurRadius: 6 + _breathAnim.value * 14,
                              spreadRadius: _breathAnim.value * 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: Color.lerp(
                            Colors.white24,
                            const Color(0xFFFFCC00),
                            _breathAnim.value * 0.55,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'TRAINING ROOM',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 18,
                            color: Colors.white38,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Color.lerp(
                                Colors.white30,
                                const Color(0xFFFFCC00),
                                _breathAnim.value * 0.4,
                              ),
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LOCKED',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                  const SizedBox(height: 12),
                  // ── Requirement + Progress ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REQUIREMENT',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.nextStage.name} Lv.$requiredLevel',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CURRENT PROGRESS',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lv.$currentLevel / Lv.$requiredLevel',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ── Progress bar ─────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shimmer Border Painter ───────────────────────────────────────────────────

class _ShimmerBorderPainter extends CustomPainter {
  final double progress; // 0.0→1.0, position of spark around perimeter
  final double breathe;  // 0.0→1.0, breathing phase
  final double borderRadius;

  const _ShimmerBorderPainter({
    required this.progress,
    required this.breathe,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      radius,
    );

    // Base border — faint, always visible, breathes slightly
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.08 + breathe * 0.06);
    canvas.drawRRect(rrect, basePaint);

    // Build perimeter path and find the spark position
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold(0.0, (sum, m) => sum + m.length);
    final targetDist = progress * totalLength;

    // Find tangent at target distance
    double walked = 0;
    Tangent? tangent;
    for (final metric in metrics) {
      if (walked + metric.length >= targetDist) {
        tangent = metric.getTangentForOffset(targetDist - walked);
        break;
      }
      walked += metric.length;
    }
    if (tangent == null) return;

    final sparkPos = tangent.position;
    const sparkRadius = 36.0;

    // Glow trail behind the spark
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFCC00).withValues(alpha: 0.55 + breathe * 0.2),
          const Color(0xFFFFCC00).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sparkPos, radius: sparkRadius));

    final arcPath = _subPath(path, targetDist, totalLength, sparkRadius * 0.8);
    canvas.drawPath(arcPath, glowPaint);

    // Bright dot at the spark tip
    canvas.drawCircle(
      sparkPos,
      2.5 + breathe * 1.0,
      Paint()
        ..color = const Color(0xFFFFEE88).withValues(alpha: 0.85 + breathe * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      sparkPos,
      1.5,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  /// Returns a sub-path of [original] of [length] centred at [center].
  Path _subPath(Path original, double center, double total, double length) {
    final half = length / 2;
    final start = center - half;
    final end = center + half;
    final metrics = original.computeMetrics().toList();

    Path result = Path();
    bool started = false;
    double wrap(double d) => ((d % total) + total) % total;

    double current = 0;
    for (final metric in metrics) {
      final mStart = current;
      double localStart = wrap(start) - mStart;
      double localEnd = wrap(end) - mStart;

      if (localStart < 0) localStart = 0;
      if (localEnd > metric.length) localEnd = metric.length;
      if (localStart < localEnd) {
        final extracted = metric.extractPath(localStart, localEnd);
        if (!started) {
          result = extracted;
          started = true;
        } else {
          result.addPath(extracted, Offset.zero);
        }
      }
      current += metric.length;
    }
    return result;
  }

  @override
  bool shouldRepaint(_ShimmerBorderPainter old) =>
      old.progress != progress || old.breathe != breathe;
}
