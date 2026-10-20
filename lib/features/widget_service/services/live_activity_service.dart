import 'dart:async';
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
  static const String enabledKey = 'live_activity_enabled';

  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  Timer? _prayerTransitionTimer;

  /// Canlı etkinliğin ayarlardan açık olup olmadığını döner.
  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(enabledKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Canlı etkinliği açar veya tamamen devre dışı bırakır.
  Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(enabledKey, enabled);
      if (!enabled) {
        _prayerTransitionTimer?.cancel();
        _prayerTransitionTimer = null;
        await stopLiveActivity();
      } else {
        await syncLiveActivity();
      }
    } catch (e) {
      debugPrint('[LiveActivityService] setEnabled hatası: $e');
    }
  }

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
      final isActEnabled = await isEnabled();
      if (!isActEnabled) {
        _prayerTransitionTimer?.cancel();
        _prayerTransitionTimer = null;
        await stopLiveActivity();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      var triggerMinutes = customTriggerMinutes ?? prefs.getInt(triggerMinutesKey) ?? -1;
      // Eski varsayılan olan 45'i otomatik olarak sürekli açık (-1) moduna geçir:
      if (triggerMinutes == 45) {
        triggerMinutes = -1;
        await prefs.setInt(triggerMinutesKey, -1);
      }
      final langCode = prefs.getString('selected_app_language') ?? 'tr';

      final prayerService = PrayerTimeService();
      final location = await prayerService.getCurrentLocation();
      final resolvedCity = cityName ?? location.cityName;

      final daily = dailyPrayerTimes ?? await prayerService.calculatePrayerTimes(location: location);
      final next = daily.nextPrayerEntry;
      if (next == null) return;

      final diff = next.time.difference(DateTime.now());

      // Eğer kullanıcı tamamen devre dışı bırakmışsa (-999):
      if (triggerMinutes == -999) {
        _prayerTransitionTimer?.cancel();
        _prayerTransitionTimer = null;
        await stopLiveActivity();
        return;
      }

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

      // Vakit girdiğinde sayacın ileriye doğru kronometre gibi saymasını önle:
      // Tam vakit saniyesinde otomatik olarak bir sonraki namazı senkronize et
      _prayerTransitionTimer?.cancel();
      if (diff > Duration.zero) {
        _prayerTransitionTimer = Timer(diff + const Duration(seconds: 1), () {
          syncLiveActivity();
        });
      }
    } catch (e) {
      debugPrint('[LiveActivityService] Live Activity senkronizasyon hatası: $e');
    }
  }

  /// Etkin tüm canlı etkinlikleri sonlandırır.
  Future<void> stopLiveActivity() async {
    _prayerTransitionTimer?.cancel();
    _prayerTransitionTimer = null;
    if (kIsWeb || !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stopLiveActivity');
    } catch (e) {
      debugPrint('[LiveActivityService] Canlı etkinlik durdurma hatası: $e');
    }
  }
}
