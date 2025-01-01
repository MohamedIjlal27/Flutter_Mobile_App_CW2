import 'package:flutter/material.dart';

class ThemeColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1976D2); // Blue shade
  static const Color secondaryColor = Color(0xFF7B1FA2); // Purple shade

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      secondaryColor,
    ],
  );

  // Background Colors
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color lightText = Colors.white;

  // Form Colors
  static const Color formFieldBorder = Color(0xFFBDBDBD);
  static const Color formFieldBackground = Colors.white;

  // Button Colors
  static const Color buttonPrimary = primaryColor;
  static const Color buttonText = Colors.white;

  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Shadow Colors
  static Color shadowColor = Colors.black.withOpacity(0.1);

  // Overlay Colors
  static Color overlayLight = Colors.white.withOpacity(0.95);
}
