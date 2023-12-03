import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/audio_manager.dart';
import 'play_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_button.dart';
import 'package:share_plus/share_plus.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DIALOGUESS',
          style: GoogleFonts.pressStart2p(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900], // Dark background color
        centerTitle: true, // Center the title
        elevation: 0, // Remove shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10), // Rounded bottom corners
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              String googlePlayLink =
                  "https://play.google.com/store/apps/details?id=com.heyidb.dialoguess";
              // If you have an Apple App Store link, include it here
              String shareMessage =
                  "Check out Dialoguess, an engaging conversational adventure game! Download on Google Play: $googlePlayLink";
              Share.share(shareMessage);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(10)), // Rounded top corners
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              // Aligns the buttons vertically centered
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Use min to fit the content size
                children: [
                  const SizedBox(height: 400), // Spacing between buttons
                  CustomIconButton(
                    icon: Icons.play_arrow,
                    text: 'Play',
                    onPressed: () {
                      AudioManager.playSFX('click.mp3');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const PlayScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
