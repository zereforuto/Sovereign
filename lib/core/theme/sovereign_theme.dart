import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sovereign/core/theme/colors.dart';

/// Sovereign application theme definitions.
abstract final class SovereignTheme {
  static const double radiusVal = 2.0;
  static const double dialogRadiusVal = 8.0;

  static TextTheme _buildTextTheme(Color textColor) {
    final base = GoogleFonts.barlowTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleMedium: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      titleSmall: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      bodyLarge: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
      labelMedium: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.barlow(
        color: textColor,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: SovereignColors.rossoCorsa,
      onPrimary: SovereignColors.white,
      primaryContainer: SovereignColors.rossoPressed,
      onPrimaryContainer: SovereignColors.white,
      secondary: SovereignColors.racingYellow,
      onSecondary: SovereignColors.black,
      surface: SovereignColors.surfaceDark,
      onSurface: SovereignColors.white,
      error: SovereignColors.warning,
      onError: SovereignColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SovereignColors.black,
      textTheme: _buildTextTheme(SovereignColors.white),
      cardTheme: const CardThemeData(
        color: SovereignColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusVal)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SovereignColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(dialogRadiusVal)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SovereignColors.rossoCorsa,
          foregroundColor: SovereignColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SovereignColors.white,
          side: const BorderSide(color: SovereignColors.grayDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SovereignColors.rossoCorsa,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SovereignColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.grayDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.grayDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.rossoCorsa, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SovereignColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusVal),
        ),
        side: const BorderSide(color: SovereignColors.grayDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SovereignColors.black,
        indicatorColor: SovereignColors.rossoCorsa,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.barlow(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: SovereignColors.white,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: SovereignColors.black,
        indicatorColor: SovereignColors.rossoCorsa,
        selectedLabelTextStyle: GoogleFonts.barlow(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: SovereignColors.white,
        ),
        unselectedLabelTextStyle: GoogleFonts.barlow(
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
          color: SovereignColors.grayMid,
        ),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: SovereignColors.rossoCorsa,
      onPrimary: SovereignColors.white,
      primaryContainer: SovereignColors.rossoPressed,
      onPrimaryContainer: SovereignColors.white,
      secondary: SovereignColors.racingYellow,
      onSecondary: SovereignColors.black,
      surface: SovereignColors.white,
      onSurface: SovereignColors.ink,
      error: SovereignColors.warning,
      onError: SovereignColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SovereignColors.white,
      textTheme: _buildTextTheme(SovereignColors.ink),
      cardTheme: const CardThemeData(
        color: SovereignColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusVal)),
          side: BorderSide(color: SovereignColors.borderLight),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(dialogRadiusVal)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SovereignColors.rossoCorsa,
          foregroundColor: SovereignColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SovereignColors.ink,
          side: const BorderSide(color: SovereignColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SovereignColors.rossoCorsa,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusVal),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SovereignColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusVal),
          borderSide: const BorderSide(color: SovereignColors.rossoCorsa, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusVal),
        ),
        side: const BorderSide(color: SovereignColors.borderLight),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SovereignColors.white,
        indicatorColor: SovereignColors.rossoCorsa,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.barlow(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: SovereignColors.ink,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: SovereignColors.white,
        indicatorColor: SovereignColors.rossoCorsa,
        selectedLabelTextStyle: GoogleFonts.barlow(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: SovereignColors.ink,
        ),
        unselectedLabelTextStyle: GoogleFonts.barlow(
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
          color: SovereignColors.grayDark,
        ),
      ),
    );
  }
}
