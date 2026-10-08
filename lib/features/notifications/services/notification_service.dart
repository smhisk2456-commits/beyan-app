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

/// Ezan, Vakit ve Günün Âyeti Yerel Bildirim Servisi
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

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
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Bildirime tıklandı: ${response.payload}');
        },
      );

      // Android için Bildirim Kanalı oluştur
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            verseChannelId,
            verseChannelName,
            description: verseChannelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
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
  Future<AdhanMakam> getSelectedMakam() async {
    final prefs = await SharedPreferences.getInstance();
    final makamStr = prefs.getString(keyAdhanMakam);
    if (makamStr != null) {
      return AdhanMakam.values.firstWhere(
        (m) => m.name == makamStr,
        orElse: () => AdhanMakam.istanbul,
      );
    }
    return AdhanMakam.istanbul;
  }

  /// Ezan Makamını değiştirir ve bildirimleri yeniden planlar.
  Future<void> setSelectedMakam(AdhanMakam makam) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAdhanMakam, makam.name);
    await scheduleUpcomingPrayers();
  }

  // ── Planlama (Scheduling) ──────────────────────────────────

  /// Önümüzdeki 7 günün namaz vakitlerini planlar.
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

    // Önceki zamanlanmış bildirimleri temizle
    await cancelAllPrayerNotifications();

    // 7 gün boyunca planla
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
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

            await _notifications.zonedSchedule(
              id: notifId,
              title: 'Vakit Girdi: ${p.name.turkish}',
              body: '${p.name.turkish} namazı vakti girdi ($timeStr). Haydin namaza!',
              scheduledDate: scheduledTz,
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  channelId,
                  channelName,
                  channelDescription: channelDesc,
                  importance: isSilent ? Importance.low : Importance.high,
                  priority: isSilent ? Priority.low : Priority.high,
                  playSound: !isSilent,
                  sound: soundResource != null
                      ? RawResourceAndroidNotificationSound(soundResource)
                      : null,
                  enableVibration: true,
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                  presentBadge: true,
                  presentSound: !isSilent,
                  sound: soundResource != null ? '$soundResource.mp3' : null,
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
                title: 'Vakit Yaklaşıyor: ${p.name.turkish}',
                body: '${p.name.turkish} vaktine 15 dakika kaldı ($timeStr).',
                scheduledDate: reminderTz,
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

  /// Tüm namaz ve erken uyarı bildirimlerini iptal eder.
  Future<void> cancelAllPrayerNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Bildirimler iptal edilirken hata: $e');
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
        ? 'Beyân Adhan Alert Test 🔔'
        : (effectiveLang == 'ar' ? 'اختبار تنبيه أذان بيان 🔔' : 'Beyân Ezan Bildirimi Testi 🔔');
    final testBody = effectiveLang == 'en'
        ? 'Notification system is working properly! (${currentMakam.localizedTitle(effectiveLang)} selected).'
        : (effectiveLang == 'ar'
            ? 'نظام الإشعارات يعمل بنجاح! (${currentMakam.localizedTitle(effectiveLang)} محدد).'
            : 'Bildirim sistemi sorunsuz çalışıyor! (${currentMakam.title} seçili).');

    try {
      await _notifications.show(
        id: 999,
        title: testTitle,
        body: testBody,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: isSilent ? Importance.low : Importance.high,
            priority: isSilent ? Priority.low : Priority.high,
            playSound: !isSilent,
            sound: soundResource != null
                ? RawResourceAndroidNotificationSound(soundResource)
                : null,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentBadge: true,
            presentSound: !isSilent,
            sound: soundResource != null ? '$soundResource.mp3' : null,
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
      await scheduleDailyVerseNotifications();
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
    await scheduleDailyVerseNotifications();
  }

  Future<String> getVerseNotifFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyVerseNotifFrequency) ?? 'daily';
  }

  Future<void> setVerseNotifFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyVerseNotifFrequency, frequency);
    await scheduleDailyVerseNotifications();
  }

  /// Önümüzdeki 14 günün günlük âyet bildirimlerini planlar.
  Future<void> scheduleDailyVerseNotifications() async {
    final enabled = await isVerseNotifEnabled();
    if (!enabled) {
      await cancelAllVerseNotifications();
      return;
    }

    await cancelAllVerseNotifications();
    final hour = await getVerseNotifHour();
    final minute = await getVerseNotifMinute();
    final freq = await getVerseNotifFrequency();
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_app_language') ?? 'tr';
    final seedOffset = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % ShortVerseNotification.pool.length;

    // ── Saatte 2 Kez (30 dakikada bir, 09:00 - 22:00 arası) ─────────────────
    if (freq == 'hourly_2') {
      int notifCount = 0;
      const int maxNotifs = 32; // iOS 64 limitine takılmamak için güvenli kota
      DateTime pointer = DateTime(now.year, now.month, now.day, now.hour, (now.minute >= 30 ? 30 : 0))
          .add(const Duration(minutes: 30));

      while (notifCount < maxNotifs) {
        if (pointer.hour >= 9 && pointer.hour <= 22) {
          if (pointer.isAfter(now)) {
            final notifId = 5000 + notifCount;
            final verse = ShortVerseNotification.getByIndex(seedOffset + notifCount);
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
      const int maxNotifs = 28;
      DateTime pointer = DateTime(now.year, now.month, now.day, now.hour, 0)
          .add(const Duration(hours: 1));

      while (notifCount < maxNotifs) {
        if (pointer.hour >= 9 && pointer.hour <= 22) {
          if (pointer.isAfter(now)) {
            final notifId = 5000 + notifCount;
            final verse = ShortVerseNotification.getByIndex(seedOffset + notifCount);
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
      final verse = ShortVerseNotification.getByIndex(seedOffset + dayOffset * 2);

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
          final eveningVerse = ShortVerseNotification.getByIndex(seedOffset + dayOffset * 2 + 1);
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
    for (int id = 5000; id <= 5250; id++) {
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

