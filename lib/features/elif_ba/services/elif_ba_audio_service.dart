import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ElifBaAudioService {
  static final ElifBaAudioService _instance = ElifBaAudioService._internal();
  factory ElifBaAudioService() => _instance;
  ElifBaAudioService._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  static const Map<String, String> _arabicLetterFullNames = {
    'ا': 'أَلِف',
    'ب': 'بَاء',
    'ت': 'تَاء',
    'ث': 'ثَاء',
    'ج': 'جِيم',
    'ح': 'حَاء',
    'خ': 'خَاء',
    'د': 'دَال',
    'ذ': 'ذَال',
    'ر': 'رَاء',
    'ز': 'زَاي',
    'س': 'سِين',
    'ش': 'شِين',
    'ص': 'صَاد',
    'ض': 'ضَاد',
    'ط': 'طَاء',
    'ظ': 'ظَاء',
    'ع': 'عَيْن',
    'غ': 'غَيْن',
    'ف': 'فَاء',
    'ق': 'قَاف',
    'ك': 'كَاف',
    'ل': 'لَام',
    'م': 'مِيم',
    'ن': 'نُون',
    'و': 'وَاو',
    'ه': 'هَاء',
    'ي': 'يَاء',
  };

  Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('ar-SA');
      await _flutterTts.setSpeechRate(0.38); // Çocuklar ve yeni başlayanlar için anlaşılır yavaş tempo
      await _flutterTts.setPitch(1.05); // Samimi ve net ton
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
      });

      _flutterTts.setErrorHandler((_) {
        _isPlaying = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('ElifBaAudioService init hatası: $e');
    }
  }

  /// Harf, hareke veya kelimeyi Arapça seslendirir
  Future<void> speakArabic(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    await _initTts();

    try {
      await _flutterTts.stop();

      // Eğer tek yalın harf ise tam okunuş adını seslendir (örn. 'ب' -> 'بَاء')
      final toSpeak = _arabicLetterFullNames[clean] ?? clean;

      await _flutterTts.speak(toSpeak);
    } catch (e) {
      debugPrint('ElifBaAudioService speak hatası: $e');
    }
  }

  /// Harfin fonetik sesini seslendirir (örn. Üstünlü, Esreli veya Harf Adı)
  Future<void> speakPhonetic(String text) async {
    await speakArabic(text);
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (_) {}
  }
}
