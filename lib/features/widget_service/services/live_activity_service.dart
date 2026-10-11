import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iOS 16.1+ Live Activities & Dynamic Island Yönetim Servisi
class LiveActivityService {
  static final LiveActivityService instance = LiveActivityService._internal();
  factory LiveActivityService() => instance;
  LiveActivityService._internal();

  static const MethodChannel _channel = MethodChannel('com.smhisk60.beyan/live_activity');
  static const String _prefKey = 'live_activity_enabled';

  bool get isSupported => Platform.isIOS;

  /// Kullanıcının Canlı Etkinlik tercihini okur (Varsayılan: true)
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true;
  }

  /// Canlı Etkinlik tercihini günceller
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    if (!enabled) {
      await stopLiveActivity();
    }
  }

  /// Sıradaki namaz vakti için Dynamic Island ve Kilit Ekranı Canlı Etkinliğini başlatır veya günceller
  Future<bool> syncWithNextPrayer({
    required String prayerName,
    required String prayerTime,
    required DateTime targetDate,
    required double progress,
  }) async {
    if (!isSupported) return false;

    final enabled = await isEnabled();
    if (!enabled) return false;

    try {
      final targetSeconds = targetDate.millisecondsSinceEpoch / 1000.0;
      final isActive = await isLiveActivityActive();

      if (isActive) {
        await _channel.invokeMethod('updateLiveActivity', {
          'prayerName': prayerName,
          'prayerTime': prayerTime,
          'targetTimestamp': targetSeconds,
          'progress': progress.clamp(0.0, 1.0),
        });
      } else {
        await _channel.invokeMethod('startLiveActivity', {
          'prayerName': prayerName,
          'prayerTime': prayerTime,
          'targetTimestamp': targetSeconds,
          'progress': progress.clamp(0.0, 1.0),
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Aktif Canlı Etkinliği sonlandırır
  Future<void> stopLiveActivity() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('stopLiveActivity');
    } catch (_) {}
  }

  /// Canlı etkinliğin çalışıp çalışmadığını sorgular
  Future<bool> isLiveActivityActive() async {
    if (!isSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isLiveActivityActive');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
