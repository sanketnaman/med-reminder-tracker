import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static bool isDark = false;

  static final _light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF5B8DEF),
    scaffoldBackgroundColor: const Color(0xFFF3F6FF),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color(0xFF5B8DEF),
      primary: const Color(0xFF5B8DEF),
      secondary: const Color(0xFF7BA7F7),
      tertiary: const Color(0xFF20C9D8),
      surface: Colors.white,
      background: const Color(0xFFF3F6FF),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE2E8F0),
  );

  static final _dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF5B8DEF),
    scaffoldBackgroundColor: const Color(0xFF0F1118),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF5B8DEF),
      primary: const Color(0xFF7BA7F7),
      secondary: const Color(0xFF20C9D8),
      tertiary: const Color(0xFF5B8DEF),
      surface: const Color(0xFF1A1D2E),
      background: const Color(0xFF0F1118),
    ),
    cardColor: const Color(0xFF1A1D2E),
    dividerColor: const Color(0xFF2A2D3E),
  );

  static ThemeData get theme => isDark ? _dark : _light;

  // Common colors used across screens
  static Color get bg => isDark ? const Color(0xFF0F1118) : const Color(0xFFF3F6FF);
  static Color get cardBg => isDark ? const Color(0xFF1A1D2E) : Colors.white;
  static Color get textPrimary => isDark ? const Color(0xFFF0F0F0) : const Color(0xFF202733);
  static Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF718096);
  static Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFFA0AEC0);
  static Color get divider => isDark ? const Color(0xFF2A2D3E) : const Color(0xFFE2E8F0);
  static Color get chipBg => isDark ? const Color(0xFF252838) : const Color(0xFFF3F6FF);
}
