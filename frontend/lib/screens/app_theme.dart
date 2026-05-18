import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors — dark neon-on-void Gen-Z palette
  static const Color primaryGreen = Color(0xFF00F5A0);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentBlue = Color(0xFF4ECDC4);

  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF13131A);
  static const Color bgCardElevated = Color(0xFF1C1C28);
  static const Color borderColor = Color(0xFF2A2A38);

  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF44445A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryPurple,
        tertiary: accentCoral,
        surface: bgCard,
        background: bgDark,
        onPrimary: bgDark,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        outline: borderColor,
        surfaceVariant: bgCardElevated,
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.5),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: bgDark, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: bgDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentCoral),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardElevated,
        selectedColor: primaryGreen.withOpacity(0.2),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: bgDark,
        elevation: 0,
        shape: CircleBorder(),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme; // App is dark-first
}