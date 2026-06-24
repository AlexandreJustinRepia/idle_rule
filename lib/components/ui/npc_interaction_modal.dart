import 'package:flutter/material.dart';
import '../../../controllers/game_controller.dart';
import '../../../models/interactable_npc.dart';

class NpcInteractionModal extends StatefulWidget {
  final InteractableNpc npc;
  final GameController controller;
  final bool disableTalk;

  const NpcInteractionModal({
    super.key,
    required this.npc,
    required this.controller,
    this.disableTalk = false,
  });

  static void show(
    BuildContext context,
    InteractableNpc npc,
    GameController controller, {
    bool disableTalk = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => NpcInteractionModal(
          npc: npc,
          controller: controller,
          disableTalk: disableTalk,
        ),
      ),
    );
  }

  @override
  State<NpcInteractionModal> createState() => _NpcInteractionModalState();
}

class _NpcInteractionModalState extends State<NpcInteractionModal> {
  String _dialogueMessage = '';

  @override
  void initState() {
    super.initState();
    _dialogueMessage = "What do you want, stranger?";
  }

  void _onTalk() {
    widget.controller.talkToNpc(widget.npc);
    setState(() {
      _dialogueMessage = "Good talking to you. Keep your ears to the streets.";
    });
  }

  void _onBribe() {
    if (widget.controller.bribeNpc(widget.npc, 50)) {
      setState(() {
        _dialogueMessage = "Cash? Now you're speaking my language!";
      });
    } else {
      setState(() {
        _dialogueMessage = "You don't even have \$50. Stop wasting my time.";
      });
    }
  }

  void _onRecruit() {
    if (widget.npc.isRecruited) return;
    if (widget.controller.recruitNpc(widget.npc)) {
      setState(() {
        _dialogueMessage = "Alright, I'll join your crew. Let's make some noise.";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      if (widget.npc.relationship < 40) {
        setState(() {
          _dialogueMessage = "I don't trust you enough to join your gang.";
        });
      } else {
        setState(() {
          _dialogueMessage = "You don't have what it takes or your gang is full.";
        });
      }
    }
  }

  void _onFight() {
    widget.controller.fightNpc(widget.npc);
    Navigator.pop(context, 'FIGHT');
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.npc.relationshipTier;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF16181B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tier.color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: tier.color.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
                    backgroundColor: tier.color.withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 32, color: tier.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.npc.name.toUpperCase(),
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
                            color: tier.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tier.label.toUpperCase(),
                            style: TextStyle(
                              color: tier.color,
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
                  // Dialogue bubble
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

                  // Bio
                  Text(
                    'BIO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.npc.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      _StatBadge(icon: Icons.favorite, label: 'HP', value: '${widget.npc.hp}', color: Colors.redAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.sports_martial_arts, label: 'ATK', value: '${widget.npc.atk}', color: Colors.orangeAccent),
                      const SizedBox(width: 12),
                      _StatBadge(icon: Icons.star, label: 'REP', value: '${widget.npc.reputation.toInt()}', color: Colors.amberAccent),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Relationship Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RELATIONSHIP',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${widget.npc.relationship}',
                            style: TextStyle(
                              color: tier.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (widget.npc.relationship + 100) / 200, // mapped from -100 to 100
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(tier.color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  if (widget.npc.isRecruited)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'RECRUITED TO GANG',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: widget.disableTalk ? 'TALK (LOCKED)' : 'TALK',
                          color: widget.disableTalk ? Colors.white24 : Colors.blueAccent,
                          onTap: widget.disableTalk ? null : _onTalk,
                        ),
                        _ActionButton(
                          icon: Icons.attach_money,
                          label: 'BRIBE (\$50)',
                          color: Colors.greenAccent,
                          onTap: widget.controller.money >= 50 ? _onBribe : null,
                        ),
                        _ActionButton(
                          icon: Icons.handshake,
                          label: 'RECRUIT',
                          color: Colors.purpleAccent,
                          onTap: widget.npc.relationship >= 40 ? _onRecruit : null,
                        ),
                        _ActionButton(
                          icon: Icons.gavel,
                          label: 'FIGHT',
                          color: Colors.redAccent,
                          onTap: _onFight,
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
            const SizedBox(height: 2),
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
    required this.onTap,
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
          width: (MediaQuery.of(context).size.width - 32 - 40 - 10) / 2 > 200 
              ? 170 
              : (MediaQuery.of(context).size.width - 32 - 40 - 10) / 2, // approximate half width
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
