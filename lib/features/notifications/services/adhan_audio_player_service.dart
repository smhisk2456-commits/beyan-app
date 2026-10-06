import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/adhan_makam.dart';

/// Ezan Makamları Önizleme Ses Çalar Servisi
class AdhanAudioPlayerService {
  static final AdhanAudioPlayerService instance = AdhanAudioPlayerService._internal();
  factory AdhanAudioPlayerService() => instance;
  AdhanAudioPlayerService._internal() {
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _currentlyPlaying = null;
        _stateController.add(null);
      }
    });
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

      final url = makam.previewAudioUrl;
      if (url.isNotEmpty) {
        await _player.play(UrlSource(url));
      } else {
        // Bell tonu veya ses yoksa 1 saniye sonra durdur
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
    _player.dispose();
    _stateController.close();
  }
}
