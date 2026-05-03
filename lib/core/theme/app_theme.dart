import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Design system colors from design.md
  static const primary = Color(0xFF0891B2);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF22D3EE);
  static const accent = Color(0xFF059669);
  static const background = Color(0xFFECFEFF);
  static const foreground = Color(0xFF164E63);
  static const muted = Color(0xFFE8F1F6);
  static const border = Color(0xFFA5F3FC);
  static const destructive = Color(0xFFDC2626);
  static const ring = Color(0xFF0891B2);

  // Dark theme colors
  static const darkPrimary = Color(0xFF22D3EE);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkSecondary = Color(0xFF0891B2);
  static const darkAccent = Color(0xFF34D399);
  static const darkBackground = Color(0xFF0F172A);
  static const darkForeground = Color(0xFFECFEFF);
  static const darkMuted = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkDestructive = Color(0xFFEF4444);
  static const darkRing = Color(0xFF22D3EE);

  static TextTheme _buildTextTheme(TextTheme base, {bool isDark = false}) {
    final color = isDark ? darkForeground : foreground;
    return base.copyWith(
      displayLarge: GoogleFonts.calistoga(
        fontSize: 57,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.05 * 57,
        color: color,
      ),
      displayMedium: GoogleFonts.calistoga(
        fontSize: 45,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.05 * 45,
        color: color,
      ),
      displaySmall: GoogleFonts.calistoga(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.05 * 36,
        color: color,
      ),
      headlineLarge: GoogleFonts.calistoga(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.calistoga(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineSmall: GoogleFonts.calistoga(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      surface: Colors.white,
      background: background,
      error: destructive,
      onBackground: foreground,
      onSurface: foreground,
    ),
    scaffoldBackgroundColor: background,
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.calistoga(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    dividerColor: border,
    iconTheme: const IconThemeData(color: foreground),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      secondary: darkSecondary,
      surface: darkMuted,
      background: darkBackground,
      error: darkDestructive,
      onBackground: darkForeground,
      onSurface: darkForeground,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, isDark: true),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkForeground,
      elevation: 0,
      titleTextStyle: GoogleFonts.calistoga(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkForeground,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      filled: true,
      fillColor: darkMuted,
    ),
    cardTheme: CardTheme(
      color: darkMuted,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    dividerColor: darkBorder,
    iconTheme: const IconThemeData(color: darkForeground),
  );
}
