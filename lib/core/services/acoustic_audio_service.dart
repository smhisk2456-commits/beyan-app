import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Beyân Akustik & ASMR Ses Efektleri Servisi (Kuka Tesbih & Parşömen Sayfa)
class AcousticAudioService {
  static final AcousticAudioService instance = AcousticAudioService._internal();
  factory AcousticAudioService() => instance;
  AcousticAudioService._internal();

  AudioPlayer? _zikrPlayer;
  bool isZikrSoundEnabled = true;
  bool isPageFlipSoundEnabled = true;

  AudioPlayer get _getZikrPlayer {
    _zikrPlayer ??= AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop);
    return _zikrPlayer!;
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

  /// İpeksi sayfa çevrilme dokunsal geri bildirimi (yapay ses kaldırıldı, doğal dokunsal his)
  Future<void> playParchmentPageFlip() async {
    if (!isPageFlipSoundEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void dispose() {
    _zikrPlayer?.dispose();
    _zikrPlayer = null;
  }
}
