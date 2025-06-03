// lib/services/notification/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // TTS ayarları
    await _flutterTts!.setLanguage("tr-TR"); // Türkçe
    await _flutterTts!.setPitch(1.0);
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);

    // iOS için ekstra ayarlar
    await _flutterTts!.setSharedInstance(true);
    await _flutterTts!.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );

    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts != null && text.isNotEmpty) {
      // Önce durakla (eğer konuşuyorsa)
      await _flutterTts!.stop();
      
      // Metni seslendir
      await _flutterTts!.speak(text);
    }
  }

  static Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }

  static Future<void> pause() async {
    if (_flutterTts != null) {
      await _flutterTts!.pause();
    }
  }

  static Future<bool> isLanguageAvailable(String language) async {
    if (_flutterTts == null) return false;
    
    List<dynamic> languages = await _flutterTts!.getLanguages;
    return languages.contains(language);
  }

  static Future<List<dynamic>> getAvailableLanguages() async {
    if (_flutterTts == null) return [];
    return await _flutterTts!.getLanguages;
  }

  static Future<void> setLanguage(String language) async {
    if (_flutterTts != null) {
      await _flutterTts!.setLanguage(language);
    }
  }

  static Future<void> setSpeechRate(double rate) async {
    if (_flutterTts != null) {
      await _flutterTts!.setSpeechRate(rate);
    }
  }

  static Future<void> setPitch(double pitch) async {
    if (_flutterTts != null) {
      await _flutterTts!.setPitch(pitch);
    }
  }

  static Future<void> setVolume(double volume) async {
    if (_flutterTts != null) {
      await _flutterTts!.setVolume(volume);
    }
  }

  static void dispose() {
    _flutterTts?.stop();
    _flutterTts = null;
    _isInitialized = false;
  }
}