import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified palette — keep distinct hues to a minimum.
///
/// Brand:    primary (purple) + accent (teal)
/// States:   success (green) / danger (red) — reserved for semantic signals
/// Badges:   vetBadge (blue) — external convention for "verified"
/// Legacy aliases (secondary / warning / brandBadge) all collapse into
/// brand-family so the UI reads as one coherent system.
class AppColors {
  static const Color primary = Color(0xFF6C4AB6);
  static const Color primarySoft = Color(0xFFEDE7FA);
  static const Color accent = Color(0xFF34C9B7);
  static const Color background = Color(0xFFFAF8FE);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1330);
  static const Color textSecondary = Color(0xFF6B6480);
  static const Color border = Color(0xFFEAE5F5);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color vetBadge = Color(0xFF2563EB);

  // Legacy aliases — kept for code compatibility, consolidated visually.
  static const Color secondary = accent;
  static const Color warning = primary;
  static const Color brandBadge = accent;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: textTheme.copyWith(
      headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primarySoft,
      labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      space: 1,
      thickness: 1,
    ),
  );
}
