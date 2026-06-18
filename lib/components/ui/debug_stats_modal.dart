import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../game_state.dart';

class DebugStatsModal extends StatefulWidget {
  final GameController gameController;

  const DebugStatsModal({super.key, required this.gameController});

  @override
  State<DebugStatsModal> createState() => _DebugStatsModalState();
}

class _DebugStatsModalState extends State<DebugStatsModal> {
  late final TextEditingController _moneyController;
  late final TextEditingController _strengthController;
  late final TextEditingController _speedController;
  late final TextEditingController _enduranceController;
  late final TextEditingController _intelligenceController;
  late final TextEditingController _potentialController;
  late final TextEditingController _reputationController;

  @override
  void initState() {
    super.initState();
    final controller = widget.gameController;
    final stats = controller.stats;
    _moneyController = TextEditingController(text: controller.money.toString());
    _strengthController = TextEditingController(
      text: stats.strength.toStringAsFixed(1),
    );
    _speedController = TextEditingController(
      text: stats.speed.toStringAsFixed(1),
    );
    _enduranceController = TextEditingController(
      text: stats.endurance.toStringAsFixed(1),
    );
    _intelligenceController = TextEditingController(
      text: stats.intelligence.toStringAsFixed(1),
    );
    _potentialController = TextEditingController(
      text: stats.potential.toStringAsFixed(1),
    );
    _reputationController = TextEditingController(
      text: stats.reputation.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _strengthController.dispose();
    _speedController.dispose();
    _enduranceController.dispose();
    _intelligenceController.dispose();
    _potentialController.dispose();
    _reputationController.dispose();
    super.dispose();
  }

  void _applyValues() {
    widget.gameController.debugSetPlayerValues(
      money: int.tryParse(_moneyController.text.trim()) ?? 0,
      strength: _parseDouble(_strengthController),
      speed: _parseDouble(_speedController),
      endurance: _parseDouble(_enduranceController),
      intelligence: _parseDouble(_intelligenceController),
      potential: _parseDouble(_potentialController),
      reputation: _parseDouble(_reputationController),
    );
    Navigator.of(context).pop();
  }

  void _setGangReady() {
    _moneyController.text = GangCreationRequirements.moneyCost.toString();
    _reputationController.text = GangCreationRequirements.reputationRequired
        .toStringAsFixed(1);
  }

  void _setStrongPreset() {
    _moneyController.text = '5000';
    _strengthController.text = '80.0';
    _speedController.text = '80.0';
    _enduranceController.text = '80.0';
    _intelligenceController.text = '80.0';
    _potentialController.text = '80.0';
    _reputationController.text = '80.0';
  }

  double _parseDouble(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111116),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFFE24B4A), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'TEST VALUES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _setGangReady,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE24B4A),
                        side: const BorderSide(color: Color(0xFFE24B4A)),
                      ),
                      child: const Text('GANG READY'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _setStrongPreset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('STRONG'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildNumberField(
                controller: _moneyController,
                label: 'MONEY',
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _strengthController,
                      label: 'STR',
                      icon: Icons.fitness_center,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      controller: _speedController,
                      label: 'SPD',
                      icon: Icons.directions_run,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _enduranceController,
                      label: 'END',
                      icon: Icons.shield,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      controller: _intelligenceController,
                      label: 'INT',
                      icon: Icons.psychology,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _potentialController,
                      label: 'POT',
                      icon: Icons.star_border,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumberField(
                      controller: _reputationController,
                      label: 'REP',
                      icon: Icons.groups,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _applyValues,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE24B4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: const Color(0xFF16161C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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
    );
  }
}
