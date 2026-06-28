import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';
import 'exclusive_recruit_page.dart';

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
            progress: (money / GangCreationRequirements.moneyCost).clamp(
              0.0,
              1.0,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            icon: Icons.star,
            label: 'REPUTATION',
            current: reputation.toStringAsFixed(1),
            required: GangCreationRequirements.reputationRequired
                .toStringAsFixed(1),
            met: repMet,
            progress: (reputation / GangCreationRequirements.reputationRequired)
                .clamp(0.0, 1.0),
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
            _buildInfoCard(
              icon: Icons.group,
              title: 'COMMAND SIZE',
              value: '$memberCapacity',
              subtitle:
                  '${gameController.gangMembers.length} total members in roster',
              accent: gang.primaryColor,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.bolt,
                    title: 'ATTACK POWER',
                    value: gameController.gangAttackPower.toString(),
                    subtitle: 'Best members used for turf attacks',
                    accent: const Color(0xFFE24B4A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.military_tech,
                    title: 'TOTAL POWER',
                    value: gameController.gangTotalPower.toString(),
                    subtitle: 'Strength of every recruited member',
                    accent: gang.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecruitExclusiveCard(context),
            const SizedBox(height: 12),
            _buildRecruitTiersSection(context),
            const SizedBox(height: 12),
            _buildFormationCard(),
            const SizedBox(height: 12),
            if (gameController.gangMembers.isEmpty)
              _buildEmptyMembersCard()
            else
              ...gameController.gangMembers.map(_buildMemberCard),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.palette_outlined,
              title: 'COLORS',
              value: 'CUSTOM',
              subtitle: 'Primary & accent emblem colors',
              accent: gang.accentColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorDot(gang.primaryColor),
                  const SizedBox(width: 6),
                  _colorDot(gang.accentColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF16161C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gang.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: gang.primaryColor, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Recruit numbers, train them, then send your best command group to take turf.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
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
                onPressed: canLevelUp
                    ? gameController.upgradeGangBuilding
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gang.primaryColor,
                  foregroundColor: gang.accentColor,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '\$${gameController.upgradeGangBuildingCost}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (gameController.gangBuildingStage <
              GangBuildings.stages.length - 1) ...[
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
                  onPressed: canAdvance
                      ? gameController.advanceGangBuildingStage
                      : null,
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

  Widget _buildRecruitExclusiveCard(BuildContext context) {
    final exclusiveCount = gameController.exclusiveMemberCount;
    final canRecruit = gameController.canRecruitExclusive;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ExclusiveRecruitPage(gameController: gameController),
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
          border: Border.all(
            color: gang.primaryColor.withValues(alpha: 0.5),
          ),
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
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
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

  Widget _buildRecruitTiersSection(BuildContext context) {
    final job = gameController.gangTrainingJob;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (job != null) ...[
          _buildTrainingJobCard(job),
          const SizedBox(height: 10),
        ],
        ...RecruitTiers.all.map(
          (tier) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildRecruitTierCard(tier),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingJobCard(GangTrainingJob job) {
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

  Widget _buildRecruitTierCard(RecruitTier tier) {
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

  Widget _buildFormationCard() {
    final formationSize = gameController.gangFormationSize;
    final totalEnemyPower = (memberCapacity * 1.2).round();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE24B4A).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE24B4A).withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Banner ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A0A), Color(0xFF2C0C0C), Color(0xFF1A0A0A)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 8),
                Text(
                  'TURF WAR FORMATION !!',
                  style: GoogleFonts.bebasNeue(
                    color: const Color(0xFFFFD700),
                    fontSize: 20,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 20),
              ],
            ),
          ),

          // ── Battlefield Scene ────────────────────────────────────────
          Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1C1408), Color(0xFF0D0F13)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // LEFT SIDE — player gang crowd
                Expanded(
                  child: _buildCrowdSide(
                    count: formationSize.clamp(0, memberCapacity),
                    maxCount: memberCapacity,
                    facingRight: true,
                    primaryColor: gang.primaryColor,
                    label: gang.name,
                  ),
                ),

                // CENTER — VS
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE24B4A).withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'VS',
                          style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // RIGHT SIDE — rival gang crowd
                Expanded(
                  child: _buildCrowdSide(
                    count: totalEnemyPower.clamp(0, memberCapacity),
                    maxCount: memberCapacity,
                    facingRight: false,
                    primaryColor: const Color(0xFF455A64),
                    label: 'RIVALS',
                  ),
                ),
              ],
            ),
          ),

          // ── Formation Count Summary ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                const Icon(Icons.groups, color: Color(0xFFE24B4A), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'FORMATION  $formationSize / $memberCapacity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: formationSize > 0
                      ? gameController.clearFormation
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE24B4A),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          // ── Tier Rows ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: RecruitTiers.all.map(_buildFormationTierRow).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders a crowd of character silhouettes for the battlefield scene.
  Widget _buildCrowdSide({
    required int count,
    required int maxCount,
    required bool facingRight,
    required Color primaryColor,
    required String label,
  }) {
    const int maxSlots = 12;
    final int displayCount = maxCount == 0
        ? 0
        : (count / maxCount * maxSlots).round().clamp(0, maxSlots);

    // Arrange icons in 2 rows (front + back)
    final int frontRow = (displayCount / 2).ceil();
    final int backRow = displayCount - frontRow;

    Widget buildRow(int n, double iconSize, double opacity) {
      final icons = List.generate(n, (i) {
        final iconData = (i % 3 == 0)
            ? Icons.person
            : (i % 3 == 1)
                ? Icons.person_2
                : Icons.person_3;
        return Transform.scale(
          scaleX: facingRight ? 1 : -1,
          child: Icon(iconData, size: iconSize, color: primaryColor.withValues(alpha: opacity)),
        );
      });
      return Row(
        mainAxisAlignment: facingRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: facingRight ? icons.reversed.toList() : icons,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            facingRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: facingRight ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          buildRow(backRow, 18, 0.45),
          buildRow(frontRow, 24, 0.85),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFormationTierRow(RecruitTier tier) {
    final available = gameController.gangTierCounts[tier.tier] ?? 0;
    final selected = gameController.formationCounts[tier.tier] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Tier badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: gang.primaryColor.withValues(alpha: selected > 0 ? 0.2 : 0.07),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: gang.primaryColor.withValues(alpha: selected > 0 ? 0.5 : 0.15),
              ),
            ),
            child: Center(
              child: Text(
                'T${tier.tier}',
                style: TextStyle(
                  color: selected > 0 ? gang.primaryColor : Colors.white30,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tier.name.toUpperCase(),
              style: TextStyle(
                color: selected > 0 ? Colors.white70 : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            '$selected / $available',
            style: TextStyle(
              color: selected > 0 ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          _buildFormationButton(
            Icons.remove,
            selected > 0
                ? () =>
                      gameController.setFormationCount(tier.tier, selected - 1)
                : null,
          ),
          const SizedBox(width: 6),
          _buildFormationButton(
            Icons.add,
            available > selected &&
                    gameController.gangFormationSize < memberCapacity
                ? () =>
                      gameController.setFormationCount(tier.tier, selected + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFormationButton(IconData icon, VoidCallback? onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null
              ? gang.primaryColor.withValues(alpha: 0.18)
              : Colors.white10,
          disabledBackgroundColor: Colors.white10,
          foregroundColor: onPressed != null ? gang.primaryColor : Colors.white24,
          disabledForegroundColor: Colors.white24,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
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

  Widget _buildMemberCard(Ally member) {
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
