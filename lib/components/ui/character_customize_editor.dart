import 'package:flutter/material.dart';
import '../../models/character_customization.dart';
import '../shared/character_painters.dart';

/// Reusable customization editor with a sticky animated preview on top and a
/// scrollable list of option pickers below.
///
/// Holds no customization state of its own: it renders the given [custom] value
/// and reports every change through [onChanged]. Used both by the in-game
/// customize screen and by the character creation flow.
///
/// The widget expects a bounded height from its parent (e.g. inside an
/// [Expanded] or as a [Scaffold] body) so the preview can stay pinned while the
/// options scroll.
class CharacterCustomizeEditor extends StatefulWidget {
  final CharacterCustomization custom;
  final ValueChanged<CharacterCustomization> onChanged;

  const CharacterCustomizeEditor({
    super.key,
    required this.custom,
    required this.onChanged,
  });

  // Color preset lists
  static const List<Color> skinTones = [
    Color(0xFFE8D5C0),
    Color(0xFFD4C0B0),
    Color(0xFFC4A882),
    Color(0xFFA08060),
    Color(0xFF8B7355),
    Color(0xFF6B4423),
    Color(0xFF5C3A1E),
    Color(0xFF3E2723),
  ];

  static const List<Color> hairColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Color(0xFF1A1A1A), // black
    Color(0xFF8B4513), // brown
    Color(0xFFDAA520), // blonde
    Colors.white,
  ];

  static const List<Color> outfitColors = [
    Color(0xFF1E3A5F), // navy
    Color(0xFF2A2A3A), // dark gray
    Color(0xFF8B0000), // dark red
    Color(0xFF006400), // dark green
    Color(0xFF4A148C), // purple
    Color(0xFF3E2723), // brown
    Color(0xFF212121), // black
    Color(0xFFB71C1C), // red
    Color(0xFF01579B), // blue
    Color(0xFF33691E), // green
  ];

  static const List<Color> accentColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.deepPurpleAccent,
  ];

  @override
  State<CharacterCustomizeEditor> createState() =>
      _CharacterCustomizeEditorState();
}

class _CharacterCustomizeEditorState extends State<CharacterCustomizeEditor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  CharacterCustomization get custom => widget.custom;
  ValueChanged<CharacterCustomization> get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sticky preview
        _buildPreview(),
        const SizedBox(height: 16),

        // Scrollable options
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Skin Color
                _buildSectionTitle('SKIN COLOR'),
                const SizedBox(height: 8),
                _buildColorGrid(CharacterCustomizeEditor.skinTones, (color) {
                  final dark = Color.lerp(color, Colors.brown, 0.3)!;
                  onChanged(
                    custom.copyWith(skinColor: color, skinColorDark: dark),
                  );
                }, custom.skinColor),
                const SizedBox(height: 20),

                // Hair Color
                _buildSectionTitle('HAIR COLOR'),
                const SizedBox(height: 8),
                _buildColorGrid(CharacterCustomizeEditor.hairColors, (color) {
                  onChanged(custom.copyWith(hairColor: color));
                }, custom.hairColor),
                const SizedBox(height: 20),

                // Hair Style
                _buildSectionTitle('HAIR STYLE'),
                const SizedBox(height: 8),
                _buildHairStyleGrid(),
                const SizedBox(height: 20),

                // Outfit Color
                _buildSectionTitle('OUTFIT COLOR'),
                const SizedBox(height: 8),
                _buildColorGrid(CharacterCustomizeEditor.outfitColors, (color) {
                  onChanged(custom.copyWith(outfitColor: color));
                }, custom.outfitColor),
                const SizedBox(height: 20),

                // Outfit Accent Color
                _buildSectionTitle('OUTFIT ACCENT'),
                const SizedBox(height: 8),
                _buildColorGrid(CharacterCustomizeEditor.accentColors, (color) {
                  onChanged(
                    custom.copyWith(
                      outfitAccentColor: color,
                      outfitSecondaryColor:
                          Color.lerp(color, Colors.black, 0.4)!,
                    ),
                  );
                }, custom.outfitAccentColor),
                const SizedBox(height: 20),

                // Outfit Style
                _buildSectionTitle('OUTFIT STYLE'),
                const SizedBox(height: 8),
                _buildOutfitStyleGrid(),
                const SizedBox(height: 20),

                // Accessory
                _buildSectionTitle('ACCESSORY'),
                const SizedBox(height: 8),
                _buildAccessoryGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF161616),
            custom.outfitAccentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text(
            'PREVIEW',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: Center(
              child: AnimatedBuilder(
                animation: _idleController,
                builder: (context, _) {
                  return FittedBox(
                    child: SizedBox(
                      width: 90,
                      height: 132,
                      child: CustomPaint(
                        painter: HeroPainter(
                          accentColor: custom.outfitAccentColor,
                          idleProgress: _idleController.value,
                          customization: custom,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${custom.hairStyle.label} / ${custom.outfitStyle.label}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildColorGrid(
    List<Color> colors,
    ValueChanged<Color> onSelected,
    Color currentColor,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color.toARGB32() == currentColor.toARGB32();
        return GestureDetector(
          onTap: () => onSelected(color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Center(
                    child: Icon(Icons.check, size: 16, color: Colors.white),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHairStyleGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HairStyle.values.map((style) {
        final isSelected = style == custom.hairStyle;
        return GestureDetector(
          onTap: () => onChanged(custom.copyWith(hairStyle: style)),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? custom.hairColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? custom.hairColor
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(style.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  style.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOutfitStyleGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OutfitStyle.values.map((style) {
        final isSelected = style == custom.outfitStyle;
        return GestureDetector(
          onTap: () => onChanged(custom.copyWith(outfitStyle: style)),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? custom.outfitAccentColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? custom.outfitAccentColor
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(style.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  style.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Accessory.values.map((acc) {
        final isSelected = acc == custom.accessory;
        return GestureDetector(
          onTap: () => onChanged(custom.copyWith(accessory: acc)),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? custom.outfitAccentColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? custom.outfitAccentColor
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(acc.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  acc.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
