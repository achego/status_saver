import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFC67C4E),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: Colors.black87,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: Colors.black54,
        fontSize: 14,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static final ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    primaryColor: Color(0xFFC67C4E),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: Colors.white54,
        fontSize: 14,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
