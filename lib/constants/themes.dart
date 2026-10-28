import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // LIGHT MODE COLORS
  // =========================

  static const lightPrimary = Color(0xFF5056A4);
  static const lightSecondary = Color(0xFFAF98F1);
  static const lightContrast = Color(0xFFF5DC63);
  static const lightBackground = Color(0xFFFEFEFE);
  static const lightPopBackground = Color(0xFFF2F2F7);
  static const lightText = Color(0xFF252525);

  // =========================
  // DARK MODE COLORS
  // =========================

  static const darkPrimary = Color(0xFF5056A4);
  static const darkSecondary = Color(0xFFAF98F1);
  static const darkContrast = Color(0xFFF5DC63);
  static const darkBackground = Color(0xFF010101);
  static const darkPopBackground = Color(0xFF1C1C1C);
  static const darkText = Color(0xFFFFFFFF);

  // =========================
  // LIGHT THEME
  // =========================

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      tertiary: lightContrast,
      surface: lightBackground,
      surfaceContainer: lightPopBackground,
      onSurface: lightText,
      onPrimary: Colors.white,
      onSecondary: lightText,
      onSurfaceVariant: Color(0xFF676779),
    ),

    scaffoldBackgroundColor: lightBackground,

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: lightText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: lightText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: lightText, height: 1.45),
      bodyMedium: TextStyle(color: lightText, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: lightPopBackground.withValues(alpha: 0.72),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimary,
        side: BorderSide(color: lightPrimary.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // =========================
  // DARK THEME
  // =========================

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      tertiary: darkContrast,
      surface: darkPopBackground,
      surfaceContainer: darkBackground,
      onSurface: darkText,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurfaceVariant: Color(0xFFB9B7C8),
    ),

    scaffoldBackgroundColor: darkBackground,

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: darkText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: darkText,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkText, height: 1.45),
      bodyMedium: TextStyle(color: darkText, height: 1.4),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: darkPopBackground.withValues(alpha: 0.84),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkSecondary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkSecondary,
        side: BorderSide(color: darkSecondary.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
