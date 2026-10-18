import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/services/prayer_time_service.dart';

/// iOS ActivityKit Canlı Etkinlik (Live Activity) ve Dynamic Island köprüsü.
class LiveActivityService {
  static const MethodChannel _channel = MethodChannel('com.smhisk60.beyan/live_activity');
  static const String triggerMinutesKey = 'live_activity_trigger_minutes';

  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  /// Cihazın / platformun Canlı Etkinlikleri destekleyip desteklemediğini kontrol eder.
  Future<bool> isSupported() async {
    if (kIsWeb || !Platform.isIOS) return false;
    try {
      final supported = await _channel.invokeMethod<bool>('isLiveActivitySupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Namaz vakitlerini ve tetiklenme eşiğini iOS ActivityKit ile senkronize eder.
  /// [customTriggerMinutes] verilirse (ör: -1 Sürekli / Her Zaman Açık), doğrudan kullanılır.
  Future<void> syncLiveActivity({
    DailyPrayerTimes? dailyPrayerTimes,
    String? cityName,
    int? customTriggerMinutes,
  }) async {
    if (kIsWeb || !Platform.isIOS) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final triggerMinutes = customTriggerMinutes ?? prefs.getInt(triggerMinutesKey) ?? 45;
      final langCode = prefs.getString('selected_app_language') ?? 'tr';

      final prayerService = PrayerTimeService();
      final location = await prayerService.getCurrentLocation();
      final resolvedCity = cityName ?? location.cityName;

      final daily = dailyPrayerTimes ?? await prayerService.calculatePrayerTimes(location: location);
      final next = daily.nextPrayerEntry;
      if (next == null) return;

      final nextPrayerName = next.name.localizedName(langCode);
      final nextPrayerTime = prayerService.formatTime(next.time);
      final targetTimestamp = next.time.millisecondsSinceEpoch / 1000.0;
      const isKerahat = false;

      await _channel.invokeMethod('startOrUpdateLiveActivity', {
        'prayerName': nextPrayerName,
        'prayerTime': nextPrayerTime,
        'targetTimestamp': targetTimestamp,
        'cityName': resolvedCity,
        'isKerahat': isKerahat,
        'triggerMinutes': triggerMinutes,
      });
    } catch (e) {
      debugPrint('[LiveActivityService] Live Activity senkronizasyon hatası: $e');
    }
  }

  /// Etkin tüm canlı etkinlikleri sonlandırır.
  Future<void> stopLiveActivity() async {
    if (kIsWeb || !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stopLiveActivity');
    } catch (e) {
      debugPrint('[LiveActivityService] Canlı etkinlik durdurma hatası: $e');
    }
  }
}
