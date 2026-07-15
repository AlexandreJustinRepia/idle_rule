import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/enemy.dart';

class EncounterTalkOverlay extends StatelessWidget {
  final String npcName;
  final NpcType npcType;
  final String? gangName;
  final String infoText;
  final String talkState; // "choices", "provoked", "complimented", "recruited", "recruitFailed"
  final VoidCallback onProvoke;
  final VoidCallback onCompliment;
  final VoidCallback onRecruit;
  final VoidCallback onLeave;
  final bool canRecruit;

  const EncounterTalkOverlay({
    super.key,
    required this.npcName,
    required this.npcType,
    this.gangName,
    required this.infoText,
    required this.talkState,
    required this.onProvoke,
    required this.onCompliment,
    required this.onRecruit,
    required this.onLeave,
    required this.canRecruit,
  });

  @override
  Widget build(BuildContext context) {
    String typeLabel = "Unknown";
    Color typeColor = Colors.white70;

    switch (npcType) {
      case NpcType.civilian:
        typeLabel = "Civilian";
        typeColor = Colors.grey[400]!;
        break;
      case NpcType.thug:
        typeLabel = "Thug";
        typeColor = const Color(0xFFE24B4A);
        break;
      case NpcType.merchant:
        typeLabel = "Merchant";
        typeColor = Colors.greenAccent;
        break;
      case NpcType.cop:
        typeLabel = "Police Officer";
        typeColor = Colors.blueAccent;
        break;
      case NpcType.gangMember:
        typeLabel = gangName != null ? "$gangName Member" : "Gang Member";
        typeColor = Colors.purpleAccent;
        break;
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF222222).withValues(alpha: 0.9),
                  const Color(0xFF111111).withValues(alpha: 0.75),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 22, color: typeColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "TALKING TO: $npcName ($typeLabel)",
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Dialogue Text Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Text(
                          infoText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Choices or Result Confirmation Button
                      if (talkState == "choices") ...[
                        _buildChoiceButton(
                          label: "PROVOKE NPC",
                          subtitle: "\"Your face looks like a punching bag!\"",
                          icon: Icons.flash_on,
                          color: const Color(0xFFE24B4A),
                          onTap: onProvoke,
                        ),
                        const SizedBox(height: 12),
                        _buildChoiceButton(
                          label: "COMPLIMENT NPC",
                          subtitle: "\"You look tough, respect.\"",
                          icon: Icons.thumb_up,
                          color: const Color(0xFF4CAF50),
                          onTap: onCompliment,
                        ),
                        const SizedBox(height: 12),
                        _buildChoiceButton(
                          label: "RECRUIT TO CREW",
                          subtitle: "\"We're building something big. Join us.\"",
                          icon: Icons.group_add,
                          color: const Color(0xFFFFB300),
                          onTap: onRecruit,
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: onLeave,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: talkState == "provoked"
                                  ? const Color(0xFFE24B4A)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: talkState == "provoked"
                                    ? const Color(0xFFE24B4A)
                                    : Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              boxShadow: talkState == "provoked"
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE24B4A).withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                talkState == "provoked" ? "FIGHT!" : "LEAVE",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
    );
  }
}
