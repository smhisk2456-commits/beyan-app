import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Beyân Akustik & ASMR Ses Efektleri Servisi (Kuka Tesbih & Parşömen Sayfa)
class AcousticAudioService {
  static final AcousticAudioService instance = AcousticAudioService._internal();
  factory AcousticAudioService() => instance;
  AcousticAudioService._internal();

  AudioPlayer? _zikrPlayer;
  AudioPlayer? _pageFlipPlayer;
  bool isZikrSoundEnabled = true;
  bool isPageFlipSoundEnabled = true;

  AudioPlayer get _getZikrPlayer {
    _zikrPlayer ??= AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop);
    return _zikrPlayer!;
  }

  AudioPlayer get _getPageFlipPlayer {
    _pageFlipPlayer ??= AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop);
    return _pageFlipPlayer!;
  }

  /// Gerçek Kuka ahşap tesbih tıkırtısı (Zikirmatik dokunma anı)
  Future<void> playKukaBeadSound() async {
    if (!isZikrSoundEnabled) return;
    try {
      final player = _getZikrPlayer;
      await player.stop();
      await player.play(
        AssetSource('audio/tesbih_kuka_click.wav'),
        volume: 0.75,
      );
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// İpeksi parşömen sayfa çevrilme sesi (Mushaf okuma modu)
  Future<void> playParchmentPageFlip() async {
    if (!isPageFlipSoundEnabled) return;
    try {
      final player = _getPageFlipPlayer;
      await player.stop();
      await player.play(
        AssetSource('audio/parchment_page_flip.wav'),
        volume: 0.65,
      );
    } catch (_) {}
  }

  void dispose() {
    _zikrPlayer?.dispose();
    _pageFlipPlayer?.dispose();
    _zikrPlayer = null;
    _pageFlipPlayer = null;
  }
}
