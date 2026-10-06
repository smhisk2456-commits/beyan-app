/// Uygulama genelinde kullanılan sabit değerler.
abstract class AppConstants {
  // ── App Info ─────────────────────────────────────────────────
  static const String appName = 'Beyân';
  static const String appVersion = '1.0.0';

  // ── Default Location (İstanbul) ──────────────────────────────
  static const double defaultLatitude = 41.0082;
  static const double defaultLongitude = 28.9784;
  static const String defaultCityName = 'İstanbul';

  // ── Database ─────────────────────────────────────────────────
  static const String databaseName = 'quran_v3.db';
  static const String databaseAssetPath = 'assets/database/quran.db';

  // ── SharedPreferences Keys ───────────────────────────────────
  static const String prefNextPrayerName = 'next_prayer_name';
  static const String prefNextPrayerTime = 'next_prayer_time';
  static const String prefDailyAyah = 'daily_ayah_arabic';
  static const String prefDailyAyahTranslation = 'daily_ayah_translation';
  static const String prefDailyAyahReference = 'daily_ayah_reference';

  // ── HomeWidget Keys ──────────────────────────────────────────
  static const String widgetNextPrayer = 'widget_next_prayer';
  static const String widgetNextPrayerTime = 'widget_next_prayer_time';
  static const String widgetCountdown = 'widget_countdown';
  static const String widgetDailyAyah = 'widget_daily_ayah';
  static const String widgetDailyAyahRef = 'widget_daily_ayah_ref';

  // ── Widget Names ─────────────────────────────────────────────
  static const String iOSWidgetName = 'BeyanPrayerWidget';
  static const String iOSPrayerWidgetName = 'BeyanPrayerWidget';
  static const String iOSVerseWidgetName = 'BeyanVerseWidget';
  static const String androidWidgetName = 'IslamicAppWidget';

  // ── WorkManager ──────────────────────────────────────────────
  static const String backgroundTaskName = 'islamicAppWidgetUpdate';
  static const String backgroundTaskTag = 'widget_update';

  // ── Prayer Names (Türkçe) ─────────────────────────────────────
  static const Map<String, String> prayerNamesTurkish = {
    'fajr': 'İmsak',
    'sunrise': 'Güneş',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
  };
}
