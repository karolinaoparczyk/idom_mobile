import 'package:flutter/material.dart';

class IdomColors {
  static const Color mainFill = Color(0xFF0E1111);
  static const Color error = Color(0xFF9C1F03);
  static const Color mainBackground = Color(0xFFFFFFFF);
  static const Color buttonBackground = Color(0xFF0E1111);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color iconLight = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFE5E5E5);
  static const Color textDark = Color(0xFF0E1111);
  static const Color iconDark = Color(0xFF0E1111);
  static const Color additionalColor = Color(0xFFDAA520);
  static const Color lightBlack = Color(0xFF3B3736);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF73C76C);
  static const Color darkGreen = Color(0xFF4A9245);
  static const Color brightGreen = Color(0xFFF0F8F0);

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
