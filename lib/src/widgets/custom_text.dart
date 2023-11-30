import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      child: Text(
        text,
        style: GoogleFonts.pressStart2p(
          fontSize: fontSize,
          color: Colors
              .white, // This color must be white for the ShaderMask to work
        ),
      ),
    );
  }
}
