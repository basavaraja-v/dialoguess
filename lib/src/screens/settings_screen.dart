import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _volumeLevel = 0.5;
  bool _musicEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueGrey, // Customizing the AppBar color
      ),
      backgroundColor:
          Colors.blue[100], // Light blue background for the settings screen
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Volume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _volumeLevel,
              onChanged: (newVolume) {
                setState(() {
                  _volumeLevel = newVolume;
                });
              },
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Colors.blueGrey,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Music'),
              trailing: Switch(
                value: _musicEnabled,
                onChanged: (newVal) {
                  setState(() {
                    _musicEnabled = newVal;
                  });
                },
                activeColor: Colors.blueGrey,
              ),
            ),
            // Add more settings options here as needed
          ],
        ),
      ),
    );
  }
}
