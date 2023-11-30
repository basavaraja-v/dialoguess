import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Congratulations!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            Text('Well Done!'),
            ElevatedButton(
              child: Text('Next'),
              onPressed: () {
                // TODO: Navigate to the next level or screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
