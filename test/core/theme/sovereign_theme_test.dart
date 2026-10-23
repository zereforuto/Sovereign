import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SovereignColors', () {
    test('exact color token definitions', () {
      expect(SovereignColors.rossoCorsa, const Color(0xFFDA291C));
      expect(SovereignColors.rossoPressed, const Color(0xFFB01E0A));
      expect(SovereignColors.rossoDeep, const Color(0xFF9D2211));
      expect(SovereignColors.racingYellow, const Color(0xFFFFF200));
      expect(SovereignColors.modenaYellow, const Color(0xFFF6E500));
      expect(SovereignColors.black, const Color(0xFF000000));
      expect(SovereignColors.surfaceDark, const Color(0xFF303030));
      expect(SovereignColors.ink, const Color(0xFF181818));
      expect(SovereignColors.grayDark, const Color(0xFF666666));
      expect(SovereignColors.grayMid, const Color(0xFF8F8F8F));
      expect(SovereignColors.graySilver, const Color(0xFF969696));
      expect(SovereignColors.borderLight, const Color(0xFFD2D2D2));
      expect(SovereignColors.white, const Color(0xFFFFFFFF));
      expect(SovereignColors.warning, const Color(0xFFF13A2C));
      expect(SovereignColors.success, const Color(0xFF03904A));
      expect(SovereignColors.info, const Color(0xFF4C98B9));
    });
  });

  group('contrastRatio', () {
    test('calculates correct contrast', () {
      expect(contrastRatio(SovereignColors.white, SovereignColors.black),
          greaterThan(20.0));
      expect(contrastRatio(SovereignColors.white, SovereignColors.rossoCorsa),
          greaterThanOrEqualTo(3.0));
    });
  });

  group('SovereignTheme', () {
    test('dark theme matches brief specifications', () {
      final dark = SovereignTheme.dark;
      expect(dark.colorScheme.primary, SovereignColors.rossoCorsa);
      expect(dark.scaffoldBackgroundColor, SovereignColors.black);
      expect(dark.cardTheme.elevation, 0);

      // 2px radius for buttons, inputs, chips
      final buttonShape =
          dark.elevatedButtonTheme.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(buttonShape?.borderRadius, BorderRadius.circular(2));

      final chipShape = dark.chipTheme.shape as RoundedRectangleBorder?;
      expect(chipShape?.borderRadius, BorderRadius.circular(2));
    });

    test('light theme matches brief specifications', () {
      final light = SovereignTheme.light;
      expect(light.scaffoldBackgroundColor, SovereignColors.white);
      expect(light.cardTheme.elevation, 0);
    });
  });
}
