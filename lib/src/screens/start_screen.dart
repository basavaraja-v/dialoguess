import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/audio_manager.dart';
import '../services/dialogue_service.dart';
import 'play_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_button.dart';
import 'package:share_plus/share_plus.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final DialogueService _dialogueService = DialogueService();
  late Future<int> _currentLevelFuture;
  late Future<int> _rewardPointsFuture;

  @override
  void initState() {
    super.initState();
    _currentLevelFuture = _dialogueService.getCurrentLevel();
    _rewardPointsFuture = _dialogueService.getRewardPoints();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background image here
    precacheImage(const AssetImage('assets/images/background.png'), context);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _currentLevelFuture,
      _rewardPointsFuture,
    ]);
  }

  void _updateData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the widget tree
        setState(() {
          _currentLevelFuture = _dialogueService.getCurrentLevel();
          _rewardPointsFuture = _dialogueService.getRewardPoints();
        });
      }
    });
  }

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
                  // const SizedBox(height: 420),
                  FutureBuilder<int>(
                    future: _currentLevelFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(
                              8), // Add some padding inside the container
                          decoration: BoxDecoration(
                            color:
                                Colors.green[800], // Setting background color
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Text(
                            'Level: ${snapshot.data! - 1}',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 16, color: Colors.white),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder<int>(
                    future: _rewardPointsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(
                              8), // Add some padding inside the container
                          decoration: BoxDecoration(
                            color:
                                Colors.green[800], // Setting background color
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Text(
                            'Highest Score: ${snapshot.data}',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 16, color: Colors.white),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  // const SizedBox(height: 420),
                  const SizedBox(height: 10),
                  CustomIconButton(
                    icon: Icons.play_arrow,
                    text: 'Play',
                    onPressed: () {
                      AudioManager.playSFX('click.mp3');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PlayScreen(onUpdate: _updateData),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
