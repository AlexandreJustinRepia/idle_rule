import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../models/character_customization.dart';
import 'character_customize_editor.dart';

/// Full-screen UI for customizing the player's hero appearance.
class CharacterCustomizeScreen extends StatefulWidget {
  final GameController gameController;

  const CharacterCustomizeScreen({super.key, required this.gameController});

  @override
  State<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState extends State<CharacterCustomizeScreen> {
  late CharacterCustomization _custom;

  @override
  void initState() {
    super.initState();
    _custom = widget.gameController.customization;
  }

  void _apply() {
    widget.gameController.updateCustomization(_custom);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'CUSTOMIZE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
        actions: [
          TextButton(
            onPressed: _apply,
            child: const Text(
              'APPLY',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFFE24B4A),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: CharacterCustomizeEditor(
            custom: _custom,
            onChanged: (updated) => setState(() => _custom = updated),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'APPLY CHANGES',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
