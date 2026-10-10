import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
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
      const d = Duration(hours: 2, minutes: 35, seconds: 10);
      final formatted = service.formatCountdown(d);
      expect(formatted, contains('s'));
      expect(formatted, contains('dk'));
    });

    test('formatCountdown saat yoksa MM:SS döner', () {
      const d = Duration(minutes: 45, seconds: 30);
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

  // ── Diyanet Kalibrasyon ve Metot Testleri ───────────────────────
  group('Diyanet Calculation Settings', () {
    test('Diyanet yöntemi Türkiye takvimine uygun olarak Asr-ı Evvel (Madhab.shafi) kullanır', () {
      final params = PrayerCalculationMethod.diyanet.getAdhanParameters();
      expect(params.madhab, equals(Madhab.shafi));
      expect(params.methodAdjustments.asr, equals(5));
      expect(params.methodAdjustments.maghrib, equals(8));
      expect(params.methodAdjustments.isha, equals(2));
    });
  });

  // ── Namaz Rekat ve Rehber Bilgisi Testleri ───────────────────────
  group('Namaz Rekatları ve Rehber Bilgisi', () {
    test('Tüm vakitlerin rekat sayıları İslam fıkhına göre eksiksiz olmalı', () {
      expect(PrayerName.fajr.rakatTotal, equals(4)); // 2 Sünnet + 2 Farz
      expect(PrayerName.sunrise.rakatTotal, equals(0)); // Kerâhet vakti
      expect(PrayerName.dhuhr.rakatTotal, equals(10)); // 4 İlk Sünnet + 4 Farz + 2 Son Sünnet
      expect(PrayerName.asr.rakatTotal, equals(8)); // 4 Sünnet + 4 Farz
      expect(PrayerName.maghrib.rakatTotal, equals(5)); // 3 Farz + 2 Sünnet
      expect(PrayerName.isha.rakatTotal, equals(13)); // 4 İlk Sünnet + 4 Farz + 2 Son Sünnet + 3 Vitir
    });

    test('Yatsı namazı detaylı rekat açılımı doğru ve kesilmemiş olmalı', () {
      final tr = PrayerName.isha.localizedRakat('tr');
      expect(tr, contains('13 Rekat'));
      expect(tr, contains('4 Sünnet + 4 Farz + 2 Sünnet + 3 Vitir'));

      final en = PrayerName.isha.localizedRakat('en');
      expect(en, contains('13 Rakats'));
      expect(en, contains('4 Sunnah + 4 Fard + 2 Sunnah + 3 Witr'));

      final ar = PrayerName.isha.localizedRakat('ar');
      expect(ar, contains('١٣ ركعة'));
      expect(ar, contains('وتر'));
    });

    test('Sabah, Öğle, İkindi ve Akşam rekat detayları Türkçe doğru dönmeli', () {
      expect(PrayerName.fajr.localizedRakat('tr'), contains('2 Sünnet + 2 Farz'));
      expect(PrayerName.dhuhr.localizedRakat('tr'), contains('4 Sünnet + 4 Farz + 2 Sünnet'));
      expect(PrayerName.asr.localizedRakat('tr'), contains('4 Sünnet + 4 Farz'));
      expect(PrayerName.maghrib.localizedRakat('tr'), contains('3 Farz + 2 Sünnet'));
    });
  });
}

