import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dialoguess/firebase_options.dart';
import 'src/screens/start_screen.dart';
import 'src/controllers/audio_manager.dart'; // Import AudioManager

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DialoguessApp());
}

class DialoguessApp extends StatefulWidget {
  const DialoguessApp({super.key});

  @override
  _DialoguessAppState createState() => _DialoguessAppState();
}

class _DialoguessAppState extends State<DialoguessApp>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.paused) {
      AudioManager.pauseBackgroundMusic(); // Pause music when app is inactive
    } else if (state == AppLifecycleState.resumed) {
      AudioManager.resumeBackgroundMusic(); // Resume music when app is active
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }
}
