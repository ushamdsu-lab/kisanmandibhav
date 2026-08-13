import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Theme Colors
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF1B5E20);
  static const secondary = Color(0xFFFF8F00);
  static const secondaryLight = Color(0xFFFFB74D);
  static const background = Color(0xFFF5F7F0);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const divider = Color(0xFFE0E0E0);

  // Module Accent Colors
  static const mandiAccent = Color(0xFFE65100);
  static const mandiAccentLight = Color(0xFFFFF3E0);
  static const mausamAccent = Color(0xFF0277BD);
  static const mausamAccentLight = Color(0xFFE1F5FE);
  static const khetiAccent = Color(0xFF2E7D32);
  static const khetiAccentLight = Color(0xFFE8F5E9);
  static const yojnaAccent = Color(0xFF6A1B9A);
  static const yojnaAccentLight = Color(0xFFF3E5F5);

  // Dark Theme Colors
  static const primaryDarkTheme = Color(0xFF66BB6A);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2A2A2A);
  static const textPrimaryDark = Color(0xFFF5F5F5);
  static const textSecondaryDark = Color(0xFFAAAAAA);

  // Gradients
  static const mandiGradient = [Color(0xFFE65100), Color(0xFFFF8F00)];
  static const mausamGradient = [Color(0xFF0277BD), Color(0xFF29B6F6)];
  static const khetiGradient = [Color(0xFF2E7D32), Color(0xFF66BB6A)];
  static const yojnaGradient = [Color(0xFF6A1B9A), Color(0xFFAB47BC)];
  static const dashboardGradient = [Color(0xFF1B5E20), Color(0xFF4CAF50)];

  // Trend Colors
  static const priceUp = Color(0xFF4CAF50);
  static const priceDown = Color(0xFFE53935);
  static const priceStable = Color(0xFFFF9800);

  // Weather Alert Colors
  static const alertYellow = Color(0xFFFFC107);
  static const alertOrange = Color(0xFFFF9800);
  static const alertRed = Color(0xFFE53935);
}

class AppTheme {
  static TextStyle _hindiStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle _englishStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // --- Light Theme ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _hindiStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.khetiAccentLight,
      labelStyle: _hindiStyle(fontSize: 13, color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: _hindiStyle(color: AppColors.textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: _hindiStyle(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: _hindiStyle(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: _hindiStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: _hindiStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: _hindiStyle(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: _hindiStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: _hindiStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      labelLarge: _englishStyle(fontSize: 16, fontWeight: FontWeight.w600),
      labelMedium: _englishStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: _englishStyle(fontSize: 12, fontWeight: FontWeight.w400),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
  );

  // --- Dark Theme ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDarkTheme,
      onPrimary: Colors.black,
      secondary: AppColors.secondaryLight,
      onSecondary: Colors.black,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _hindiStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryDarkTheme,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardDark,
      labelStyle: _hindiStyle(fontSize: 13, color: AppColors.primaryDarkTheme),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDarkTheme, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: _hindiStyle(color: AppColors.textSecondaryDark, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDarkTheme,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: _hindiStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
      headlineMedium: _hindiStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      headlineSmall: _hindiStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      titleLarge: _hindiStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      titleMedium: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
      titleSmall: _hindiStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
      bodyLarge: _hindiStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark),
      bodyMedium: _hindiStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark),
      bodySmall: _hindiStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondaryDark),
      labelLarge: _englishStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      labelMedium: _englishStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
      labelSmall: _englishStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondaryDark),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
      space: 0,
    ),
  );
}
