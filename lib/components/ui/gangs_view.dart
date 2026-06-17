import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 112, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'FOUND YOUR GANG',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: const Color(0xFFE24B4A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Earn enough money and reputation on the street to found your crew.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequirementsCard(
              money: controller.money,
              reputation: controller.stats.reputation,
              moneyMet: moneyMet,
              repMet: repMet,
            ),
            const SizedBox(height: 20),
            Center(child: GangBadge(gang: _previewGang, size: 96)),
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
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
            _buildInfoCard(
              icon: Icons.group,
              title: 'MEMBER CAPACITY',
              value: '${gameController.gangMembers.length}/$memberCapacity',
              subtitle: 'Recruit from street fights or call exclusive members',
              accent: gang.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildRecruitExclusiveCard(context),
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
                      'Head to the Street tab, win fights, and recruit defeated enemies into your gang.',
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

  Widget _buildRecruitExclusiveCard(BuildContext context) {
    const cost = 250;
    final canRecruit =
        gameController.money >= cost &&
        gameController.gangMembers.length < memberCapacity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gang.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: gang.primaryColor, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXCLUSIVE RECRUIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Call in a random named leader-grade member.',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canRecruit
                ? () {
                    final recruited = gameController
                        .recruitRandomExclusiveMember();
                    if (recruited) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('EXCLUSIVE MEMBER RECRUITED'),
                          duration: Duration(milliseconds: 900),
                        ),
                      );
                    }
                  }
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
            child: const Text(
              '\$250',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
        'No members yet. Recruit defeated enemies from Street or buy an exclusive recruit.',
        style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
      ),
    );
  }

  Widget _buildMemberCard(Ally member) {
    final cost = gameController.trainingCostFor(member);
    final canTrain = member.canTrain && gameController.money >= cost;

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
                  'ATK ${member.atk}  HP ${member.maxHp}  TRAIN ${member.trainingLevel}/${member.maxTrainingLevel}',
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
              member.canTrain ? '\$$cost' : 'MAX',
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
