import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  CustomPlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return "Play"
        .text
        .textStyle(GoogleFonts.pressStart2p(fontSize: 25, color: Colors.white))
        .make()
        .box
        .alignCenter
        .withRounded(value: 50) // Rounded corners
        .neumorphic(
            color: Colors.blueGrey[900], // Updated color for better integration
            elevation: 5.0,
            curve: VxCurve.flat // Flat design
            )
        .width(MediaQuery.of(context).size.width * 0.5) // Responsive width
        .height(60) // Fixed height
        .make() // Make the VxBox
        .onInkTap(onPressed); // Apply the tap callback
  }
}
