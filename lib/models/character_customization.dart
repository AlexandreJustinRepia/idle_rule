import 'package:flutter/material.dart';

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
