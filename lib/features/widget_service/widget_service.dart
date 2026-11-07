import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../prayer_times/models/prayer_time_model.dart';
import '../prayer_times/services/prayer_time_service.dart';
import '../quran/repositories/quran_repository.dart';
import '../notifications/models/short_verse_notification.dart';
import 'services/live_activity_service.dart';
import 'screens/widget_center_screen.dart';

import '../../core/localization/app_strings.dart';

/// Home Widget, Shared Keychain ve SharedPreferences köprüsü.
///
/// Sorumlulukları:
/// 1. Namaz vakitlerini, günlük ayeti ve tüm widget özelleştirmelerini hem [home_widget]
///    hem de iOS Shared Keychain köprüsüne (`com.smhisk60.beyan/widget_bridge`) yazar.
/// 2. iOS WidgetKit ve Android AppWidget bu verileri anında okur.
/// 3. WorkManager arka plan görevi bu servisi çağırır.
class WidgetService {
  // ── Singleton ──────────────────────────────────────────────
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  final PrayerTimeService _prayerService = PrayerTimeService();
  final QuranRepository _quranRepo = QuranRepository();

  static const String _appGroupId = 'group.com.smhisk60.beyan';
  static const MethodChannel _bridgeChannel =
      MethodChannel('com.smhisk60.beyan/widget_bridge');

  /// Uygulamanın başında bir kez çağrılır.
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Kullanıcının Widget sekmesinde yaptığı her değişikliği (<10ms içinde)
  /// beklemeden iOS Shared Keychain ve WidgetCenter'a anında yazar.
  Future<void> syncImmediateSettings([Map<String, dynamic>? extraData]) async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('selected_app_language') ?? 'tr';
      final quoteCat = prefs.getString('widget_quote_category') ?? 'all';
      final verseView = prefs.getString('widget_verse_view') ?? 'meal_only';
      final textSize = prefs.getString('widget_text_size') ?? 'standard';
      final activeCat = prefs.getString('widget_active_category') ?? 'quotes';
      final refreshInterval = prefs.getString('widget_refresh_interval') ?? '1h';
      final prayerStyle = prefs.getString('widget_prayer_style') ?? 'detailed';
      final countdownStyle =
          prefs.getString('widget_countdown_style') ?? 'timer_and_time';
      final hijriStyle =
          prefs.getString('widget_hijri_style') ?? 'hijri_and_kandil';
      final hijriOffset = prefs.getString('widget_hijri_offset') ?? '0';
      final kerahetMinutes = prefs.getString('widget_kerahet_minutes') ?? '45';
      final sunStyle = prefs.getString('widget_sun_style') ?? 'full';

      final isPinned = prefs.getBool('widget_is_pinned') ?? false;
      var appliedRef = prefs.getString('widget_applied_verse_ref') ?? '';
      var appliedText = prefs.getString('widget_applied_verse_text') ?? '';
      final appliedArabic = prefs.getString('widget_applied_verse_arabic') ?? '';
      final appliedSurah = prefs.getInt('widget_applied_verse_surah') ?? 0;
      final appliedVerseNum = prefs.getInt('widget_applied_verse_number') ?? 0;
      final applyNonce = prefs.getInt('widget_apply_nonce') ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // Seçili kategori ve görünüme göre hızlı bellek-içi ayet listesini oluştur
      final List<Map<String, String>> fastVerses = _buildCuratedVerseList(
        activeCat: activeCat,
        quoteCat: quoteCat,
        verseView: verseView,
        langCode: langCode,
        isPinned: isPinned,
        appliedRef: appliedRef,
        appliedText: appliedText,
      );
      final fastVersesJson = jsonEncode(fastVerses);

      final payload = <String, dynamic>{
        'widget_app_language': langCode,
        'widget_quote_category': quoteCat,
        'widget_verse_view': verseView,
        'widget_text_size': textSize,
        'widget_active_category': activeCat,
        'widget_refresh_interval': refreshInterval,
        'widget_prayer_style': prayerStyle,
        'widget_countdown_style': countdownStyle,
        'widget_hijri_style': hijriStyle,
        'widget_hijri_offset': hijriOffset,
        'widget_kerahet_minutes': kerahetMinutes,
        'widget_sun_style': sunStyle,
        'widget_is_pinned': isPinned,
        'widget_applied_verse_ref': appliedRef,
        'widget_applied_verse_text': appliedText,
        'widget_applied_verse_arabic': appliedArabic,
        'widget_applied_verse_surah': appliedSurah,
        'widget_applied_verse_number': appliedVerseNum,
        'widget_apply_nonce': applyNonce,
        'widget_verses_json': fastVersesJson,
        if (extraData != null) ...extraData,
      };

      // 1. iOS Shared Keychain + Native WidgetCenter köprüsüne anında gönder
      await _invokeNativeBridge(payload);

      // 2. HomeWidget UserDefaults alanına da yaz
      await HomeWidget.saveWidgetData<String>('widget_app_language', langCode);
      await HomeWidget.saveWidgetData<String>('widget_quote_category', quoteCat);
      await HomeWidget.saveWidgetData<String>('widget_verse_view', verseView);
      await HomeWidget.saveWidgetData<String>('widget_text_size', textSize);
      await HomeWidget.saveWidgetData<String>('widget_active_category', activeCat);
      await HomeWidget.saveWidgetData<String>(
          'widget_refresh_interval', refreshInterval);
      await HomeWidget.saveWidgetData<String>('widget_prayer_style', prayerStyle);
      await HomeWidget.saveWidgetData<String>(
          'widget_countdown_style', countdownStyle);
      await HomeWidget.saveWidgetData<String>('widget_hijri_style', hijriStyle);
      await HomeWidget.saveWidgetData<String>('widget_hijri_offset', hijriOffset);
      await HomeWidget.saveWidgetData<String>(
          'widget_kerahet_minutes', kerahetMinutes);
      await HomeWidget.saveWidgetData<String>('widget_sun_style', sunStyle);
      await HomeWidget.saveWidgetData<bool>('widget_is_pinned', isPinned);
      await HomeWidget.saveWidgetData<String>(
          'widget_applied_verse_ref', appliedRef);
      await HomeWidget.saveWidgetData<String>(
          'widget_applied_verse_text', appliedText);
      await HomeWidget.saveWidgetData<String>(
          'widget_applied_verse_arabic', appliedArabic);
      await HomeWidget.saveWidgetData<int>(
          'widget_applied_verse_surah', appliedSurah);
      await HomeWidget.saveWidgetData<int>(
          'widget_applied_verse_number', appliedVerseNum);
      await HomeWidget.saveWidgetData<int>('widget_apply_nonce', applyNonce);
      await HomeWidget.saveWidgetData<String>('widget_verses_json', fastVersesJson);

      await _refreshNativeWidgets();
    } catch (e) {
      _log('Hızlı widget senkronizasyon hatası: $e');
    }
  }

  List<Map<String, String>> _buildCuratedVerseList({
    required String activeCat,
    required String quoteCat,
    required String verseView,
    required String langCode,
    required bool isPinned,
    required String appliedRef,
    required String appliedText,
  }) {
    final List<Map<String, String>> widgetVerses = [];

    if (activeCat == 'dailyVerse') {
      for (final v in ShortVerseNotification.pool) {
        final meal = v.localizedText(langCode);
        final text = (verseView == 'arabic_only' || verseView == 'Yalnızca Arapça')
            ? v.arabicText
            : ((verseView == 'arabic_meal' || verseView == 'Arapça + Meal')
                ? '${v.arabicText}\n$meal'
                : meal);
        widgetVerses.add({
          'ref': v.localizedReference(langCode),
          'text': text,
        });
      }
    } else {
      final categoryList =
          kWidgetCategoryQuotes[quoteCat] ?? kWidgetCategoryQuotes['all']!;
      for (final q in categoryList) {
        widgetVerses.add({
          'ref': q.localizedReference(langCode),
          'text': q.formatForViewMode(verseView, langCode),
        });
      }
    }

    if (appliedRef.isNotEmpty && appliedText.isNotEmpty) {
      widgetVerses.removeWhere((item) => item['ref'] == appliedRef);
      widgetVerses.insert(0, {
        'ref': appliedRef,
        'text': appliedText,
      });
    }

    return widgetVerses;
  }

  Future<void> _invokeNativeBridge(Map<String, dynamic> payload) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _bridgeChannel.invokeMethod('syncWidgetData', payload);
    } catch (e) {
      _log('Native widget bridge uyarısı: $e');
    }
  }

  // ── Ana Güncelleme Metodu ─────────────────────────────────

  /// Widget verilerini hesaplar ve platforma yazar.
  Future<void> updateAllWidgets() async {
    try {
      // 0. Önce kullanıcı tercihlerini ve seçili ayeti hiç bekletmeden anında gönder
      await syncImmediateSettings();

      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('selected_app_language') ?? 'tr';
      final lang = AppLanguage.fromCode(langCode);

      // 1. Namaz Vakitleri (Widget için donanım GPS yerine önbellek/hızlı konumu kullan)
      final location = await _prayerService.getCachedOrFastLocation();
      final daily = await _prayerService.calculatePrayerTimes(location: location);
      final next = daily.nextPrayerEntry;
      final countdown =
          _prayerService.formatCountdown(daily.timeUntilNextPrayer, lang: lang);
      final nextPrayerName = next?.name.localizedName(langCode) ?? '--';

      // 1.1 iOS ve Android Widget'ları için kesin namaz çizelgesi (Bildirimlerle tam senkronize)
      final now = DateTime.now();
      final scheduleList = <Map<String, dynamic>>[];
      for (int dayOffset = -1; dayOffset <= 4; dayOffset++) {
        final targetDate = DateTime(now.year, now.month, now.day + dayOffset);
        final d = await _prayerService.calculatePrayerTimes(
            location: location, date: targetDate);
        for (final p in d.prayers) {
          final kind = _prayerNameToKind(p.name);
          if (kind != null) {
            scheduleList.add({
              'kind': kind,
              'epoch': p.time.millisecondsSinceEpoch ~/ 1000,
            });
          }
        }
      }
      final prayerScheduleJson = jsonEncode(scheduleList);
      await HomeWidget.saveWidgetData<String>(
          'widget_prayer_schedule_json', prayerScheduleJson);
      await HomeWidget.saveWidgetData<double>(
          'beyan_widget_lat', location.latitude);
      await HomeWidget.saveWidgetData<double>(
          'beyan_widget_lng', location.longitude);

      // 2. Seçili kategoriye ve görünüme göre duygusal ayet havuzu oluştur
      final quoteCat = prefs.getString('widget_quote_category') ?? 'all';
      final verseView = prefs.getString('widget_verse_view') ?? 'meal_only';
      final activeCat = prefs.getString('widget_active_category') ?? 'quotes';
      final isPinned = prefs.getBool('widget_is_pinned') ?? false;
      final appliedRef = prefs.getString('widget_applied_verse_ref') ?? '';
      final appliedText = prefs.getString('widget_applied_verse_text') ?? '';

      final List<Map<String, String>> widgetVerses = _buildCuratedVerseList(
        activeCat: activeCat,
        quoteCat: quoteCat,
        verseView: verseView,
        langCode: langCode,
        isPinned: isPinned,
        appliedRef: appliedRef,
        appliedText: appliedText,
      );

      // Eğer "Tüm Kategoriler" ve Türkçe Yalnızca Meal seçiliyse veritabanından da ekle
      if (activeCat != 'dailyVerse' &&
          quoteCat == 'all' &&
          langCode == 'tr' &&
          verseView == 'meal_only') {
        try {
          final dbVerses = await _quranRepo.getRandomWidgetVerses(limit: 40);
          widgetVerses.addAll(dbVerses);
        } catch (_) {}
      }

      final versesJson = jsonEncode(widgetVerses);
      final interval = (prefs.getInt('widget_update_interval') ?? 5).clamp(3, 15);

      // 3. home_widget ortak alanına yaz
      await _writeToHomeWidget(
        langCode: langCode,
        nextPrayerName: nextPrayerName,
        nextPrayerTime:
            next != null ? _prayerService.formatTime(next.time) : '--:--',
        countdown: countdown,
        allPrayers: daily.prayers,
        versesJson: versesJson,
        interval: interval,
      );

      // 4. iOS Shared Keychain köprüsüne tam çizelge ve konum verilerini de gönder
      await _invokeNativeBridge({
        'widget_prayer_schedule_json': prayerScheduleJson,
        'beyan_widget_lat': location.latitude,
        'beyan_widget_lng': location.longitude,
        'widget_verses_json': versesJson,
        AppConstants.widgetNextPrayer: nextPrayerName,
        AppConstants.widgetNextPrayerTime:
            next != null ? _prayerService.formatTime(next.time) : '--:--',
        AppConstants.widgetCountdown: countdown,
      });

      // 5. Native widget'ları yenile
      await _refreshNativeWidgets();

      // 6. iOS Canlı Etkinlik (Live Activity) & Dynamic Island senkronizasyonu
      await LiveActivityService().syncLiveActivity(
        dailyPrayerTimes: daily,
        cityName: location.cityName,
      );
    } catch (e) {
      _log('Widget güncelleme hatası: $e');
    }
  }

  /// Verileri home_widget ortak deposuna yazar.
  Future<void> _writeToHomeWidget({
    required String langCode,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    required List<PrayerEntry> allPrayers,
    required String versesJson,
    required int interval,
  }) async {
    await HomeWidget.saveWidgetData<String>('widget_app_language', langCode);
    await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetNextPrayer, nextPrayerName);
    await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetNextPrayerTime, nextPrayerTime);
    await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetCountdown, countdown);

    // Ayet listesi ve döngü aralığı
    await HomeWidget.saveWidgetData<String>('widget_verses_json', versesJson);
    await HomeWidget.saveWidgetData<int>('widget_update_interval', interval);

    // Kilit ekranı özelleştirme tercihleri
    final prefs = await SharedPreferences.getInstance();
    final quoteCat = prefs.getString('widget_quote_category') ?? 'all';
    final verseView = prefs.getString('widget_verse_view') ?? 'meal_only';
    final textSize = prefs.getString('widget_text_size') ?? 'standard';
    final activeCat = prefs.getString('widget_active_category') ?? 'quotes';
    final refreshInterval = prefs.getString('widget_refresh_interval') ?? '1h';

    await HomeWidget.saveWidgetData<String>('widget_quote_category', quoteCat);
    await HomeWidget.saveWidgetData<String>('widget_verse_view', verseView);
    await HomeWidget.saveWidgetData<String>('widget_text_size', textSize);
    await HomeWidget.saveWidgetData<String>('widget_active_category', activeCat);
    await HomeWidget.saveWidgetData<String>(
        'widget_refresh_interval', refreshInterval);

    // Live Activity & Dynamic Island tetiklenme süresi (dk)
    final triggerMinutes = prefs.getInt('live_activity_trigger_minutes') ?? -1;
    await HomeWidget.saveWidgetData<int>(
        'live_activity_trigger_minutes', triggerMinutes);

    // Kilit ekranına uygulanan / sabitlenen özel ayet durumu
    final isPinned = prefs.getBool('widget_is_pinned') ?? false;
    var appliedRef = prefs.getString('widget_applied_verse_ref') ?? '';
    var appliedText = prefs.getString('widget_applied_verse_text') ?? '';
    final appliedSurah = prefs.getInt('widget_applied_verse_surah') ?? 0;
    final appliedVerseNum = prefs.getInt('widget_applied_verse_number') ?? 0;
    final applyNonce = prefs.getInt('widget_apply_nonce') ?? 0;

    if (appliedRef.isNotEmpty &&
        langCode != 'tr' &&
        appliedSurah > 0 &&
        appliedVerseNum > 0) {
      final needle = '$appliedSurah:$appliedVerseNum';
      for (final v in ShortVerseNotification.pool) {
        if (v.verseReference.contains(needle)) {
          appliedRef = v.localizedReference(langCode);
          appliedText = v.localizedText(langCode);
          break;
        }
      }
    }

    await HomeWidget.saveWidgetData<bool>('widget_is_pinned', isPinned);
    await HomeWidget.saveWidgetData<String>(
        'widget_applied_verse_ref', appliedRef);
    await HomeWidget.saveWidgetData<String>(
        'widget_applied_verse_text', appliedText);
    await HomeWidget.saveWidgetData<int>(
        'widget_applied_verse_surah', appliedSurah);
    await HomeWidget.saveWidgetData<int>(
        'widget_applied_verse_number', appliedVerseNum);
    await HomeWidget.saveWidgetData<int>('widget_apply_nonce', applyNonce);

    // Günün Duası & Âyeti Widget Verileri
    final dailyDua = prefs.getString('widget_daily_dua_title') ??
        'Sübhanallâhi ve bihamdihî';
    final dailyDuaArabic = prefs.getString('widget_daily_dua_arabic') ??
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';
    final dailyDuaMeaning = prefs.getString('widget_daily_dua_meaning') ??
        'Allah\'ı hamd ile tesbih ederim.';
    await HomeWidget.saveWidgetData<String>('widget_daily_dua_title', dailyDua);
    await HomeWidget.saveWidgetData<String>(
        'widget_daily_dua_arabic', dailyDuaArabic);
    await HomeWidget.saveWidgetData<String>(
        'widget_daily_dua_meaning', dailyDuaMeaning);

    // Kompakt Vakit Sayacı Widget Verileri
    final compactCountdown = '$nextPrayerName • $countdown';
    await HomeWidget.saveWidgetData<String>(
        'widget_compact_countdown', compactCountdown);

    // Hızlı Zikirmatik Widget Verileri
    final zikrCount = prefs.getInt('zikirmatik_count') ?? 0;
    final zikrTarget = prefs.getInt('zikirmatik_target') ?? 33;
    await HomeWidget.saveWidgetData<int>('widget_zikr_count', zikrCount);
    await HomeWidget.saveWidgetData<int>('widget_zikr_target', zikrTarget);
    await HomeWidget.saveWidgetData<String>('widget_zikr_title', 'Sübhanallâh');

    // Tüm vakitler
    for (final prayer in allPrayers) {
      await HomeWidget.saveWidgetData<String>(
          'widget_${prayer.name.key}_time', _prayerService.formatTime(prayer.time));
    }
  }

  /// iOS ve Android native widget'larını yeniler.
  Future<void> _refreshNativeWidgets() async {
    final iosWidgets = [
      AppConstants.iOSVerseWidgetName,
      AppConstants.iOSPrayerWidgetName,
      AppConstants.iOSCountdownWidgetName,
      AppConstants.iOSHijriWidgetName,
      AppConstants.iOSSunWidgetName,
      AppConstants.iOSKazaWidgetName,
    ];

    for (final widgetName in iosWidgets) {
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    }

    await HomeWidget.updateWidget(
      name: AppConstants.androidWidgetName,
      androidName: AppConstants.androidWidgetName,
    );
  }

  int? _prayerNameToKind(PrayerName name) {
    switch (name) {
      case PrayerName.fajr:
        return 0;
      case PrayerName.sunrise:
        return 1;
      case PrayerName.dhuhr:
        return 2;
      case PrayerName.asr:
        return 3;
      case PrayerName.maghrib:
        return 4;
      case PrayerName.isha:
        return 5;
    }
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
