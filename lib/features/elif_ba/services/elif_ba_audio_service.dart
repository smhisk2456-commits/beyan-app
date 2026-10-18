import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Elif-Bâ Ses Servisi
/// 28 temel Arapça harf için yüksek kaliteli, gerçek hoca/kāri tilaveti (MP3) çalar.
/// Çevrimdışı çalışır, sıfır gecikmelidir ve cihazın sistem dil paketine bağımlı değildir.
/// Çok heceli dualar ve cümleler için FlutterTts desteğini yedek olarak kullanır.
class ElifBaAudioService {
  static final ElifBaAudioService _instance = ElifBaAudioService._internal();
  factory ElifBaAudioService() => _instance;

  ElifBaAudioService._internal() {
    _initAudio();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // Harf ID -> Arapça Temel Karakter
  static const Map<String, int> _arabicToLetterId = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1,
    'ب': 2,
    'ت': 3, 'ة': 3,
    'ث': 4,
    'ج': 5,
    'ح': 6,
    'خ': 7,
    'د': 8,
    'ذ': 9,
    'ر': 10,
    'ز': 11,
    'س': 12,
    'ش': 13,
    'ص': 14,
    'ض': 15,
    'ط': 16,
    'ظ': 17,
    'ع': 18,
    'غ': 19,
    'ف': 20,
    'ق': 21,
    'ك': 22,
    'ل': 23,
    'م': 24,
    'ن': 25,
    'و': 26,
    'ه': 27,
    'ي': 28, 'ى': 28,
  };

  static const Map<String, int> _nameToLetterId = {
    'elif': 1, 'alif': 1,
    'be': 2, 'baa': 2,
    'te': 3, 'taa': 3,
    'se': 4, 'thaa': 4, 'se (peltek)': 4,
    'cim': 5, 'jeem': 5,
    'ha': 6, 'haa': 6, 'ha (boğaz)': 6,
    'hı': 7, 'khaa': 7, 'hı (hırıltılı)': 7,
    'dal': 8, 'daal': 8,
    'zel': 9, 'zaal': 9, 'zel (peltek)': 9,
    'ra': 10, 'raa': 10,
    'ze': 11, 'zaay': 11, 'ze (keskin)': 11,
    'sin': 12, 'seen': 12,
    'şın': 13, 'sheen': 13,
    'sad': 14, 'saad': 14, 'sad (kalın)': 14,
    'dad': 15, 'daad': 15,
    'tı': 16, 'taah': 16, 'tı (kalın)': 16,
    'zı': 17, 'zhaa': 17, 'zı (kalın peltek)': 17,
    'ayn': 18, 'ain': 18,
    'gayn': 19, 'ghayn': 19,
    'fe': 20, 'faa': 20,
    'kaf': 21, 'qaaf': 21, 'kaf (kalın)': 21,
    'kef': 22, 'kaaf': 22, 'kef (ince)': 22,
    'lam': 23, 'laam': 23,
    'mim': 24, 'meem': 24,
    'nun': 25, 'noon': 25,
    'vav': 26, 'waaw': 26, 'waw': 26,
    'he': 27, 'he (göğüs)': 27, 'haah': 27,
    'ye': 28, 'yaa': 28,
  };

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      _audioPlayer.onPlayerStateChanged.listen((state) {
        _isPlaying = (state == PlayerState.playing);
      });
    } catch (e) {
      debugPrint('[ElifBaAudioService] AudioContext init hatası: $e');
    }
  }

  Future<void> _initTts() async {
    if (_isTtsInitialized) return;
    try {
      await _flutterTts.setLanguage('ar-SA');
      await _flutterTts.setSpeechRate(0.38);
      await _flutterTts.setPitch(1.05);
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

      _isTtsInitialized = true;
    } catch (e) {
      debugPrint('[ElifBaAudioService] TTS init hatası: $e');
    }
  }

  /// Harf ID'si (1 - 28) ile gerçek hoca sesini anında çalar.
  Future<void> playLetter(int letterId) async {
    if (letterId < 1 || letterId > 28) return;
    try {
      await stop();
      final assetPath = 'audio/letters/letter_$letterId.mp3';
      await _audioPlayer.play(AssetSource(assetPath));
      _isPlaying = true;
    } catch (e) {
      debugPrint('[ElifBaAudioService] playLetter ($letterId) hatası: $e');
    }
  }

  /// Harf, hareke veya kelimeyi seslendirir.
  /// Tek harf veya harf formu ise gerçek hoca MP3 tilaveti çalar.
  Future<void> speakArabic(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    // Sayısal ID geldiyse doğrudan harfi çal
    final numeric = int.tryParse(clean.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numeric != null && numeric >= 1 && numeric <= 28) {
      await playLetter(numeric);
      return;
    }

    // Harf veya harf formu kontrolü
    final letterId = _resolveLetterId(clean);
    if (letterId != null) {
      await playLetter(letterId);
      return;
    }

    // Çok harfli veya hareke içeren özel kelimeler için TTS yedeği
    await _speakWithTts(clean);
  }

  /// Fonetik telaffuz çağrısı
  Future<void> speakPhonetic(String text) async {
    await speakArabic(text);
  }

  int? _resolveLetterId(String input) {
    // 1. İsim eşleşmesi (Türkçe/İngilizce)
    final lower = input.toLowerCase().trim();
    if (_nameToLetterId.containsKey(lower)) {
      return _nameToLetterId[lower];
    }

    // 2. Uzatma/keşide (ـ) ve harekeleri temizle
    final stripped = input
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .trim();

    if (_arabicToLetterId.containsKey(stripped)) {
      return _arabicToLetterId[stripped];
    }

    // 3. Tek harf içeriyorsa harfi tespit et
    if (stripped.length == 1 && _arabicToLetterId.containsKey(stripped)) {
      return _arabicToLetterId[stripped];
    }

    return null;
  }

  Future<void> _speakWithTts(String arabicText) async {
    try {
      await stop();
      await _initTts();
      await _flutterTts.speak(arabicText);
    } catch (e) {
      debugPrint('[ElifBaAudioService] TTS speak hatası: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isPlaying = false;
  }
}
