import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZalonoTheme {
  // Brand Colors matching Zalono visual identity
  static const Color primaryBurgundy = Color(0xFF80142B);
  static const Color primaryDark = Color(0xFF4A0E1A);
  static const Color primaryLight = Color(0xFFF9E8EC);
  
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentGreenLight = Color(0xFFDCFCE7);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color accentRed = Color(0xFFDC2626);
  static const Color accentRedLight = Color(0xFFFEE2E2);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBurgundy,
        primary: primaryBurgundy,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        iconTheme: IconThemeData(color: textDark),
      ),
    );
  }
}
