import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final double fontSize;

  const GradientText({
    required this.text,
    required this.gradient,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: text.text
          .textStyle(GoogleFonts.pressStart2p(
              fontSize: fontSize)) // Apply the font size from the parameter
          .center // Center align text
          .make(), // Make the text widget
    );
  }
}
