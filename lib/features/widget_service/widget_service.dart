import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../prayer_times/models/prayer_time_model.dart';
import '../prayer_times/services/prayer_time_service.dart';
import '../quran/repositories/quran_repository.dart';

/// Home Widget ve SharedPreferences köprüsü.
///
/// Sorumlulukları:
/// 1. Namaz vakitlerini ve günlük ayeti [home_widget] ortak alanına yazar.
/// 2. iOS WidgetKit ve Android AppWidget bu verileri okur.
/// 3. WorkManager arka plan görevi bu servisi çağırır.
class WidgetService {
  // ── Singleton ──────────────────────────────────────────────
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  final PrayerTimeService _prayerService = PrayerTimeService();

  // ── iOS App Group Identifier ──────────────────────────────
  /// home_widget'ın iOS'ta SharedPreferences yerine
  /// UserDefaults App Group'unu kullanması için gerekli.
  static const String _appGroupId = 'group.com.example.islamicApp';

  // ── Başlatma ───────────────────────────────────────────────

  /// Uygulamanın başında bir kez çağrılır.
  /// App Group kaydı yapar.
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  final QuranRepository _quranRepo = QuranRepository();

  // ── Ana Güncelleme Metodu ─────────────────────────────────

  /// Widget verilerini hesaplar ve platforma yazar.
  Future<void> updateAllWidgets() async {
    try {
      // 1. Namaz Vakitleri
      final location = await _prayerService.getCurrentLocation();
      final daily = await _prayerService.calculatePrayerTimes(location: location);
      final next = daily.nextPrayerEntry;
      final countdown = _prayerService.formatCountdown(daily.timeUntilNextPrayer);

      // 2. Çoklu Rastgele Ayet Çekimi (Widget döngüsü için 50 adet)
      final verses = await _quranRepo.getRandomVerses(50);
      // Ayetleri JSON'a çevir
      final versesList = verses.map((v) => {
        'ref': '${v.surahId}:${v.verseNumber}', // Örn: 16:114
        'text': v.turkishMeaning,
      }).toList();
      final versesJson = jsonEncode(versesList);

      // Kullanıcının seçtiği güncelleme aralığını al (varsayılan 5 dk, 3-15 dk arası güvenli sınır)
      final prefs = await SharedPreferences.getInstance();
      final interval = (prefs.getInt('widget_update_interval') ?? 5).clamp(3, 15);

      // 3. home_widget ortak alanına yaz
      await _writeToHomeWidget(
        nextPrayerName: next?.name.turkish ?? '--',
        nextPrayerTime: next != null ? _prayerService.formatTime(next.time) : '--:--',
        countdown: countdown,
        allPrayers: daily.prayers,
        versesJson: versesJson,
        interval: interval,
      );

      // 4. Native widget'ları yenile
      await _refreshNativeWidgets();
    } catch (e) {
      _log('Widget güncelleme hatası: $e');
    }
  }

  /// Verileri home_widget ortak deposuna yazar.
  Future<void> _writeToHomeWidget({
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    required List<PrayerEntry> allPrayers,
    required String versesJson,
    required int interval,
  }) async {
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetNextPrayer, nextPrayerName);
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetNextPrayerTime, nextPrayerTime);
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetCountdown, countdown);
    
    // Ayet listesi ve döngü aralığı
    await HomeWidget.saveWidgetData<String>('widget_verses_json', versesJson);
    await HomeWidget.saveWidgetData<int>('widget_update_interval', interval);

    // Tüm vakitler
    for (final prayer in allPrayers) {
      await HomeWidget.saveWidgetData<String>('widget_${prayer.name.key}_time', _prayerService.formatTime(prayer.time));
    }
  }

  /// iOS ve Android native widget'larını yeniler.
  Future<void> _refreshNativeWidgets() async {
    // iOS WidgetKit Timeline'ını geçersiz kıl
    await HomeWidget.updateWidget(
      name: AppConstants.iOSWidgetName,
      iOSName: AppConstants.iOSWidgetName,
    );

    // Android AppWidget'ı yenile
    await HomeWidget.updateWidget(
      name: AppConstants.androidWidgetName,
      androidName: AppConstants.androidWidgetName,
    );
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[WidgetService] $msg');
  }
}

/// WidgetService provider'ı.
final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});
