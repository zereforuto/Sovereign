import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ferrari-inspired color tokens for Sovereign.
abstract final class SovereignColors {
  static const Color rossoCorsa = Color(0xFFDA291C);
  static const Color rossoPressed = Color(0xFFB01E0A);
  static const Color rossoDeep = Color(0xFF9D2211);
  static const Color racingYellow = Color(0xFFFFF200);
  static const Color modenaYellow = Color(0xFFF6E500);
  static const Color black = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF303030);
  static const Color ink = Color(0xFF181818);
  static const Color grayDark = Color(0xFF666666);
  static const Color grayMid = Color(0xFF8F8F8F);
  static const Color graySilver = Color(0xFF969696);
  static const Color borderLight = Color(0xFFD2D2D2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF13A2C);
  static const Color success = Color(0xFF03904A);
  static const Color info = Color(0xFF4C98B9);
}

/// Relative luminance helper conforming to WCAG 2.0.
double relativeLuminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Computes the contrast ratio between two colors according to WCAG 2.0 guidelines.
double contrastRatio(Color a, Color b) {
  final l1 = relativeLuminance(a);
  final l2 = relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}
