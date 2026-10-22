import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Beyân Akustik & Dokunsal Ses Efektleri Servisi (Zikirmatik & Mushaf Sayfa)
class AcousticAudioService {
  static final AcousticAudioService instance = AcousticAudioService._internal();
  factory AcousticAudioService() => instance;
  AcousticAudioService._internal();

  AudioPlayer? _zikrPlayer;
  bool isZikrSoundEnabled = true;
  bool isPageFlipSoundEnabled = true;

  /// 0: Kadife Mekanik Tık (Apple/Native Sistem Tıkı - Varsayılan, Sıfır Gecikmeli & Doğal)
  /// 1: Yumuşak Kehribar / Kuka Dokunuşu (Sıcak Ahşap Akustik Tını)
  /// 2: Sessiz
  int zikrSoundStyle = 0;

  AudioPlayer get _getZikrPlayer {
    _zikrPlayer ??= AudioPlayer()
      ..setPlayerMode(PlayerMode.lowLatency)
      ..setReleaseMode(ReleaseMode.stop);
    return _zikrPlayer!;
  }

  /// Doğal ve huzurlu tesbih çekme sesi (Zikirmatik dokunma anı)
  Future<void> playKukaBeadSound() async {
    if (!isZikrSoundEnabled || zikrSoundStyle == 2) return;

    // Mod 0 (Varsayılan): Cihazın kendi doğal mekanik "Kadife Tık" sistem sesi (Apple Watch / iOS Crown hissi)
    if (zikrSoundStyle == 0) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
      return;
    }

    // Mod 1: Yumuşak Kehribar & Kuka Ahşap Dokunuşu
    try {
      await SystemSound.play(SystemSoundType.click);
      final player = _getZikrPlayer;
      await player.stop();
      await player.play(
        AssetSource('audio/tesbih_kuka_click.wav'),
        volume: 0.32,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
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
