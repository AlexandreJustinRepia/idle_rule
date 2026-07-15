import 'dart:ui';
import 'package:flutter/material.dart';

class EncounterChoiceOverlay extends StatelessWidget {
  final String npcName;
  final VoidCallback onFight;
  final VoidCallback? onTalk;

  const EncounterChoiceOverlay({
    super.key,
    required this.npcName,
    required this.onFight,
    this.onTalk,
  });

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'ENCOUNTERED:',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        npcName.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceOption(
                              label: 'FIGHT',
                              description: 'Combat encounter',
                              icon: Icons.gavel,
                              color: const Color(0xFFE24B4A),
                              onTap: onFight,
                              isDisabled: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildChoiceOption(
                              label: 'TALK',
                              description: 'Dialogue choices',
                              icon: Icons.chat_bubble,
                              color: const Color(0xFF2196F3),
                              onTap: onTalk ?? () {},
                              isDisabled: onTalk == null,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildChoiceOption({
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    final finalColor = isDisabled ? Colors.grey : color;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDisabled 
              ? Colors.white.withValues(alpha: 0.05) 
              : finalColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDisabled 
                ? Colors.white.withValues(alpha: 0.1) 
                : finalColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: !isDisabled
              ? [
                  BoxShadow(
                    color: finalColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.white24 : finalColor,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.white30 : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                color: isDisabled ? Colors.white12 : Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
