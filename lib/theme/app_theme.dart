// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF4F46E5);
  static const Color primary2 = Color(0xFF7C3AED);
  static const Color green = Color(0xFF16A34A);
  static const Color red = Color(0xFFDC2626);
  static const Color orange = Color(0xFFF97316);
  static const Color yellow = Color(0xFFD97706);
  static const Color greenLight = Color(0xFFDCFCE7);
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color yellowLight = Color(0xFFFEF3C7);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F8FB),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      titleTextStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: const Color(0xFF111111),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F14),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A1A24),
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A2A38)),
      ),
    ),
  );
}
