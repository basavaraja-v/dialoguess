import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("assets/images/back.png"),
          onPressed: () {
            AudioManager.playSFX('click.mp3');
            Navigator.of(context).pop();
          },
        ),
        title: Text('Settings',
            style: GoogleFonts.bitter(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.blueGrey[800],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.white),
              title: Text('Music',
                  style: GoogleFonts.bitter(fontSize: 18, color: Colors.white)),
              trailing: IconButton(
                icon: Icon(
                  _musicEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _musicEnabled = !_musicEnabled;
                    AudioManager.setMusicEnabled(_musicEnabled);
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.audio_file, color: Colors.white),
              title: Text('Sound FX',
                  style: GoogleFonts.bitter(fontSize: 18, color: Colors.white)),
              trailing: IconButton(
                icon: Icon(
                  _sfxEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _sfxEnabled = !_sfxEnabled;
                    AudioManager.setSFXEnabled(_sfxEnabled);
                  });
                },
              ),
            ),
            // Additional settings options...
          ],
        ),
      ),
    );
  }
}
