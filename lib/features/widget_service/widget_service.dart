import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../prayer_times/models/prayer_time_model.dart';
import '../prayer_times/services/prayer_time_service.dart';
import '../quran/repositories/quran_repository.dart';
import '../notifications/models/short_verse_notification.dart';
import 'screens/widget_center_screen.dart';

import '../../core/localization/app_strings.dart';

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
  static const String _appGroupId = 'group.com.smhisk60.beyan';

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
      await HomeWidget.setAppGroupId(_appGroupId);
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('selected_app_language') ?? 'tr';
      final lang = AppLanguage.fromCode(langCode);

      // 1. Namaz Vakitleri
      final location = await _prayerService.getCurrentLocation();
      final daily = await _prayerService.calculatePrayerTimes(location: location);
      final next = daily.nextPrayerEntry;
      final countdown = _prayerService.formatCountdown(daily.timeUntilNextPrayer, lang: lang);
      final nextPrayerName = next?.name.localizedName(langCode) ?? '--';

      // 2. Seçili kategoriye ve görünüme göre duygusal ayet havuzu oluştur
      final quoteCat = prefs.getString('widget_quote_category') ?? 'all';
      final verseView = prefs.getString('widget_verse_view') ?? 'meal_only';
      final activeCat = prefs.getString('widget_active_category') ?? 'quotes';

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
        final categoryList = kWidgetCategoryQuotes[quoteCat] ?? kWidgetCategoryQuotes['all']!;
        for (final q in categoryList) {
          widgetVerses.add({
            'ref': q.localizedReference(langCode),
            'text': q.formatForViewMode(verseView, langCode),
          });
        }
        // 'all' seçiliyse ve केवल meal görünümündeyse ek kısa ayetlerle zenginleştir
        if (quoteCat == 'all' && langCode == 'tr' && verseView == 'meal_only') {
          final dbVerses = await _quranRepo.getRandomWidgetVerses(limit: 40);
          widgetVerses.addAll(dbVerses);
        }
      }

      // Kullanıcının son uyguladığı ayeti listenin en başına ekle
      final appliedRef = prefs.getString('widget_applied_verse_ref') ?? '';
      final appliedText = prefs.getString('widget_applied_verse_text') ?? '';
      if (appliedRef.isNotEmpty && appliedText.isNotEmpty) {
        widgetVerses.removeWhere((item) => item['ref'] == appliedRef);
        widgetVerses.insert(0, {
          'ref': appliedRef,
          'text': appliedText,
        });
      }

      final versesJson = jsonEncode(widgetVerses);

      // Kullanıcının seçtiği güncelleme aralığını al (varsayılan 5 dk, 3-15 dk arası güvenli sınır)
      final interval = (prefs.getInt('widget_update_interval') ?? 5).clamp(3, 15);

      // 3. home_widget ortak alanına yaz
      await _writeToHomeWidget(
        langCode: langCode,
        nextPrayerName: nextPrayerName,
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
    required String langCode,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String countdown,
    required List<PrayerEntry> allPrayers,
    required String versesJson,
    required int interval,
  }) async {
    await HomeWidget.saveWidgetData<String>('widget_app_language', langCode);
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetNextPrayer, nextPrayerName);
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetNextPrayerTime, nextPrayerTime);
    await HomeWidget.saveWidgetData<String>(AppConstants.widgetCountdown, countdown);
    
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
    await HomeWidget.saveWidgetData<String>('widget_refresh_interval', refreshInterval);

    // Live Activity & Dynamic Island tetiklenme süresi (dk)
    final triggerMinutes = prefs.getInt('live_activity_trigger_minutes') ?? 45;
    await HomeWidget.saveWidgetData<int>('live_activity_trigger_minutes', triggerMinutes);

    // Kilit ekranına uygulanan / sabitlenen özel ayet durumu
    final isPinned = prefs.getBool('widget_is_pinned') ?? false;
    var appliedRef = prefs.getString('widget_applied_verse_ref') ?? '';
    var appliedText = prefs.getString('widget_applied_verse_text') ?? '';
    final appliedSurah = prefs.getInt('widget_applied_verse_surah') ?? 0;
    final appliedVerseNum = prefs.getInt('widget_applied_verse_number') ?? 0;
    final applyNonce = prefs.getInt('widget_apply_nonce') ?? 0;

    if (appliedRef.isNotEmpty && langCode != 'tr' && appliedSurah > 0 && appliedVerseNum > 0) {
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
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_ref', appliedRef);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_text', appliedText);
    await HomeWidget.saveWidgetData<int>('widget_applied_verse_surah', appliedSurah);
    await HomeWidget.saveWidgetData<int>('widget_applied_verse_number', appliedVerseNum);
    await HomeWidget.saveWidgetData<int>('widget_apply_nonce', applyNonce);

    // Tüm vakitler
    for (final prayer in allPrayers) {
      await HomeWidget.saveWidgetData<String>('widget_${prayer.name.key}_time', _prayerService.formatTime(prayer.time));
    }
  }

  /// iOS ve Android native widget'larını yeniler.
  Future<void> _refreshNativeWidgets() async {
    // iOS WidgetKit Timeline'larını geçersiz kılıp yenile
    final iosWidgets = [
      AppConstants.iOSVerseWidgetName,
      AppConstants.iOSPrayerWidgetName,
      AppConstants.iOSCountdownWidgetName,
      AppConstants.iOSHijriWidgetName,
      AppConstants.iOSSunWidgetName,
    ];

    for (final widgetName in iosWidgets) {
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    }

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
