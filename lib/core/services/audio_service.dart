// ignore_for_file: avoid_print

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static String? _currentAlarmPath;

  static Future<void> playAlarm({String? customSound}) async {
    try {
      // Stop any currently playing alarm
      await stopAlarm();

      // Set the alarm sound (custom or default)
      final soundPath = customSound ?? 'audio/default_alarm.mp3';
      _currentAlarmPath = soundPath;

      // Configure audio player for loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);

      // Play the alarm
      await _audioPlayer.play(AssetSource(soundPath));
      _isPlaying = true;

      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Playing alarm: $soundPath');
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Error playing alarm: $e');
    }
  }

  static Future<void> stopAlarm() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        _isPlaying = false;
        _currentAlarmPath = null;
        print('Alarm stopped');
      }
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  static Future<void> pauseAlarm() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
        print('Alarm paused');
      }
    } catch (e) {
      print('Error pausing alarm: $e');
    }
  }

  static Future<void> resumeAlarm() async {
    try {
      if (!_isPlaying && _currentAlarmPath != null) {
        await _audioPlayer.resume();
        _isPlaying = true;
        print('Alarm resumed');
      }
    } catch (e) {
      print('Error resuming alarm: $e');
    }
  }

  static bool get isPlaying => _isPlaying;

  static Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  static Future<void> testSound(String soundPath) async {
    try {
      final testPlayer = AudioPlayer();
      await testPlayer.play(AssetSource(soundPath));

      // Auto stop after 3 seconds for testing
      await Future.delayed(const Duration(seconds: 3));
      await testPlayer.stop();
      await testPlayer.dispose();
    } catch (e) {
      print('Error testing sound: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      await stopAlarm();
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio service: $e');
    }
  }
}
