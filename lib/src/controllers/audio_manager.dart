import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool _isMusicEnabled = true;
  static bool _isSFXEnabled = true;

  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('musicEnabled') ?? true;
    _isSFXEnabled = prefs.getBool('sfxEnabled') ?? true;
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    }
  }

  static Future<void> playBackgroundMusic() async {
    await _bgmPlayer.play(AssetSource('music/bgm.mp3'), volume: 0.5);
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static void pauseBackgroundMusic() {
    _bgmPlayer.pause();
  }

  static void resumeBackgroundMusic() {
    if (_isMusicEnabled) {
      _bgmPlayer.resume();
    }
  }

  static Future<void> playSFX(String fileName) async {
    if (_isSFXEnabled) {
      await _sfxPlayer.play(AssetSource('sfx/$fileName'), volume: 1.0);
    }
  }

  static Future<void> setMusicEnabled(bool isEnabled) async {
    _isMusicEnabled = isEnabled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', isEnabled);
    if (isEnabled) {
      await playBackgroundMusic();
    } else {
      pauseBackgroundMusic();
    }
  }

  static Future<void> setSFXEnabled(bool isEnabled) async {
    _isSFXEnabled = isEnabled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfxEnabled', isEnabled);
  }
}
