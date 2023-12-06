import 'package:dialoguess/src/controllers/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isLoading = true;

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
        title: Text('Privacy Policy',
            style: GoogleFonts.bitter(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true, // Adjust the color to match your theme
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    'https://heyidb.com/dialoguessprivacypolicy.txt')),
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(), // Hide progress indicator when done loading
        ],
      ),
    );
  }
}
