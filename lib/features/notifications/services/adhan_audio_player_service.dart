import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adhan_makam.dart';

/// Ezan Makamları Ses Çalar Servisi
/// Kilit ekranı / güç tuşuna basıldığında veya uygulama arka plana geçtiğinde
/// ezanı otomatik olarak durdurma mekanizmasını içerir.
class AdhanAudioPlayerService with WidgetsBindingObserver {
  static final AdhanAudioPlayerService instance = AdhanAudioPlayerService._internal();
  factory AdhanAudioPlayerService() => instance;
  AdhanAudioPlayerService._internal() {
    _player = AudioPlayer();
    _initAudioSession();
    WidgetsBinding.instance.addObserver(this);
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _currentlyPlaying = null;
        _stateController.add(null);
      }
    });
  }

  /// Kullanıcı telefonun kilit tuşuna (güç/ekran kilitleme) bastığında,
  /// ekran kapandığında veya uygulama arka plana alındığında çalan ezanı anında susturur.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_currentlyPlaying != null) {
        debugPrint('[AdhanAudioPlayerService] Kilit tuşuna basıldı / ekran kilitlendi -> Ezan durduruldu.');
        stop();
      }
    }
  }

  Future<void> _initAudioSession() async {
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
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
    } catch (_) {}
  }

  late final AudioPlayer _player;
  AdhanMakam? _currentlyPlaying;

  final _stateController = StreamController<AdhanMakam?>.broadcast();
  Stream<AdhanMakam?> get currentlyPlayingStream => _stateController.stream;
  AdhanMakam? get currentlyPlaying => _currentlyPlaying;

  /// Seçili makamın sesini önizleme olarak çalar veya çalıyorsa durdurur.
  Future<void> togglePlayPreview(AdhanMakam makam) async {
    if (makam == AdhanMakam.silent) {
      await stop();
      return;
    }

    if (_currentlyPlaying == makam) {
      await stop();
      return;
    }

    try {
      await _player.stop();
      _currentlyPlaying = makam;
      _stateController.add(makam);

      if (makam == AdhanMakam.bell) {
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(const Duration(milliseconds: 600));
        await stop();
        return;
      }

      final asset = makam.assetPath;
      if (asset.isNotEmpty) {
        await _player.play(AssetSource(asset));
      } else {
        await Future.delayed(const Duration(seconds: 1));
        await stop();
      }
    } catch (e) {
      debugPrint('Ezan önizleme çalma hatası: $e');
      await stop();
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _currentlyPlaying = null;
    _stateController.add(null);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    _stateController.close();
  }
}

/// Çalmakta olan ezan makamını anlık olarak yayınlayan Riverpod provider'ı.
final adhanPlayingProvider = StreamProvider<AdhanMakam?>((ref) {
  return AdhanAudioPlayerService.instance.currentlyPlayingStream;
});
