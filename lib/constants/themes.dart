import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // LIGHT MODE COLORS
  // =========================

  static const lightPrimary = Color(0xFF5056A4);
  static const lightSecondary = Color(0xFFAF98F1);
  static const lightContrast = Color(0xFFF5DC63);
  static const lightBackground = Color(0xFFF2F2F7);
  static const lightPopBackground = Color(0xFFFEFEFE);
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

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightBackground,
      surfaceContainer: lightPopBackground,
      onSurface: lightText,
      onPrimary: Colors.white,
      onSecondary: lightText,
    ),

    scaffoldBackgroundColor: lightBackground,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
      titleLarge: TextStyle(color: lightText),
      titleMedium: TextStyle(color: lightText),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
    ),
  );

  // =========================
  // DARK THEME
  // =========================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkPopBackground,
      surfaceContainer: darkBackground,
      onSurface: darkText,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),

    scaffoldBackgroundColor: darkBackground,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
      titleLarge: TextStyle(color: darkText),
      titleMedium: TextStyle(color: darkText),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),
  );
}
