import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/prayer_times/services/prayer_time_service.dart';

/// Phase 3 – Namaz Vakitleri Servis Testleri
void main() {
  // ── PrayerName Enum Testleri ────────────────────────────────
  group('PrayerName', () {
    test('adhan Prayer enum\'undan doğru dönüştürür', () {
      expect(PrayerName.fromAdhan(Prayer.fajr),    equals(PrayerName.fajr));
      expect(PrayerName.fromAdhan(Prayer.sunrise), equals(PrayerName.sunrise));
      expect(PrayerName.fromAdhan(Prayer.dhuhr),   equals(PrayerName.dhuhr));
      expect(PrayerName.fromAdhan(Prayer.asr),     equals(PrayerName.asr));
      expect(PrayerName.fromAdhan(Prayer.maghrib), equals(PrayerName.maghrib));
      expect(PrayerName.fromAdhan(Prayer.isha),    equals(PrayerName.isha));
    });

    test('Türkçe adlar doğru', () {
      expect(PrayerName.fajr.turkish,    equals('İmsak'));
      expect(PrayerName.dhuhr.turkish,   equals('Öğle'));
      expect(PrayerName.asr.turkish,     equals('İkindi'));
      expect(PrayerName.maghrib.turkish, equals('Akşam'));
      expect(PrayerName.isha.turkish,    equals('Yatsı'));
    });

    test('Arapça adlar boş değil', () {
      for (final name in PrayerName.values) {
        expect(name.arabic, isNotEmpty);
      }
    });
  });

  // ── PrayerTimeService Testleri ──────────────────────────────
  group('PrayerTimeService', () {
    late PrayerTimeService service;

    setUp(() {
      service = PrayerTimeService();
    });

    test('İstanbul için bugünün namaz vakitlerini hesaplar', () async {
      const istanbul = LocationData(
        latitude: 41.0082,
        longitude: 28.9784,
        cityName: 'İstanbul',
        isFromGPS: false,
      );

      final daily = await service.calculatePrayerTimes(location: istanbul);

      // 6 vakit olmalı
      expect(daily.prayers.length, equals(6));
      // Tarih bugün olmalı
      expect(daily.date.day, equals(DateTime.now().day));
      // Konum adı doğru olmalı
      expect(daily.locationName, equals('İstanbul'));
    });

    test('İmsak güneşten önce gelir', () async {
      const istanbul = LocationData(
        latitude: 41.0082,
        longitude: 28.9784,
        cityName: 'İstanbul',
        isFromGPS: false,
      );

      final daily = await service.calculatePrayerTimes(location: istanbul);

      expect(daily.fajr.time.isBefore(daily.sunrise.time), isTrue);
      expect(daily.sunrise.time.isBefore(daily.dhuhr.time), isTrue);
      expect(daily.dhuhr.time.isBefore(daily.asr.time), isTrue);
      expect(daily.asr.time.isBefore(daily.maghrib.time), isTrue);
      expect(daily.maghrib.time.isBefore(daily.isha.time), isTrue);
    });

    test('Vakitler sıralı ve mantıklı saatlerde', () async {
      const istanbul = LocationData(
        latitude: 41.0082,
        longitude: 28.9784,
        cityName: 'İstanbul',
        isFromGPS: false,
      );

      final daily = await service.calculatePrayerTimes(location: istanbul);

      // İmsak sabah 3-7 arasında olmalı
      expect(daily.fajr.time.hour, greaterThanOrEqualTo(3));
      expect(daily.fajr.time.hour, lessThanOrEqualTo(7));

      // Öğle 11-14 arasında olmalı
      expect(daily.dhuhr.time.hour, greaterThanOrEqualTo(11));
      expect(daily.dhuhr.time.hour, lessThanOrEqualTo(14));

      // Yatsı akşam 6'dan sonra olmalı
      expect(daily.isha.time.hour, greaterThanOrEqualTo(18));
    });

    test('formatCountdown saat varsa saat gösterir', () {
      final d = const Duration(hours: 2, minutes: 35, seconds: 10);
      final formatted = service.formatCountdown(d);
      expect(formatted, contains('s'));
      expect(formatted, contains('dk'));
    });

    test('formatCountdown saat yoksa MM:SS döner', () {
      final d = const Duration(minutes: 45, seconds: 30);
      final formatted = service.formatCountdown(d);
      expect(formatted, equals('45:30'));
    });

    test('formatCountdown sıfır duration için -- döner', () {
      final formatted = service.formatCountdown(Duration.zero);
      expect(formatted, equals('--:--'));
    });

    test('progress 0.0-1.0 arasında kalır', () async {
      const istanbul = LocationData(
        latitude: 41.0082,
        longitude: 28.9784,
        cityName: 'İstanbul',
        isFromGPS: false,
      );

      final daily = await service.calculatePrayerTimes(location: istanbul);
      final progress = service.getProgressToNextPrayer(daily);

      expect(progress, greaterThanOrEqualTo(0.0));
      expect(progress, lessThanOrEqualTo(1.0));
    });
  });

  // ── LocationData Testleri ────────────────────────────────────
  group('LocationData', () {
    test('GPS ve varsayılan konum ayrımı doğru', () {
      const gps = LocationData(
        latitude: 39.9,
        longitude: 32.8,
        cityName: 'Ankara',
        isFromGPS: true,
      );

      const fallback = LocationData(
        latitude: 41.0082,
        longitude: 28.9784,
        cityName: 'İstanbul',
        isFromGPS: false,
      );

      expect(gps.isFromGPS, isTrue);
      expect(fallback.isFromGPS, isFalse);
    });
  });
}
