import 'package:flutter/material.dart';

class AppTheme {
  // Google Stitch Design Tokens (Ainara Design System)
  static const Color primaryBlue = Color(0xFF3490F9);
  static const Color secondaryTangerine = Color(0xFFF7A81E);
  static const Color canvasBackground = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFF1F5F9);
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color borderBlueActive = Color(0xFF2563EB);
  static const Color borderAmber = Color(0xFFFDE68A);

  // Typography Palette (Slate Tiers)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Functional Semantics
  static const Color success = Color(0xFF10B981);
  static const Color destructive = Color(0xFFEF4444);
  static const Color amberSurface = Color(0xFFFEF6E8);
  static const Color amberText = Color(0xFF92400E);
  static const Color stepperInactive = Color(0xFFCBD5E1);

  // Backward-Compatible Aliases (Upgrades legacy green to Stitch Digital Blue & Tangerine)
  static const Color primaryGreen = primaryBlue;
  static const Color primaryLightGreen = secondaryTangerine;
  static const Color accentGreen = Color(0xFFEFF6FF); // Soft blue tint container
  static const Color backgroundLight = canvasBackground;
  static const Color textDark = textPrimary;
  static const Color cardBorder = borderDefault;
  static const Color canvasColor = canvasBackground;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      secondary: secondaryTangerine,
      surface: canvasBackground,
      error: destructive,
    ),
    scaffoldBackgroundColor: canvasBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: borderDefault, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        elevation: 0,
        side: const BorderSide(color: borderDefault, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDefault, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDefault, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: destructive, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderDefault,
      thickness: 1,
      space: 1,
    ),
  );
}
