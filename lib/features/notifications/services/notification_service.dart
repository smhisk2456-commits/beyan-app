import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/services/prayer_time_service.dart';
import '../models/adhan_makam.dart';
import '../models/short_verse_notification.dart';
import '../../monetization/services/premium_service.dart';
import 'adhan_audio_player_service.dart';

/// Ezan, Vakit ve Günün Âyeti Yerel Bildirim Servisi
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  /// Belirli bir namaz vakti ve dile ait âyet metnini döner.
  static String getPrayerVerse(PrayerName prayer, String langCode) {
    return instance._getPrayerVerse(prayer, langCode);
  }

  /// Namaz vakti bildiriminin gövde metnini döner (vakit + âyet içerikli).
  static String getPrayerEnteredBodyText(PrayerName prayer, String timeStr, String langCode) {
    return instance._getPrayerEnteredBody(prayer, timeStr, langCode);
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // SharedPreferences Keys (Ezan & Vakit)
  static const String keyMasterEnabled = 'beyan_notif_master';
  static const String keyEarlyReminder = 'beyan_notif_early_15';
  static const String keySoundEnabled = 'beyan_notif_sound';
  static const String keyAdhanMakam = 'beyan_adhan_makam';
  static const String _keyPrefixPrayer = 'beyan_notif_prayer_';

  // SharedPreferences Keys (Günün Âyeti & Sure Bildirimi)
  static const String keyVerseNotifEnabled = 'beyan_notif_verse_enabled';
  static const String keyVerseNotifHour = 'beyan_notif_verse_hour';
  static const String keyVerseNotifMinute = 'beyan_notif_verse_minute';
  static const String keyVerseNotifFrequency = 'beyan_notif_verse_frequency';

  // Android Channels
  static const String channelId = 'beyan_prayer_channel';
  static const String channelName = 'Ezan ve Namaz Vakitleri';
  static const String channelDesc =
      'Namaz vakitlerinde ve vakit yaklaşırken gönderilen bildirimler.';

  static const String verseChannelId = 'beyan_verse_channel';
  static const String verseChannelName = 'Günün Âyeti ve Sure Bildirimleri';
  static const String verseChannelDesc =
      'Her gün ilham verici Kur\'an-ı Kerim ayetleri ve manevi hatırlatmalar.';

  /// Servisi başlatır ve saat dilimini ayarlar.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Timezone başlat
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        debugPrint('Timezone tespiti yapılamadı, Europe/Istanbul varsayılıyor: $e');
        try {
          tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
        } catch (_) {}
      }

      // Android Ayarları
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Ayarları (Açılışta izinleri talep et ve ön plandayken de banner/ses göster)
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        defaultPresentBanner: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) async {
          debugPrint('Bildirime tıklandı: ${response.payload}');
          final payload = response.payload;
          if (payload != null && (payload.startsWith('prayer_') || payload == 'test_adhan')) {
            final makam = await getSelectedMakam();
            if (makam != AdhanMakam.silent) {
              await AdhanAudioPlayerService.instance.togglePlayPreview(makam);
            }
          }
        },
      );

      // Android için Bildirim Kanalları oluştur (Her makam için özel sesli kanal)
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final channels = [
          const AndroidNotificationChannel(
            'beyan_prayer_channel_istanbul',
            'Ezan - İstanbul (Hicaz)',
            description: 'İstanbul makamında okunan ezan bildirimleri.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_istanbul'),
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            'beyan_prayer_channel_mecca',
            'Ezan - Mekke-i Mükerreme',
            description: 'Kâbe-i Muazzama makamında okunan ezan bildirimleri.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_mecca'),
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            'beyan_prayer_channel_medina',
            'Ezan - Medine-i Münevvere',
            description: 'Mescid-i Nebevî makamında okunan ezan bildirimleri.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_medina'),
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            'beyan_prayer_channel_tekbir',
            'Ezan - Kısa Sade Tekbir',
            description: 'Kısa ve nezaketli tekbir bildirimi.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('adhan_tekbir'),
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            'beyan_prayer_channel_bell',
            'Ezan - Standart Zil',
            description: 'Standart bildirim zili tonu.',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            'beyan_prayer_channel_silent',
            'Ezan - Sessiz',
            description: 'Yalnızca ekran bildirimi ve titreşim.',
            importance: Importance.low,
            playSound: false,
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
          const AndroidNotificationChannel(
            verseChannelId,
            verseChannelName,
            description: verseChannelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        ];

        for (final ch in channels) {
          await androidImplementation.createNotificationChannel(ch);
        }
      }

      _isInitialized = true;

      // Uygulama açılışında izinleri kontrol et ve gerekirse iste
      await requestPermissions();

      // Günün ayeti bildirimlerini arka planda kontrol et/planla
      await scheduleDailyVerseNotifications();
    } catch (e) {
      debugPrint('NotificationService başlatma hatası: $e');
    }
  }


  /// Cihaz bildirim izninin aktif olup olmadığını kontrol eder.
  Future<bool> hasPermission() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (Platform.isIOS) {
        final iosImplementation = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final options = await iosImplementation.checkPermissions();
          if (options != null) {
            final isAuthorized = options.isEnabled ||
                options.isAlertEnabled ||
                options.isSoundEnabled ||
                options.isBadgeEnabled ||
                options.isProvisionalEnabled;
            if (isAuthorized) return true;
          }
        }
      }

      final status = await Permission.notification.status;
      return status.isGranted || status.isProvisional || status.isLimited;
    } catch (e) {
      debugPrint('hasPermission kontrol hatası: $e');
      return true;
    }
  }

  /// Kullanıcıdan bildirim izni talep eder (iOS ve Android).
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (Platform.isIOS) {
        final iosImplementation = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          if (granted == true) return true;
        }
      }

      // Android platformu
      final status = await Permission.notification.request();
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
          await androidImplementation.requestExactAlarmsPermission();
        } catch (_) {}
      }

      return status.isGranted || status.isProvisional;
    } catch (e) {
      debugPrint('Bildirim izni isteme hatası: $e');
      return false;
    }
  }

  // ── Tercihler (SharedPreferences) ──────────────────────────

  Future<bool> isMasterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMasterEnabled) ?? true;
  }

  Future<void> setMasterEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyMasterEnabled, enabled);
    if (!enabled) {
      await cancelAllPrayerNotifications();
    } else {
      await scheduleUpcomingPrayers();
    }
  }

  Future<bool> isEarlyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyEarlyReminder) ?? true;
  }

  Future<void> setEarlyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyEarlyReminder, enabled);
    await scheduleUpcomingPrayers();
  }

  Future<bool> isPrayerEnabled(PrayerName prayer) async {
    final prefs = await SharedPreferences.getInstance();
    // Güneş varsayılan kapalı, diğer vakitler varsayılan açık
    final defaultVal = prayer != PrayerName.sunrise;
    return prefs.getBool('$_keyPrefixPrayer${prayer.name}') ?? defaultVal;
  }

  Future<void> setPrayerEnabled(PrayerName prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefixPrayer${prayer.name}', enabled);
    await scheduleUpcomingPrayers();
  }

  /// Seçili Ezan Makamını getirir (Varsayılan: İstanbul)
  /// Eğer PRO makam (Mekke/Medine) seçilmişse ve kullanıcı Premium değilse güvenle İstanbul'a döner.
  Future<AdhanMakam> getSelectedMakam() async {
    final prefs = await SharedPreferences.getInstance();
    final makamStr = prefs.getString(keyAdhanMakam);
    if (makamStr != null) {
      final makam = AdhanMakam.values.firstWhere(
        (m) => m.name == makamStr,
        orElse: () => AdhanMakam.istanbul,
      );
      if (makam.isPro && !PremiumService.instance.isPremium) {
        return AdhanMakam.istanbul;
      }
      return makam;
    }
    return AdhanMakam.istanbul;
  }

  /// Ezan Makamını değiştirir ve bildirimleri yeniden planlar.
  Future<void> setSelectedMakam(AdhanMakam makam) async {
    final prefs = await SharedPreferences.getInstance();
    if (makam.isPro && !PremiumService.instance.isPremium) {
      await prefs.setString(keyAdhanMakam, AdhanMakam.istanbul.name);
    } else {
      await prefs.setString(keyAdhanMakam, makam.name);
    }
    await scheduleUpcomingPrayers();
  }

  // ── Planlama (Scheduling) ──────────────────────────────────

  String _getAndroidChannelIdForMakam(AdhanMakam makam) {
    if (makam == AdhanMakam.silent) return 'beyan_prayer_channel_silent';
    final sound = makam.soundResourceName;
    if (sound != null) return 'beyan_prayer_channel_$sound';
    return 'beyan_prayer_channel_bell';
  }

  String _getPrayerEnteredTitle(PrayerName prayer, String langCode, [String? timeStr]) {
    final pName = prayer.localizedName(langCode);
    final timeSuffix = (timeStr != null && timeStr.isNotEmpty) ? ' ($timeStr)' : '';
    switch (langCode) {
      case 'en': return '🕌 $pName Time$timeSuffix • Come to Prayer';
      case 'ar': return '🕌 حان وقت $pName$timeSuffix • حي على الصلاة';
      case 'id': return '🕌 Waktu $pName$timeSuffix • Mari Sholat';
      case 'fr': return '🕌 Heure de $pName$timeSuffix';
      case 'ur': return '🕌 وقتِ نماز $pName$timeSuffix';
      case 'de': return '🕌 Gebetszeit: $pName$timeSuffix';
      case 'ru': return '🕌 Время намаза: $pName$timeSuffix';
      case 'tr':
      default: return '🕌 $pName Vakti Girdi$timeSuffix';
    }
  }

  String _getPrayerVerse(PrayerName prayer, String langCode) {
    switch (prayer) {
      case PrayerName.fajr:
        switch (langCode) {
          case 'en': return '"Recite the Quran at dawn; the dawn recitation is witnessed." (Al-Isra, 78)';
          case 'ar': return '«وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا» (الإسراء: ٧٨)';
          case 'id': return '"Dirikanlah shalat Subuh; sungguh ia disaksikan malaikat." (Al-Isra\', 78)';
          case 'fr': return '"accomplis la prière de l\'aube, car elle a des témoins." (Al-Isra, 78)';
          case 'ur': return '«فجر کا قرآن پڑھو، بے شک وہ فرشتوں کی حاضری کا وقت ہے۔» (الاسراء: 78)';
          case 'de': return '"Verrichte das Morgengebet; es wird von Engeln bezeugt." (Al-Isra, 78)';
          case 'ru': return '«Читай Коран на заре — его читают при свидетелях.» (Аль-Исра, 78)';
          case 'tr':
          default: return '«Sabah namazını kıl; sabah Kur\'an\'ı meleklerce şahitlidir.» (İsrâ, 78)';
        }
      case PrayerName.sunrise:
        switch (langCode) {
          case 'en': return '"Praise your Lord before sunrise and before sunset." (Ta-Ha, 130)';
          case 'ar': return '«وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا» (طه: ١٣٠)';
          case 'id': return '"Bertasbihlah memuji Tuhanmu sebelum terbit dan terbenam matahari." (Ta-Ha, 130)';
          case 'fr': return '"Célèbre les louanges de ton Seigneur avant le lever du soleil." (Ta-Ha, 130)';
          case 'ur': return '«طلوع اور غروبِ آفتاب سے پہلے اپنے رب کی تسبیح کرو۔» (طٰہٰ: 130)';
          case 'de': return '"Preise deinen Herrn vor Sonnenaufgang und Sonnenuntergang." (Ta-Ha, 130)';
          case 'ru': return '«Прославляй Господа перед восходом и перед закатом.» (Та Ха, 130)';
          case 'tr':
          default: return '«Güneş doğmadan ve batmadan önce Rabbini hamd ile tesbih et.» (Tâhâ, 130)';
        }
      case PrayerName.dhuhr:
        switch (langCode) {
          case 'en': return '"Establish prayer; indeed, good deeds erase misdeeds." (Hud, 114)';
          case 'ar': return '«وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ» (هود: ١١٤)';
          case 'id': return '"Dirikanlah shalat; sungguh kebaikan menghapus keburukan." (Hud, 114)';
          case 'fr': return '"Accomplis la prière; les bonnes actions dissipent les mauvaises." (Hud, 114)';
          case 'ur': return '«نماز قائم کرو، بے شک نیکیاں برائیوں کو مٹا دیتی ہیں۔» (ہود: 114)';
          case 'de': return '"Verrichte das Gebet; gute Taten tilgen die bösen." (Hud, 114)';
          case 'ru': return '«Совершай намаз; добрые деяния удаляют злодеяния.» (Худ, 114)';
          case 'tr':
          default: return '«Gündüzün iki طرفında namaz kıl; iyilikler kötülükleri giderir.» (Hûd, 114)'
              .replaceAll('طرفında', 'tarafında');
        }
      case PrayerName.asr:
        switch (langCode) {
          case 'en': return '"Guard the prayers, especially the middle prayer, and stand devoutly." (Al-Baqarah, 238)';
          case 'ar': return '«حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ» (البقرة: ٢٣٨)';
          case 'id': return '"Peliharalah shalat dan shalat Ashar; berdirilah dengan khusyuk." (Al-Baqarah, 238)';
          case 'fr': return '"Soyez assidus aux prières et à la prière médiane avec dévotion." (Al-Baqarah, 238)';
          case 'ur': return '«نمازوں اور خصوصاً عصر کی حفاظت کرو اور با ادب کھڑے رہو۔» (البقرہ: 238)';
          case 'de': return '"Haltet die Gebete und das mittlere Gebet demütig ein." (Al-Baqarah, 238)';
          case 'ru': return '«Оберегайте намазы и особенно средний намаз благоговейно.» (Аль-Бакара, 238)';
          case 'tr':
          default: return '«Namazlara ve ikindi namazına devam edin; gönülden Allah\'a durun.» (Bakara, 238)';
        }
      case PrayerName.maghrib:
        switch (langCode) {
          case 'en': return '"Glorify Allah when you reach the evening and the morning." (Ar-Rum, 17)';
          case 'ar': return '«فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ» (الروم: ١٧)';
          case 'id': return '"Bertasbihlah kepada Allah di waktu petang dan waktu subuh." (Ar-Rum, 17)';
          case 'fr': return '"Glorifiez donc Allah soir et matin !" (Ar-Rum, 17)';
          case 'ur': return '«پس اللہ کی تسبیح کرو جب شام ہو اور جب صبح ہو۔» (الروم: 17)';
          case 'de': return '"Preist Gott am Abend und am Morgen!" (Ar-Rum, 17)';
          case 'ru': return '«Славьте же Аллаха вечером и утром!» (Ар-Рум, 17)';
          case 'tr':
          default: return '«Akşama ulaştığınızda ve sabaha kavuştuğunuzda Allah\'ı tesbih edin.» (Rûm, 17)';
        }
      case PrayerName.isha:
        switch (langCode) {
          case 'en': return '"Prostrate to Him at night and exalt Him." (Al-Insan, 26)';
          case 'ar': return '«وَمِنَ اللَّيْلِ فَاسْجُدْ لَهُ وَسَبِّحْهُ لَيْلًا طَوِيلًا» (الإنسان: ٢٦)';
          case 'id': return '"Pada malam hari, bersujudlah dan bertasbihlah kepada-Nya." (Al-Insan, 26)';
          case 'fr': return '"Prosterne-toi devant Lui la nuit et glorifie-Le." (Al-Insan, 26)';
          case 'ur': return '«اور رات کے کچھ حصے میں اس کے حضور سجدہ اور تسبیح کرو۔» (الانسان: 26)';
          case 'de': return '"Wirf dich in der Nacht vor Ihm nieder und preise Ihn!" (Al-Insan, 26)';
          case 'ru': return '«Ночью падай ниц перед Ним и славь Его!» (Аль-Инсан, 26)';
          case 'tr':
          default: return '«Gecenin bir kısmında O\'na secde et ve O\'nu tesbih et.» (İnsân, 26)';
        }
    }
  }

  String _getPrayerEnteredBody(PrayerName prayer, String timeStr, String langCode) {
    final verse = _getPrayerVerse(prayer, langCode);
    return '📖 $verse';
  }

  String _getPrayerApproachingTitle(PrayerName prayer, String langCode) {
    final pName = prayer.localizedName(langCode);
    switch (langCode) {
      case 'en': return 'Prayer Approaching: $pName';
      case 'ar': return 'اقترب وقت الصلاة: $pName';
      case 'id': return 'Waktu Sholat Mendekat: $pName';
      case 'fr': return 'Prière imminente : $pName';
      case 'ur': return 'نماز کا وقت قریب ہے: $pName';
      case 'de': return 'Gebetszeit naht: $pName';
      case 'ru': return 'Скоро намаз: $pName';
      case 'tr':
      default: return 'Vakit Yaklaşıyor: $pName';
    }
  }

  String _getPrayerApproachingBody(PrayerName prayer, String timeStr, String langCode) {
    final pName = prayer.localizedName(langCode);
    switch (langCode) {
      case 'en':
        return '15 minutes left until $pName prayer ($timeStr).';
      case 'ar':
        return 'بقي 15 دقيقة على صلاة $pName ($timeStr).';
      case 'id':
        return '15 menit lagi menuju waktu sholat $pName ($timeStr).';
      case 'fr':
        return 'Il reste 15 minutes avant la prière de $pName ($timeStr).';
      case 'ur':
        return 'نماز $pName میں ۱۵ منٹ باقی ہیں ($timeStr)۔';
      case 'de':
        return 'Noch 15 Minuten bis zum $pName-Gebet ($timeStr).';
      case 'ru':
        return 'До намаза $pName осталось 15 минут ($timeStr).';
      case 'tr':
      default:
        return '$pName vaktine 15 dakika kaldı ($timeStr).';
    }
  }

  /// Önümüzdeki 3 günün namaz vakitlerini planlar (iOS 64 kota sınırına tam uyumlu).
  Future<void> scheduleUpcomingPrayers() async {
    final master = await isMasterEnabled();
    if (!master) {
      await cancelAllPrayerNotifications();
      return;
    }

    final earlyReminder = await isEarlyReminderEnabled();
    final currentMakam = await getSelectedMakam();
    final prayerService = PrayerTimeService();
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_app_language') ?? 'tr';

    // Yalnızca namaz bildirimlerini temizle (Ayet bildirimlerine dokunma!)
    await cancelAllPrayerNotifications();

    // 3 gün boyunca planla (Maksimum 36 bildirim, iOS 64 limitine kesin uyum)
    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      try {
        final daily = await prayerService.calculatePrayerTimes(date: targetDate);
        for (int i = 0; i < daily.prayers.length; i++) {
          final p = daily.prayers[i];
          final enabled = await isPrayerEnabled(p.name);
          if (!enabled) continue;

          // 1. Tam vakit bildirimi
          if (p.time.isAfter(now)) {
            final notifId = 1000 + (dayOffset * 10) + i;
            final scheduledTz = tz.TZDateTime.from(p.time, tz.local);
            final timeStr = prayerService.formatTime(p.time);

            // Makam ses detayı
            final isSilent = currentMakam == AdhanMakam.silent;
            final soundResource = currentMakam.soundResourceName;
            final targetChannelId = _getAndroidChannelIdForMakam(currentMakam);

            final notifTitle = _getPrayerEnteredTitle(p.name, langCode, timeStr);
            final notifBody = _getPrayerEnteredBody(p.name, timeStr, langCode);

            await _notifications.zonedSchedule(
              id: notifId,
              title: notifTitle,
              body: notifBody,
              scheduledDate: scheduledTz,
              payload: 'prayer_${p.name.name}',
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  targetChannelId,
                  channelName,
                  channelDescription: channelDesc,
                  importance: isSilent ? Importance.low : Importance.high,
                  priority: isSilent ? Priority.low : Priority.high,
                  playSound: !isSilent,
                  sound: soundResource != null
                      ? RawResourceAndroidNotificationSound(soundResource)
                      : null,
                  enableVibration: true,
                  styleInformation: BigTextStyleInformation(
                    notifBody,
                    contentTitle: notifTitle,
                  ),
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                  presentBadge: true,
                  presentSound: !isSilent,
                  sound: soundResource != null ? '$soundResource.caf' : null,
                  interruptionLevel: InterruptionLevel.timeSensitive,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }

          // 2. 15 dakika kala erken uyarı bildirimi
          if (earlyReminder) {
            final reminderTime = p.time.subtract(const Duration(minutes: 15));
            if (reminderTime.isAfter(now)) {
              final reminderId = 2000 + (dayOffset * 10) + i;
              final reminderTz = tz.TZDateTime.from(reminderTime, tz.local);
              final timeStr = prayerService.formatTime(p.time);

              await _notifications.zonedSchedule(
                id: reminderId,
                title: _getPrayerApproachingTitle(p.name, langCode),
                body: _getPrayerApproachingBody(p.name, timeStr, langCode),
                scheduledDate: reminderTz,
                payload: 'early_${p.name.name}',
                notificationDetails: const NotificationDetails(
                  android: AndroidNotificationDetails(
                    channelId,
                    channelName,
                    channelDescription: channelDesc,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(
                    presentAlert: true,
                    presentBanner: true,
                    presentList: true,
                    presentBadge: false,
                    presentSound: true,
                    interruptionLevel: InterruptionLevel.timeSensitive,
                  ),
                ),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Gün $dayOffset için namaz bildirimi planlanamadı: $e');
      }
    }
  }

  /// Yalnızca namaz ve erken uyarı bildirimlerini iptal eder (Ayet bildirimlerini korur).
  Future<void> cancelAllPrayerNotifications() async {
    for (int id = 1000; id <= 1999; id++) {
      try {
        await _notifications.cancel(id: id);
      } catch (_) {}
    }
    for (int id = 2000; id <= 2999; id++) {
      try {
        await _notifications.cancel(id: id);
      } catch (_) {}
    }
  }

  /// Anında test bildirimi gönderir (Kullanıcı testi için).
  Future<void> sendTestNotification({String? langCode}) async {
    final currentMakam = await getSelectedMakam();
    final isSilent = currentMakam == AdhanMakam.silent;
    final soundResource = currentMakam.soundResourceName;
    final prefs = await SharedPreferences.getInstance();
    final effectiveLang = langCode ?? prefs.getString('selected_app_language') ?? 'tr';

    final testTitle = effectiveLang == 'en'
        ? '🕌 Adhan Alert Test (${currentMakam.localizedTitle(effectiveLang)})'
        : (effectiveLang == 'ar'
            ? '🕌 اختبار تنبيه الأذان (${currentMakam.localizedTitle(effectiveLang)})'
            : '🕌 Ezan Bildirimi Testi (${currentMakam.title})');
    final sampleVerse = _getPrayerVerse(PrayerName.fajr, effectiveLang);
    final testBody = '📖 $sampleVerse';

    try {
      final targetChannelId = _getAndroidChannelIdForMakam(currentMakam);
      await _notifications.show(
        id: 999,
        title: testTitle,
        body: testBody,
        payload: 'test_adhan',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            targetChannelId,
            channelName,
            channelDescription: channelDesc,
            importance: isSilent ? Importance.low : Importance.high,
            priority: isSilent ? Priority.low : Priority.high,
            playSound: !isSilent,
            sound: soundResource != null
                ? RawResourceAndroidNotificationSound(soundResource)
                : null,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(
              testBody,
              contentTitle: testTitle,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentBadge: true,
            presentSound: !isSilent,
            sound: soundResource != null ? '$soundResource.caf' : null,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Özel sesli test bildirimi hatası, varsayılan sistem sesiyle deneniyor: $e');
      try {
        await _notifications.show(
          id: 999,
          title: testTitle,
          body: effectiveLang == 'en'
              ? 'Notification system is working properly! (Default alert sound).'
              : (effectiveLang == 'ar'
                  ? 'نظام الإشعارات يعمل بنجاح! (صوت التنبيه الافتراضي).'
                  : 'Bildirim sistemi sorunsuz çalışıyor! (Standart bildirim sesi).'),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDesc,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBanner: true,
              presentList: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
        );
      } catch (fallbackError) {
        debugPrint('Yedek test bildirimi hatası: $fallbackError');
        rethrow;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GÜNÜN ÂYETİ VE SURE BİLDİRİMLERİ (Preferences & Scheduling)
  // ══════════════════════════════════════════════════════════════

  Future<bool> isVerseNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyVerseNotifEnabled) ?? true;
  }

  Future<void> setVerseNotifEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyVerseNotifEnabled, enabled);
    if (!enabled) {
      await cancelAllVerseNotifications();
    } else {
      await scheduleDailyVerseNotifications(force: true);
    }
  }

  Future<int> getVerseNotifHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyVerseNotifHour) ?? 9; // Varsayılan 09:00
  }

  Future<int> getVerseNotifMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyVerseNotifMinute) ?? 0;
  }

  Future<void> setVerseNotifTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyVerseNotifHour, hour);
    await prefs.setInt(keyVerseNotifMinute, minute);
    await scheduleDailyVerseNotifications(force: true);
  }

  Future<String> getVerseNotifFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyVerseNotifFrequency) ?? 'daily';
  }

  Future<void> setVerseNotifFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyVerseNotifFrequency, frequency);
    await scheduleDailyVerseNotifications(force: true);
  }

  /// Önümüzdeki 14 günün günlük âyet bildirimlerini planlar.
  Future<void> scheduleDailyVerseNotifications({bool force = false}) async {
    final enabled = await isVerseNotifEnabled();
    if (!enabled) {
      await cancelAllVerseNotifications();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastScheduledEpoch = prefs.getInt('beyan_last_verse_scheduled_epoch') ?? 0;
    final lastScheduled = DateTime.fromMillisecondsSinceEpoch(lastScheduledEpoch);

    // Son 18 saat içinde zaten planlandıysa ve zorlama (force) yoksa tekrar baştan planlayıp geçmişi tüketme
    if (!force && lastScheduledEpoch > 0 && now.difference(lastScheduled).inHours < 18) {
      return;
    }

    await cancelAllVerseNotifications();
    await prefs.setInt('beyan_last_verse_scheduled_epoch', now.millisecondsSinceEpoch);

    final hour = await getVerseNotifHour();
    final minute = await getVerseNotifMinute();
    final freq = await getVerseNotifFrequency();
    final langCode = prefs.getString('selected_app_language') ?? 'tr';
    
    // Mükerrerliği önleyen ve son 60 bildirimi hafızada tutan eşsiz ayet havuzu
    final batchSize = freq == 'morning_evening'
        ? 28
        : (freq == 'hourly_2' ? 24 : (freq == 'hourly_1' ? 18 : 14));
    final batch = await ShortVerseNotification.getNonRepeatingBatch(batchSize);

    // ── Saatte 2 Kez (30 dakikada bir, 09:00 - 22:00 arası) ─────────────────
    if (freq == 'hourly_2') {
      int notifCount = 0;
      const int maxNotifs = 24; // iOS 64 limitine kesin uyum (36 namaz + 24 ayet = 60 <= 64)
      DateTime pointer = DateTime(now.year, now.month, now.day, now.hour, (now.minute >= 30 ? 30 : 0))
          .add(const Duration(minutes: 30));

      while (notifCount < maxNotifs) {
        if (pointer.hour >= 9 && pointer.hour <= 22) {
          if (pointer.isAfter(now)) {
            final notifId = 5000 + notifCount;
            final verse = batch[notifCount % batch.length];
            final scheduledTz = tz.TZDateTime.from(pointer, tz.local);

            await _notifications.zonedSchedule(
              id: notifId,
              title: verse.localizedTitle(langCode),
              body: verse.localizedText(langCode),
              scheduledDate: scheduledTz,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  verseChannelId,
                  verseChannelName,
                  channelDescription: verseChannelDesc,
                  importance: Importance.high,
                  priority: Priority.high,
                  playSound: true,
                  enableVibration: true,
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                  presentBadge: true,
                  presentSound: true,
                  interruptionLevel: InterruptionLevel.timeSensitive,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
            notifCount++;
          }
        }
        pointer = pointer.add(const Duration(minutes: 30));
        if (pointer.difference(now).inDays > 5) break;
      }
      return;
    }

    // ── Her Saat Başı (09:00 - 22:00 arası) ──────────────────────────────────
    if (freq == 'hourly_1') {
      int notifCount = 0;
      const int maxNotifs = 18;
      DateTime pointer = DateTime(now.year, now.month, now.day, now.hour, 0)
          .add(const Duration(hours: 1));

      while (notifCount < maxNotifs) {
        if (pointer.hour >= 9 && pointer.hour <= 22) {
          if (pointer.isAfter(now)) {
            final notifId = 5000 + notifCount;
            final verse = batch[notifCount % batch.length];
            final scheduledTz = tz.TZDateTime.from(pointer, tz.local);

            await _notifications.zonedSchedule(
              id: notifId,
              title: verse.localizedTitle(langCode),
              body: verse.localizedText(langCode),
              scheduledDate: scheduledTz,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  verseChannelId,
                  verseChannelName,
                  channelDescription: verseChannelDesc,
                  importance: Importance.high,
                  priority: Priority.high,
                  playSound: true,
                  enableVibration: true,
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                  presentBadge: true,
                  presentSound: true,
                  interruptionLevel: InterruptionLevel.timeSensitive,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
            notifCount++;
          }
        }
        pointer = pointer.add(const Duration(hours: 1));
        if (pointer.difference(now).inDays > 5) break;
      }
      return;
    }

    // ── Günlük veya Sabah & Akşam Planlaması ─────────────────────────────────
    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final verseIndex = (freq == 'morning_evening' ? dayOffset * 2 : dayOffset) % batch.length;
      final verse = batch[verseIndex];

      // Ana bildirim vakti
      final scheduledTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        hour,
        minute,
      );

      if (scheduledTime.isAfter(now)) {
        final notifId = 5000 + dayOffset;
        final scheduledTz = tz.TZDateTime.from(scheduledTime, tz.local);

        await _notifications.zonedSchedule(
          id: notifId,
          title: verse.localizedTitle(langCode),
          body: verse.localizedText(langCode),
          scheduledDate: scheduledTz,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              verseChannelId,
              verseChannelName,
              channelDescription: verseChannelDesc,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBanner: true,
              presentList: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      // Sabah & Akşam seçeneği (19:30 akşam tefekkürü)
      if (freq == 'morning_evening') {
        final eveningTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          19,
          30,
        );
        if (eveningTime.isAfter(now)) {
          final notifId = 5100 + dayOffset;
          final eveningVerseIndex = (dayOffset * 2 + 1) % batch.length;
          final eveningVerse = batch[eveningVerseIndex];
          final scheduledTz = tz.TZDateTime.from(eveningTime, tz.local);

          await _notifications.zonedSchedule(
            id: notifId,
            title: eveningVerse.localizedTitle(langCode, isEvening: true),
            body: eveningVerse.localizedText(langCode),
            scheduledDate: scheduledTz,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                verseChannelId,
                verseChannelName,
                channelDescription: verseChannelDesc,
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBanner: true,
                presentList: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
  }

  /// Yalnızca zamanlanmış ayet bildirimlerini iptal eder.
  Future<void> cancelAllVerseNotifications() async {
    for (int id = 5000; id <= 5999; id++) {
      try {
        await _notifications.cancel(id: id);
      } catch (_) {}
    }
  }

  static int _testVerseCounter = 0;

  /// Kullanıcının ayet bildirimini test etmesi için anında gönderir (Her tıklamada sırayla ve farklı kısa ayet).
  Future<void> sendTestVerseNotification({String? langCode}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveLang = langCode ?? prefs.getString('selected_app_language') ?? 'tr';
    final verse = await ShortVerseNotification.getNextRotatingVerse();
    final notifId = 5900 + (_testVerseCounter++ % 80);
    try {
      await _notifications.cancel(id: notifId);
      await _notifications.show(
        id: notifId,
        title: verse.localizedTitle(effectiveLang),
        body: verse.localizedText(effectiveLang),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            verseChannelId,
            verseChannelName,
            channelDescription: verseChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Ayet test bildirimi hatası: $e');
    }
  }
}

