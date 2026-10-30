import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS Kilit Ekranı ve Denetim Merkezi (Now Playing / Control Center)
/// Medya kartı ve kilit ekranı ses denetimlerini yöneten servis.
class NowPlayingService {
  static final NowPlayingService _instance = NowPlayingService._internal();
  factory NowPlayingService() => _instance;
  static NowPlayingService get instance => _instance;

  NowPlayingService._internal() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const MethodChannel _channel = MethodChannel('com.smhisk60.beyan/now_playing');

  // Uzaktan kumanda / Kilit ekranı olay dinleyicileri (Play, Pause, Skip, Seek)
  VoidCallback? onPlay;
  VoidCallback? onPause;
  VoidCallback? onTogglePlayPause;
  VoidCallback? onNext;
  VoidCallback? onPrevious;
  void Function(double positionSeconds)? onSeek;

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onRemotePlay':
          onPlay?.call();
          break;
        case 'onRemotePause':
          onPause?.call();
          break;
        case 'onRemoteTogglePlayPause':
          onTogglePlayPause?.call();
          break;
        case 'onRemoteNext':
          onNext?.call();
          break;
        case 'onRemotePrevious':
          onPrevious?.call();
          break;
        case 'onRemoteSeek':
          final args = call.arguments as Map?;
          final pos = (args?['positionSeconds'] as num?)?.toDouble() ?? 0.0;
          onSeek?.call(pos);
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('NowPlayingService native call error: $e');
    }
  }

  /// Kilit ekranı ve iOS denetim merkezine medya bilgilerini gönderir.
  Future<void> updateNowPlaying({
    required String title,
    required String artist,
    String? albumTitle,
    required double durationSeconds,
    required double positionSeconds,
    required bool isPlaying,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod('updateNowPlaying', {
        'title': title,
        'artist': artist,
        'albumTitle': albumTitle ?? 'Beyân',
        'durationSeconds': durationSeconds,
        'positionSeconds': positionSeconds,
        'isPlaying': isPlaying,
      });
    } catch (e) {
      debugPrint('NowPlaying update error: $e');
    }
  }

  /// Ses bittiğinde veya kapatıldığında kilit ekranındaki kartı temizler.
  Future<void> clearNowPlaying() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod('clearNowPlaying');
    } catch (e) {
      debugPrint('NowPlaying clear error: $e');
    }
  }
}
