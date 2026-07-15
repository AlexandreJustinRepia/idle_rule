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
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.symmetric(horizontal: 40.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ENCOUNTERED:',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                 Text(
                  npcName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildButton(
                        label: 'FIGHT',
                        onTap: onFight,
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        label: 'TALK',
                        onTap: onTalk,
                        isPrimary: false,
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
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFE24B4A).withValues(alpha: 0.9)
              : isDisabled
              ? Colors.grey[850]
              : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFE24B4A)
                : isDisabled
                ? Colors.grey[700]!
                : Colors.grey[800]!,
            width: 2,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPrimary
                ? Colors.white
                : isDisabled
                ? Colors.grey[600]
                : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
