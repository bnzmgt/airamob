import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Google Stitch Design Tokens (Ainara Design System - Disciplined Safeguard)
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
  static const Color errorRed = destructive;

  // =========================================================================
  // Disciplined Safeguard Typography Tokens (Stitch Design System)
  // =========================================================================

  // 1. Headline Family: Metrophobic (Clean geometric sans for headlines & anchors)
  static TextStyle headlineHero({Color color = textPrimary}) => GoogleFonts.metrophobic(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.48,
    height: 32 / 24,
  );

  static TextStyle headingLg({Color color = textPrimary}) => GoogleFonts.metrophobic(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.27,
    height: 24 / 18,
  );

  static TextStyle headingMd({Color color = textPrimary}) => GoogleFonts.metrophobic(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: -0.16,
    height: 22 / 16,
  );

  static TextStyle headingSm({Color color = textPrimary}) => GoogleFonts.metrophobic(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color,
    height: 20 / 15,
  );

  // 2. Body Family: Chivo (High-contrast, high-legibility grotesque sans for reporting & content)
  static TextStyle bodyLg({Color color = textPrimary, FontWeight fontWeight = FontWeight.w500}) => GoogleFonts.chivo(
    fontSize: 14,
    fontWeight: fontWeight,
    color: color,
    height: 20 / 14,
  );

  static TextStyle bodyMd({Color color = textSecondary, FontWeight fontWeight = FontWeight.w400}) => GoogleFonts.chivo(
    fontSize: 13,
    fontWeight: fontWeight,
    color: color,
    height: 18 / 13,
  );

  static TextStyle bodySm({Color color = textMuted, FontWeight fontWeight = FontWeight.w400}) => GoogleFonts.chivo(
    fontSize: 12,
    fontWeight: fontWeight,
    color: color,
    height: 16 / 12,
  );

  static TextStyle codeTicket({Color color = primaryBlue}) => GoogleFonts.chivo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.65,
    height: 16 / 13,
  );

  // 3. Label Family: Plus Jakarta Sans (Crisp modern sans specifically for actions, buttons & status chips)
  static TextStyle labelBtn({Color color = Colors.white, FontWeight fontWeight = FontWeight.w700}) => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 0.14,
    height: 18 / 14,
  );

  static TextStyle labelBadge({Color color = primaryBlue, FontWeight fontWeight = FontWeight.w600}) => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 0.22,
    height: 14 / 11,
  );

  // =========================================================================
  // Global Light Theme
  // =========================================================================
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
    textTheme: GoogleFonts.chivoTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.metrophobic(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: GoogleFonts.metrophobic(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: GoogleFonts.metrophobic(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      headlineLarge: GoogleFonts.metrophobic(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.48),
      headlineMedium: GoogleFonts.metrophobic(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.3),
      headlineSmall: GoogleFonts.metrophobic(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.27),
      titleLarge: GoogleFonts.metrophobic(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
      titleMedium: GoogleFonts.metrophobic(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: GoogleFonts.metrophobic(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.chivo(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      bodyMedium: GoogleFonts.chivo(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
      bodySmall: GoogleFonts.chivo(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
      labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.14),
      labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.14),
      labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.22),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.metrophobic(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.27,
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
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.14,
        ),
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
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.chivo(color: textMuted, fontSize: 13),
      labelStyle: GoogleFonts.chivo(color: textSecondary, fontSize: 13),
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
