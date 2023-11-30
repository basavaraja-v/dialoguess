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
            color: Colors.orangeAccent, // Base color for neumorphism
            elevation: 5.0,
            curve: VxCurve.flat // Flat design
            )
        .linearGradient([Colors.orangeAccent, Colors.purpleAccent])
        .shadow2xl // Apply a large shadow
        .width(150) // Specify the width of the button
        .height(60) // Specify the height of the button
        .make() // Make the VxBox
        .onInkTap(onPressed); // Apply the tap callback
  }
}
