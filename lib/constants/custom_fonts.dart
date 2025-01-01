import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFonts {
  // Title Font
  static TextStyle titleFont({
    double fontSize = 24,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Subtitle Font
  static TextStyle subtitleFont({
    double fontSize = 18,
    Color color = Colors.black87,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Body Font
  static TextStyle bodyFont({
    double fontSize = 16,
    Color color = Colors.black54,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.openSans(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Button Font
  static TextStyle buttonFont({
    double fontSize = 16,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.lato(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
