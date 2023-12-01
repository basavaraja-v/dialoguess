import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HStack([
      Icon(icon, color: Colors.white).box.make(),
      10.widthBox, // Space between icon and text
      text.text
          .textStyle(
              GoogleFonts.pressStart2p(fontSize: 20, color: Colors.white))
          .make(),
    ])
        .box
        .alignCenter
        .withRounded(value: 10) // Rounded corners
        .neumorphic(
            color: Colors.blueGrey[900], // Updated color for better integration
            elevation: 5.0,
            curve: VxCurve.flat // Flat design
            )
        .width(MediaQuery.of(context).size.width * 0.8) // Responsive width
        .height(60) // Fixed height
        .make() // Make the VxBox
        .onInkTap(onPressed); // Apply the tap callback
  }
}
