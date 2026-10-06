import 'dart:async';
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

/// Ezan ve Namaz Vakti Yerel Bildirim Servisi
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // SharedPreferences Keys
  static const String keyMasterEnabled = 'beyan_notif_master';
  static const String keyEarlyReminder = 'beyan_notif_early_15';
  static const String keySoundEnabled = 'beyan_notif_sound';
  static const String keyAdhanMakam = 'beyan_adhan_makam';
  static const String _keyPrefixPrayer = 'beyan_notif_prayer_';

  // Android Channel
  static const String channelId = 'beyan_prayer_channel';
  static const String channelName = 'Ezan ve Namaz Vakitleri';
  static const String channelDesc =
      'Namaz vakitlerinde ve vakit yaklaşırken gönderilen bildirimler.';

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
      }

      _isInitialized = true;

      // Uygulama açılışında izinleri kontrol et ve gerekirse iste
      await requestPermissions();
    } catch (e) {
      debugPrint('NotificationService başlatma hatası: $e');
    }
  }

  /// Cihaz bildirim izninin aktif olup olmadığını kontrol eder.
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted || status.isProvisional;
    } catch (e) {
      debugPrint('hasPermission kontrol hatası: $e');
      return true;
    }
  }

  /// Kullanıcıdan bildirim izni talep eder (iOS ve Android).
  Future<bool> requestPermissions() async {
    try {
      // 1. Genel bildirim izni (Android 13+ & iOS)
      final status = await Permission.notification.request();

      // 2. Android platformuna özel bildirim & tam zamanlı alarm izni
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (_) {}
      }

      // 3. iOS platformuna özel bildirim izinleri
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? status.isGranted;
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
  Future<void> sendTestNotification() async {
    try {
      final currentMakam = await getSelectedMakam();
      final isSilent = currentMakam == AdhanMakam.silent;
      final soundResource = currentMakam.soundResourceName;

      await _notifications.show(
        id: 999,
        title: 'Beyân Ezan Bildirimi Testi 🔔',
        body: 'Bildirim sistemi sorunsuz çalışıyor! (${currentMakam.title} seçili).',
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
            sound: soundResource != null ? '$soundResource.caf' : null,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Test bildirimi hatası: $e');
    }
  }
}
