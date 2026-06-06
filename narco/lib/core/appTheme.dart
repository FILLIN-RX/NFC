import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Couleurs Narco Premium
  static const Color primary = Color(0xFFF5D161);
  static const Color background = Color(0xFFF7F5F0);
  static const Color dark = Color(0xFF1A1A1A);
  static const Color tertiary = Color(0xFF1A1A1A); // Identique à dark pour la cohérence
  static const Color cardColor = Colors.white;
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF59E0B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: dark,
      tertiary: tertiary,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
    ),
  );
}
