import 'package:flutter/material.dart';

class AppTheme {
  // Goldenwine: Let's use a wine color as primary and gold as secondary
  static const Color wineColor = Color(0xFF722F37);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color whiteColor = Colors.white;

  static ThemeData get theme {
    return ThemeData(
      primaryColor: wineColor,
      scaffoldBackgroundColor: whiteColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: wineColor,
        foregroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: wineColor,
        secondary: goldColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: wineColor,
        foregroundColor: whiteColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: whiteColor,
        selectedItemColor: wineColor,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: whiteColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: wineColor,
          foregroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }
}
