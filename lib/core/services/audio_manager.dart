import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioManagerProvider = Provider<AudioManager>((ref) {
  return AudioManager();
});

/// Sound types for UI feedback.
enum SoundType { correct, incorrect, complete, tap, levelUp, streak }

/// Language locale codes for TTS.
const _ttsLocales = {
  'bg': 'bg-BG',
  'ro': 'ro-RO',
  'ka': 'ka-GE',
  'sv': 'sv-SE',
};

/// Central audio manager controlling TTS, sound effects, and preventing overlap.
class AudioManager {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'bg';

  /// Initialize TTS engine.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    _isInitialized = true;
  }

  /// Set the TTS language.
  Future<void> setLanguage(String languageId) async {
    if (_currentLanguage == languageId && _isInitialized) return;
    _currentLanguage = languageId;
    final locale = _ttsLocales[languageId] ?? 'en-US';
    await initialize();
    await _tts.setLanguage(locale);
  }

  /// Speak text in the current target language.
  Future<void> speak(String text, {String? languageId}) async {
    if (_isSpeaking) {
      await stop();
    }
    if (languageId != null) {
      await setLanguage(languageId);
    }
    await initialize();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Speak text slowly for pronunciation practice.
  Future<void> speakSlow(String text, {String? languageId}) async {
    await initialize();
    await _tts.setSpeechRate(0.25);
    await speak(text, languageId: languageId);
    // Restore normal rate after speaking
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _tts.setSpeechRate(0.45);
    });
  }

  /// Stop all audio.
  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
    await _sfxPlayer.stop();
  }

  /// Play a UI sound effect.
  Future<void> playSound(SoundType type) async {
    // Use short synthesized audio clips for feedback
    // In production, these would be asset audio files
    try {
      switch (type) {
        case SoundType.correct:
          await _tts.setSpeechRate(0.8);
          // A quick "ding" substitute — will be replaced with real assets
          break;
        case SoundType.incorrect:
          break;
        case SoundType.complete:
          break;
        case SoundType.tap:
          break;
        case SoundType.levelUp:
          break;
        case SoundType.streak:
          break;
      }
    } catch (_) {
      // Silently fail on audio errors
    }
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await _tts.stop();
    await _sfxPlayer.dispose();
    _isInitialized = false;
  }

  bool get isSpeaking => _isSpeaking;
}
