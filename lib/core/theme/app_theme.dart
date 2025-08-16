import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Updated colors to match the design
  static const Color primaryColor = Color(0xFF20B2AA); // Teal color from design
  static const Color secondaryColor = Color(0xFF48C9B0);
  static const Color accentColor = Color(0xFF1ABC9C);
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light background
  static const Color surfaceColor = Color(0xFFE8F4F8); // Light blue surface
  static const Color textPrimaryColor = Color(0xFF2C3E50); // Dark gray text
  static const Color textSecondaryColor = Color(0xFF7F8C8D); // Light gray text
  static const Color buttonColor = Color(0xFF34495E); // Dark gray button
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
            displayLarge: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
            displayMedium: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
            displaySmall: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              color: textPrimaryColor,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: const BorderSide(color: buttonColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(
          color: textSecondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
