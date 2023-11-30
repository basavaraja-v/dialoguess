import 'package:flutter/material.dart';
import 'play_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_button.dart'; // Import the custom button

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/background.png'), // Replace with your background image asset
            fit: BoxFit.cover, // This will fill the background with the image
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 10),
              // Custom Play Button
              CustomPlayButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PlayScreen()),
                  );
                },
              ),
              Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
