import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens approximating the original app's oklch() design tokens
/// (dark "editorial" theme: near-black ink background, warm amber accent,
/// warm off-white text). Converted by eye from oklch -> sRGB hex; tweak
/// these if you want pixel-exact matches to the web build.
class AppColors {
  static const background = Color(0xFF17171D);
  static const foreground = Color(0xFFF5F1EA);
  static const card = Color(0xFF201F27);
  static const cardForeground = Color(0xFFF5F1EA);
  static const primary = Color(0xFFDFA85A); // amber accent
  static const primaryForeground = Color(0xFF2B1F14);
  static const secondary = Color(0xFF2A2932);
  static const secondaryForeground = Color(0xFFEFEBE3);
  static const muted = Color(0xFF26252D);
  static const mutedForeground = Color(0xFFB7AE9C);
  static const accent = Color(0xFF2A3A3B);
  static const accentForeground = Color(0xFFF5F1EA);
  static const destructive = Color(0xFFD8654A);
  static const destructiveForeground = Color(0xFFF7F3EC);
  static const border = Color(0xFF302F38);
  static const success = Color(0xFF6FAE7B);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
      ),
    );

    final displayFont = GoogleFonts.frauncesTextTheme(base.textTheme);
    final bodyFont = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: bodyFont.copyWith(
        headlineLarge: displayFont.headlineLarge?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
        headlineMedium: displayFont.headlineMedium?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
        headlineSmall: displayFont.headlineSmall?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
        titleLarge: displayFont.titleLarge?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
        titleMedium: bodyFont.titleMedium?.copyWith(color: AppColors.foreground),
        bodyLarge: bodyFont.bodyLarge?.copyWith(color: AppColors.foreground),
        bodyMedium: bodyFont.bodyMedium?.copyWith(color: AppColors.foreground),
        bodySmall: bodyFont.bodySmall?.copyWith(color: AppColors.mutedForeground),
        labelLarge: bodyFont.labelLarge?.copyWith(color: AppColors.foreground),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.foreground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: bodyFont.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.mutedForeground),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.muted,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.foreground),
        secondaryLabelStyle: const TextStyle(color: AppColors.primaryForeground),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
