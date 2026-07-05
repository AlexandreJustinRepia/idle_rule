import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/class_gacha_view.dart';
import '../../models/character_class.dart';
import '../../models/player_stats.dart';

enum CreationPhase { nameInput, rolling, result }

class CharacterCreationScreen extends StatefulWidget {
  final void Function({
    required String playerName,
    required CharacterClass characterClass,
    required double strength,
    required double speed,
    required double endurance,
    required double intelligence,
    required double potential,
    required double reputation,
  })
  onCharacterCreated;

  const CharacterCreationScreen({super.key, required this.onCharacterCreated});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Random _random = Random();

  CreationPhase _phase = CreationPhase.nameInput;
  CharacterClass? _rolledClass;
  PlayerStats? _rolledStats;
  String? _playerName;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continueToRoll() {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length < 2) {
      _showError('Name must be at least 2 characters');
      return;
    }
    if (name.length > 15) {
      _showError('Name must be 15 characters or less');
      return;
    }

    setState(() {
      _playerName = name.toUpperCase();
      _phase = CreationPhase.rolling;
    });

    _performGachaRoll();
  }

  void _performGachaRoll() {
    setState(() {
      _rolledClass = null;
      _rolledStats = null;
    });
  }

  void _completeGachaRoll(CharacterClass charClass) {
    final stats = charClass.generateBaseStats(_random);
    setState(() {
      _rolledClass = charClass;
      _rolledStats = stats;
      _phase = CreationPhase.result;
    });
  }

  void _createCharacter() {
    if (_rolledClass == null || _rolledStats == null || _playerName == null) {
      return;
    }

    widget.onCharacterCreated(
      playerName: _playerName!,
      characterClass: _rolledClass!,
      strength: _rolledStats!.strength,
      speed: _rolledStats!.speed,
      endurance: _rolledStats!.endurance,
      intelligence: _rolledStats!.intelligence,
      potential: _rolledStats!.potential,
      reputation: _rolledStats!.reputation,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE24B4A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _phase == CreationPhase.nameInput
            ? _buildNameInputPhase()
            : _phase == CreationPhase.rolling
            ? Center(child: ClassGachaView(onRollComplete: _completeGachaRoll))
            : _buildResultPhase(),
      ),
    );
  }

  Widget _buildNameInputPhase() {
    return _buildCenteredScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        _buildSymbol(),
        const SizedBox(height: 40),
        Text(
          'CREATE YOUR',
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CHARACTER',
          style: GoogleFonts.bebasNeue(
            fontSize: 56,
            color: const Color(0xFFE24B4A),
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 50),
        _buildNameInput(),
        const SizedBox(height: 24),
        _buildClassPreview(),
        const SizedBox(height: 40),
        _buildStartButton(),
      ],
    );
  }

  Widget _buildCenteredScrollView({
    required EdgeInsetsGeometry padding,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymbol() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE24B4A), width: 2),
        color: const Color(0xFFE24B4A).withValues(alpha: 0.1),
      ),
      child: const Icon(Icons.person, size: 40, color: Color(0xFFE24B4A)),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: _nameController,
        style: GoogleFonts.bebasNeue(
          fontSize: 28,
          color: Colors.white,
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
        maxLength: 15,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: 'ENTER NAME',
          hintStyle: GoogleFonts.bebasNeue(
            fontSize: 20,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 4,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          counterText: '',
        ),
        onSubmitted: (_) => _continueToRoll(),
      ),
    );
  }

  Widget _buildClassPreview() {
    return Column(
      children: [
        Text(
          'YOUR FATE WILL BE SEALED',
          style: GoogleFonts.bebasNeue(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: CharacterClasses.allClasses.map((charClass) {
            final isHidden = charClass.gachaChance < 0.10;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isHidden
                      ? Colors.white.withValues(alpha: 0.1)
                      : charClass.tierColor.withValues(alpha: 0.4),
                ),
                color: isHidden
                    ? Colors.transparent
                    : charClass.tierColor.withValues(alpha: 0.1),
              ),
              child: Text(
                charClass.emoji,
                style: TextStyle(
                  fontSize: isHidden ? 10 : 14,
                  color: isHidden
                      ? Colors.white.withValues(alpha: 0.2)
                      : charClass.tierColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _continueToRoll,
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFFE24B4A), Color(0xFF8B0000)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'ROLL',
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultPhase() {
    if (_rolledClass == null || _rolledStats == null) {
      return const SizedBox.shrink();
    }
    final charClass = _rolledClass!;
    final stats = _rolledStats!;
    final tierLabel = CharacterClasses.getTierLabel(charClass);

    return _buildCenteredScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildResultHeader(charClass, tierLabel),
        const SizedBox(height: 32),
        _buildClassEmblem(charClass),
        const SizedBox(height: 16),
        _buildClassName(charClass),
        const SizedBox(height: 8),
        _buildClassDesc(charClass),
        const SizedBox(height: 32),
        _buildStatGrid(stats),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'BEGIN',
                onTap: _createCharacter,
                isSecondary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultHeader(CharacterClass charClass, String tierLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: charClass.tierColor, width: 1),
          ),
          child: Text(
            'TIER $tierLabel',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: charClass.tierColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassEmblem(CharacterClass charClass) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            charClass.tierColor.withValues(alpha: 0.3),
            charClass.tierColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: charClass.tierColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: charClass.glowColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(charClass.emoji, style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  Widget _buildClassName(CharacterClass charClass) {
    return Text(
      charClass.name.toUpperCase(),
      style: GoogleFonts.bebasNeue(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: charClass.tierColor,
        letterSpacing: 6,
      ),
    );
  }

  Widget _buildClassDesc(CharacterClass charClass) {
    return Text(
      charClass.description,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildStatGrid(PlayerStats stats) {
    final statEntries = [
      {'label': 'STR', 'value': stats.strength, 'icon': '💪'},
      {'label': 'SPD', 'value': stats.speed, 'icon': '⚡'},
      {'label': 'END', 'value': stats.endurance, 'icon': '🛡️'},
      {'label': 'INT', 'value': stats.intelligence, 'icon': '🧠'},
      {'label': 'POT', 'value': stats.potential, 'icon': '✨'},
      {'label': 'REP', 'value': stats.reputation, 'icon': '⭐'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BASE STATS',
            style: GoogleFonts.bebasNeue(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          ...statEntries.map((entry) {
            final rank = PlayerStats.getRank(entry['value'] as double);
            final barColor = rank.color;
            final label = entry['label'] as String;
            final maxVal = label == 'REP'
                ? 20.0
                : (label == 'INT' || label == 'POT')
                ? 90.0
                : 60.0;
            final percent = ((entry['value'] as double) / maxVal).clamp(
              0.0,
              1.0,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Text(entry['icon'] as String)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      entry['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white10,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percent,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                barColor,
                                barColor.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      (entry['value'] as double).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: barColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required bool isSecondary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSecondary
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFE24B4A), Color(0xFF8B0000)],
                ),
          border: isSecondary ? Border.all(color: Colors.white24) : null,
          color: isSecondary ? Colors.transparent : null,
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSecondary ? Colors.white70 : Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
