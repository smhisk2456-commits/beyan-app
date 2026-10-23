import 'package:flutter/services.dart';

/// Beyân Dokunsal Geri Bildirim Servisi (Mushaf Sayfa Çevirme)
class AcousticAudioService {
  static final AcousticAudioService instance = AcousticAudioService._internal();
  factory AcousticAudioService() => instance;
  AcousticAudioService._internal();

  bool isPageFlipSoundEnabled = true;

  /// İpeksi sayfa çevrilme dokunsal geri bildirimi
  Future<void> playParchmentPageFlip() async {
    if (!isPageFlipSoundEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void dispose() {}
}

