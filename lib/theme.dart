import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // HSL-based colors as constants (converted to hex)
  static const primary = Color(0xFF3B82F6); // #3B82F6
  static const accent = Color(0xFFF59E0B); // #F59E0B
  static const background = Color(0xFFF8FAFC); // #F8FAFC
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const destructive = Color(0xFFEF4444);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient warmGradient = const LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData themeData() => ThemeData(
        useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: accent),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.black87),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0, centerTitle: true),
  cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4, color: Colors.white.withAlpha((0.9 * 255).round())),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0)),
      );
}
