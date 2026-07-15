import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Defines all visual customization options for the player's hero doll.
class CharacterCustomization {
  final Color skinColor;
  final Color skinColorDark;
  final Color hairColor;
  final Color outfitColor;
  final Color outfitAccentColor;
  final Color outfitSecondaryColor;
  final HairStyle hairStyle;
  final OutfitStyle outfitStyle;
  final Accessory accessory;

  const CharacterCustomization({
    this.skinColor = const Color(0xFFE8D5C0),
    this.skinColorDark = const Color(0xFFD4C0B0),
    this.hairColor = Colors.blueAccent,
    this.outfitColor = const Color(0xFF1E3A5F),
    this.outfitAccentColor = Colors.blueAccent,
    this.outfitSecondaryColor = const Color(0xFF162D4A),
    this.hairStyle = HairStyle.spiky,
    this.outfitStyle = OutfitStyle.jacket,
    this.accessory = Accessory.none,
  });

  CharacterCustomization copyWith({
    Color? skinColor,
    Color? skinColorDark,
    Color? hairColor,
    Color? outfitColor,
    Color? outfitAccentColor,
    Color? outfitSecondaryColor,
    HairStyle? hairStyle,
    OutfitStyle? outfitStyle,
    Accessory? accessory,
  }) {
    return CharacterCustomization(
      skinColor: skinColor ?? this.skinColor,
      skinColorDark: skinColorDark ?? this.skinColorDark,
      hairColor: hairColor ?? this.hairColor,
      outfitColor: outfitColor ?? this.outfitColor,
      outfitAccentColor: outfitAccentColor ?? this.outfitAccentColor,
      outfitSecondaryColor: outfitSecondaryColor ?? this.outfitSecondaryColor,
      hairStyle: hairStyle ?? this.hairStyle,
      outfitStyle: outfitStyle ?? this.outfitStyle,
      accessory: accessory ?? this.accessory,
    );
  }
}

enum HairStyle { spiky, flat, long, mohawk, afro, slicked }

enum OutfitStyle { jacket, tankTop, hoodie, suit, casual }

enum Accessory { none, glasses, bandana, chain, hat, eyepatch }

/// Helper to get display names and preview details
extension HairStyleHelper on HairStyle {
  String get label {
    switch (this) {
      case HairStyle.spiky:
        return 'Spiky';
      case HairStyle.flat:
        return 'Flat';
      case HairStyle.long:
        return 'Long';
      case HairStyle.mohawk:
        return 'Mohawk';
      case HairStyle.afro:
        return 'Afro';
      case HairStyle.slicked:
        return 'Slicked';
    }
  }

  String get emoji {
    switch (this) {
      case HairStyle.spiky:
        return '⚡';
      case HairStyle.flat:
        return '➖';
      case HairStyle.long:
        return '🌊';
      case HairStyle.mohawk:
        return '🦜';
      case HairStyle.afro:
        return '☁️';
      case HairStyle.slicked:
        return '✨';
    }
  }
}

extension OutfitStyleHelper on OutfitStyle {
  String get label {
    switch (this) {
      case OutfitStyle.jacket:
        return 'Jacket';
      case OutfitStyle.tankTop:
        return 'Tank Top';
      case OutfitStyle.hoodie:
        return 'Hoodie';
      case OutfitStyle.suit:
        return 'Suit';
      case OutfitStyle.casual:
        return 'Casual';
    }
  }

  String get emoji {
    switch (this) {
      case OutfitStyle.jacket:
        return '🧥';
      case OutfitStyle.tankTop:
        return '👕';
      case OutfitStyle.hoodie:
        return '👔';
      case OutfitStyle.suit:
        return '🤵';
      case OutfitStyle.casual:
        return '👚';
    }
  }
}

extension AccessoryHelper on Accessory {
  String get label {
    switch (this) {
      case Accessory.none:
        return 'None';
      case Accessory.glasses:
        return 'Glasses';
      case Accessory.bandana:
        return 'Bandana';
      case Accessory.chain:
        return 'Chain';
      case Accessory.hat:
        return 'Hat';
      case Accessory.eyepatch:
        return 'Eyepatch';
    }
  }

  String get emoji {
    switch (this) {
      case Accessory.none:
        return '❌';
      case Accessory.glasses:
        return '👓';
      case Accessory.bandana:
        return '🟥';
      case Accessory.chain:
        return '⛓️';
      case Accessory.hat:
        return '🧢';
      case Accessory.eyepatch:
        return '🎭';
    }
  }
}

/// Palettes shared by the generator and the customization editor.
class CustomizationPalettes {
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
}

/// Deterministic generator that produces many visually distinct NPC looks.
///
/// The same [seed] always yields the same appearance, so an NPC keeps its look
/// across rebuilds. Pass [palette] (e.g. a rival gang color) to bias the
/// outfit/accent toward a faction's theme while keeping variety in the rest.
CharacterCustomization generateNpcCustomization(
  int seed, {
  Color? palette,
}) {
  final random = math.Random(seed);

  T pick<T>(List<T> list) => list[random.nextInt(list.length)];

  final skinColor = pick(CustomizationPalettes.skinTones);
  final skinColorDark = Color.lerp(skinColor, Colors.brown, 0.3)!;
  final hairColor = pick(CustomizationPalettes.hairColors);

  final hairStyle = pick(HairStyle.values);
  final outfitStyle = pick(OutfitStyle.values);
  final accessory = pick(Accessory.values);

  Color outfit;
  Color accent;
  if (palette != null && random.nextDouble() < 0.7) {
    outfit = palette;
    accent = pick(CustomizationPalettes.accentColors);
  } else {
    outfit = pick(CustomizationPalettes.outfitColors);
    accent = pick(CustomizationPalettes.accentColors);
  }

  return CharacterCustomization(
    skinColor: skinColor,
    skinColorDark: skinColorDark,
    hairColor: hairColor,
    outfitColor: outfit,
    outfitAccentColor: accent,
    outfitSecondaryColor: Color.lerp(accent, Colors.black, 0.4)!,
    hairStyle: hairStyle,
    outfitStyle: outfitStyle,
    accessory: accessory,
  );
}
