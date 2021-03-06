import 'package:flutter/material.dart';

/// colors used in app
class IdomColors {
  /// light mode
  static const Color mainBackgroundLight = Color(0xFFFFFFFF);
  static const Color blackTextLight = Color(0xFF0E1111);
  static const Color brighterBlackTextLight = Color(0xFF202022);
  static const Color whiteTextLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color buttonSplashColorLight = Color(0xFFE5E5E5);

  /// dark mode
  static const Color mainBackgroundDark = Color(0xFF202022);
  static const Color blackTextDark = Color(0xFFFFFFFF);
  static const Color brighterBlackTextDark = Color(0xFFBDBDBD);
  static const Color whiteTextDark = Color(0xFF0E1111);
  static const Color cardDark = Colors.black87;
  static const Color buttonSplashColorDark = Color(0xFF767676);

  /// general
  static const Color mainFill = Color(0xFF0C0C0F);
  static const Color error = Color(0xFF9C1F03);
  static const Color buttonBackground = Color(0xFF0C0C0F);
  static const Color iconLight = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFE5E5E5);
  static const Color iconDark = Color(0xFF0E1111);
  static const Color additionalColor = Color(0xFFDAA520);
  static const Color lightBlack = Color(0xFF3B3736);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF73C76C);
  static const Color darkGreen = Color(0xFF4A9245);
  static const Color brightGreen = Color(0xFFF0F8F0);
  static const Color brightGrey = Color(0xFFA2A2A2);

  /// darken color base on given intensity
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// lighten color base on given intensity
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
