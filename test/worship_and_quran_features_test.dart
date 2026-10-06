import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/zikr/models/worship_tracker_model.dart';
import 'package:islamic_app/features/quran/providers/quran_reading_providers.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
import 'package:islamic_app/features/prayer_times/models/city_model.dart';
import 'package:islamic_app/features/ramadan/screens/ramadan_dashboard_screen.dart';

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

    test('WorshipStreakMilestone tüm 6 dönüm noktasını ve motive edici sureleri içermeli', () {
      expect(WorshipStreakMilestone.allMilestones.length, 6);
      final days = WorshipStreakMilestone.allMilestones.map((m) => m.days).toList();
      expect(days, [10, 30, 50, 100, 200, 400]);

      // 10. gün Asr Suresi
      expect(WorshipStreakMilestone.allMilestones[0].surahName, 'Asr Suresi');
      // 30. gün İnşirah Suresi
      expect(WorshipStreakMilestone.allMilestones[1].surahName, 'İnşirah Suresi');
      // 50. gün Bakara Suresi
      expect(WorshipStreakMilestone.allMilestones[2].surahName, 'Bakara Suresi');
      // 100. gün Mü'minûn Suresi
      expect(WorshipStreakMilestone.allMilestones[3].surahName, 'Mü\'minûn Suresi');
      // 200. gün Fetih Suresi
      expect(WorshipStreakMilestone.allMilestones[4].surahName, 'Fetih Suresi');
      // 400. gün Fecr Suresi
      expect(WorshipStreakMilestone.allMilestones[5].surahName, 'Fecr Suresi');

      for (final m in WorshipStreakMilestone.allMilestones) {
        expect(m.arabicText.isNotEmpty, isTrue);
        expect(m.turkishMeaning.isNotEmpty, isTrue);
        expect(m.spiritualVirtue.isNotEmpty, isTrue);
        expect(m.badgeName.isNotEmpty, isTrue);
      }
    });

    test('WorshipTrackerNotifier kesintisiz günlük seriyi doğru hesaplamalı', () {
      final notifier = WorshipTrackerNotifier();
      final now = DateTime.now();

      // Hiçbir kayıt yokken seri 0
      notifier.state = {};
      expect(notifier.calculateCurrentStreak(), 0);

      // Bugün 7/7 tamamlandığında seri 1
      final todayKey = WorshipTrackerNotifier.formatDateKey(now);
      notifier.state = {
        todayKey: const DailyWorshipEntry(
          dateKey: '',
          fajr: true, dhuhr: true, asr: true, maghrib: true, isha: true, quran: true, zikr: true,
        ),
      };
      expect(notifier.calculateCurrentStreak(), 1);

      // Dün ve bugün tamamlandığında seri 2
      final yesterdayKey = WorshipTrackerNotifier.formatDateKey(now.subtract(const Duration(days: 1)));
      notifier.state = {
        todayKey: const DailyWorshipEntry(
          dateKey: '',
          fajr: true, dhuhr: true, asr: true, maghrib: true, isha: true, quran: true, zikr: true,
        ),
        yesterdayKey: const DailyWorshipEntry(
          dateKey: '',
          fajr: true, dhuhr: true, asr: true, maghrib: true, isha: true, quran: true, zikr: true,
        ),
      };
      expect(notifier.calculateCurrentStreak(), 2);
    });

    test('DailyCompletionVerse pool 31 zengin ve doğrulanmış ayet içermeli ve tarihe göre farklı ayet dönmeli', () {
      expect(DailyCompletionVerse.pool.length, 31);

      // Her ayetin alanları dolu ve geçerli olmalı
      for (final v in DailyCompletionVerse.pool) {
        expect(v.surahName.isNotEmpty, isTrue);
        expect(v.verseReference.isNotEmpty, isTrue);
        expect(v.arabicText.isNotEmpty, isTrue);
        expect(v.turkishMeaning.isNotEmpty, isTrue);
        expect(v.spiritualNote.isNotEmpty, isTrue);
      }

      // Farklı günlerde farklı ayetler dönmeli
      final day1 = DateTime(2026, 6, 1);
      final day2 = DateTime(2026, 6, 2);
      final verseDay1 = DailyCompletionVerse.getForDate(day1);
      final verseDay2 = DailyCompletionVerse.getForDate(day2);

      expect(verseDay1.verseReference != verseDay2.verseReference, isTrue);

      // Index bazlı erişim ve döngü çalışmalı
      final v0 = DailyCompletionVerse.getByIndex(0);
      final v31 = DailyCompletionVerse.getByIndex(31);
      expect(v0.verseReference, v31.verseReference);
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

  group('Ramazan ve Oruç Sayacı Testleri', () {
    test('FastingTrackerData varsayılan değerleri ve totalDays hesaplaması doğru olmalı', () {
      const data = FastingTrackerData(loggedDates: {'2026-03-01', '2026-03-02'}, manualExtraDays: 3);
      expect(data.totalDays, 5);
      expect(data.isFastingToday('2026-03-01'), isTrue);
      expect(data.isFastingToday('2026-03-03'), isFalse);
    });

    test('FastingTrackerData copyWith manualExtraDays doğru güncellenmeli', () {
      const data = FastingTrackerData(loggedDates: {}, manualExtraDays: 0);
      final updated = data.copyWith(manualExtraDays: 10);
      expect(updated.totalDays, 10);
      expect(updated.manualExtraDays, 10);
    });
  });
}
