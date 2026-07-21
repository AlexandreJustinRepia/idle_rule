import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../controllers/game_controller.dart';
import '../../../models/world_session.dart';

class PlayerInteractionModal extends StatefulWidget {
  final GameCharacterSession targetCharacter;
  final GameController controller;
  final VoidCallback? onFightStarted;

  const PlayerInteractionModal({
    super.key,
    required this.targetCharacter,
    required this.controller,
    this.onFightStarted,
  });

  static void show(
    BuildContext context,
    GameCharacterSession target,
    GameController controller, {
    VoidCallback? onFightStarted,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => PlayerInteractionModal(
          targetCharacter: target,
          controller: controller,
          onFightStarted: onFightStarted,
        ),
      ),
    );
  }

  @override
  State<PlayerInteractionModal> createState() => _PlayerInteractionModalState();
}

class _PlayerInteractionModalState extends State<PlayerInteractionModal> {
  String _dialogueMessage = '';
  bool _hasTalked = false;

  @override
  void initState() {
    super.initState();
    _dialogueMessage = "What do you want?";
  }

  void _onTalk() {
    final messages = [
      "Keep your head down and your fists up.",
      "This street belongs to no one.",
      "We're just passing through.",
      "Watch my back and I'll watch yours.",
      "Respect is earned here, not given.",
      "The strong survive. The weak don't.",
      "Stay sharp out here.",
    ];
    setState(() {
      _dialogueMessage = messages[_random.nextInt(messages.length)];
      _hasTalked = true;
    });
  }

  void _onFight() {
    widget.onFightStarted?.call();
    widget.controller.startPlayerChallenge(widget.targetCharacter);
    Navigator.pop(context, 'FIGHT');
  }

  static final math.Random _random = math.Random();

  @override
  Widget build(BuildContext context) {
    final targetStats = widget.targetCharacter.controller.stats;
    final targetName = widget.targetCharacter.controller.playerName;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF16181B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 28, color: Colors.purpleAccent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          targetName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'RIVAL',
                            style: TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202327),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote, color: Colors.white.withValues(alpha: 0.2), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '"$_dialogueMessage"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'COMBAT STATS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatBadge(icon: Icons.favorite, label: 'HP', value: '${targetStats.maxHealth}', color: Colors.redAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.sports_martial_arts, label: 'ATK', value: '${targetStats.attackDamage}', color: Colors.orangeAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.flash_on, label: 'SPD', value: '${targetStats.speed.toInt()}', color: Colors.cyanAccent),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _StatBadge(icon: Icons.shield, label: 'END', value: '${targetStats.endurance.toInt()}', color: Colors.greenAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.visibility, label: 'DODGE', value: '${(targetStats.dodgeChance * 100).toInt()}%', color: Colors.amberAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.timer, label: 'SPD', value: '${targetStats.attackDelay.inMilliseconds}ms', color: Colors.blueAccent),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: _hasTalked ? 'TALK AGAIN' : 'TALK',
                          color: Colors.blueAccent,
                          onTap: _onTalk,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.gavel,
                          label: 'FIGHT',
                          color: Colors.redAccent,
                          onTap: _onFight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF202327),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isEnabled ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEnabled ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isEnabled ? color : Colors.white24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? color : Colors.white24,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
