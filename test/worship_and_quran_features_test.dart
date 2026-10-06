import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/zikr/models/worship_tracker_model.dart';
import 'package:islamic_app/features/quran/providers/quran_reading_providers.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
import 'package:islamic_app/features/prayer_times/models/city_model.dart';

void main() {
  group('İbadet Takibi ve Zikir Model Testleri', () {
    test('DailyWorshipEntry varsayılan olarak boş ve 0 tamamlanma oranına sahip olmalı', () {
      const entry = DailyWorshipEntry(dateKey: '2026-03-01');
      expect(entry.completedCount, 0);
      expect(entry.completionRatio, 0.0);
    });

    test('DailyWorshipEntry tüm ibadetler tamamlandığında 7/7 oran vermeli', () {
      const entry = DailyWorshipEntry(
        dateKey: '2026-03-01',
        fajr: true,
        dhuhr: true,
        asr: true,
        maghrib: true,
        isha: true,
        quran: true,
        zikr: true,
      );
      expect(entry.completedCount, 7);
      expect(entry.completionRatio, 1.0);
    });

    test('DailyWorshipEntry copyWith ve serialization düzgün çalışmalı', () {
      const entry = DailyWorshipEntry(dateKey: '2026-03-01', fajr: true);
      final map = entry.toMap();
      final from = DailyWorshipEntry.fromMap(map);
      expect(from.fajr, isTrue);
      expect(from.dhuhr, isFalse);
    });
  });

  group('Kur\'an Tilavet ve Okuma Özellikleri Testleri', () {
    test('LastReadPosition serialization doğru çalışmalı', () {
      final now = DateTime(2026, 3, 1, 14, 30);
      final lastRead = LastReadPosition(
        surahId: 36,
        surahName: 'Yâsîn',
        verseNumber: 12,
        timestamp: now,
      );
      final map = lastRead.toMap();
      final from = LastReadPosition.fromMap(map);

      expect(from.surahId, 36);
      expect(from.surahName, 'Yâsîn');
      expect(from.verseNumber, 12);
    });

    test('Kâri okuyucuları listesi geçerli ve URL içerikli olmalı', () {
      expect(quranRecitersList.isNotEmpty, isTrue);
      for (final reciter in quranRecitersList) {
        expect(reciter.id.isNotEmpty, isTrue);
        expect(reciter.nameTr.isNotEmpty, isTrue);
        expect(reciter.baseUrl.startsWith('http'), isTrue);
      }
    });

    test('Hesaplama yöntemleri geçerli adhan parametreleri üretmeli', () {
      for (final method in PrayerCalculationMethod.values) {
        final params = method.getAdhanParameters();
        expect(params.fajrAngle, isNotNull);
        expect(params.ishaAngle != null || params.ishaInterval > 0, isTrue);
      }
    });

    test('Önceden tanımlı şehirler listesi koordinatları geçerli olmalı', () {
      expect(predefinedCitiesList.isNotEmpty, isTrue);
      for (final city in predefinedCitiesList) {
        expect(city.latitude, inInclusiveRange(-90.0, 90.0));
        expect(city.longitude, inInclusiveRange(-180.0, 180.0));
        expect(city.name.isNotEmpty, isTrue);
      }
    });
  });
}
