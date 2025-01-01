import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF0139FE
);
  static const secondaryColor = Color(0xFF03DAC6);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color(0xFF000000);
  static const errorColor = Color(0xFFB00020);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0139FE), // Start color
      Color(0xFF10F1FF), // Middle color
      Color(0xFF0062FF), // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
