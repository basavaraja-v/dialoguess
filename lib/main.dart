import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dialoguess/firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'src/ads/ads_controller.dart';
import 'src/screens/start_screen.dart';
import 'src/controllers/audio_manager.dart'; // Import AudioManager
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AdsController? adsController;
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    /// Prepare the google_mobile_ads plugin so that the first ad loads
    /// faster. This can be done later or with a delay if startup
    /// experience suffers.
    adsController = AdsController(MobileAds.instance);
    adsController.initialize();
  }
  runApp(Provider<AdsController?>.value(
    value: adsController,
    child: const DialoguessApp(),
  ));
}

class DialoguessApp extends StatefulWidget {
  const DialoguessApp({super.key});

  @override
  _DialoguessAppState createState() => _DialoguessAppState();
}

class _DialoguessAppState extends State<DialoguessApp>
    with WidgetsBindingObserver {
  bool _wasAppMinimized = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioManager.init(); // Initialize and play BGM if enabled
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DialoGuess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StartScreen(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        // App is in background
        _wasAppMinimized = true;
        AudioManager.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        // App is back to foreground
        if (!_wasAppMinimized) {
          AudioManager.resumeBackgroundMusic();
        }
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (like receiving a phone call)
        _wasAppMinimized = false;
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }
}
