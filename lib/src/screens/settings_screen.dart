import 'package:dialoguess/src/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/audio_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../games_services/games_services.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  String _appVersion = '';
  late GamesServicesController gamesServicesController;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initPackageInfo();
    gamesServicesController = GamesServicesController();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      print('_appVersion: $_appVersion');
    });
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
    });
  }

  void showPrivacyPolicy() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
  }

  void _showLeaderboard() {
    gamesServicesController.showLeaderboard();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  color: Colors.blueGrey[900], // Card color
                  child: ListTile(
                    title: Text('Music',
                        style: GoogleFonts.bitter(
                            fontSize: 18, color: Colors.white)),
                    onTap: () {
                      setState(() {
                        _musicEnabled = !_musicEnabled;
                        AudioManager.setMusicEnabled(_musicEnabled);
                      });
                    },
                    trailing: IconButton(
                      icon: Icon(
                        _musicEnabled
                            ? Icons.music_note_outlined
                            : Icons.music_off_outlined,
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
                ),
                Card(
                    color: Colors.blueGrey[900], // Card color
                    child: ListTile(
                      title: Text('Sound FX',
                          style: GoogleFonts.bitter(
                              fontSize: 18, color: Colors.white)),
                      onTap: () {
                        setState(() {
                          _sfxEnabled = !_sfxEnabled;
                          AudioManager.setSFXEnabled(_sfxEnabled);
                        });
                      },
                      trailing: IconButton(
                          icon: Icon(
                            _sfxEnabled ? Icons.graphic_eq : Icons.volume_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _sfxEnabled = !_sfxEnabled;
                              AudioManager.setSFXEnabled(_sfxEnabled);
                            });
                          }),
                    )),
                Card(
                    color: Colors.blueGrey[900], // Card color
                    child: ListTile(
                      title: Text('Leaderboard',
                          style: GoogleFonts.bitter(
                              fontSize: 18, color: Colors.white)),
                      onTap: _showLeaderboard,
                      trailing: IconButton(
                        icon: Image.asset('assets/images/leaderboard.png'),
                        onPressed: _showLeaderboard,
                      ),
                    )),
                Card(
                    color: Colors.blueGrey[900], // Card color
                    child: ListTile(
                      // leading: Icon(Icons.privacy_tip, color: Colors.white),
                      title: Text('Privacy Policy',
                          style: GoogleFonts.bitter(
                              fontSize: 18, color: Colors.white)),
                      onTap: showPrivacyPolicy,
                      trailing: IconButton(
                        icon: Icon(Icons.privacy_tip, color: Colors.white),
                        onPressed: showPrivacyPolicy,
                      ),
                    ))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Text(
              'Version: $_appVersion',
              style: GoogleFonts.bitter(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
