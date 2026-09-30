import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStylesCons {
  // Customizable text style method
  static TextStyle custom({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: color,
    );
  }
}
