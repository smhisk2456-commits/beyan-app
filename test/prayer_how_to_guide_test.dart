import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_how_to_model.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';

void main() {
  group('PrayerHowToGuide', () {
    test('2 rekatlık namazda ilk oturuş yoktur', () {
      final steps = PrayerHowToGuide.steps(PrayerName.fajr, AppLanguage.turkish);
      expect(steps.any((s) => s.title.contains('İlk Oturuş')), isFalse);
      expect(steps.any((s) => s.title.contains('Son Oturuş')), isTrue);
    });

    test('4 rekatlık namazda ilk ve son oturuş ile 3-4. rekat adımı vardır', () {
      final steps = PrayerHowToGuide.steps(PrayerName.dhuhr, AppLanguage.turkish);
      expect(steps.any((s) => s.title.contains('İlk Oturuş')), isTrue);
      expect(steps.any((s) => s.title.contains('3. ve 4. Rekatlar')), isTrue);
      expect(steps.any((s) => s.title.contains('Son Oturuş')), isTrue);
    });

    test('Akşam namazı 3 rekat olarak anlatılır', () {
      final steps = PrayerHowToGuide.steps(PrayerName.maghrib, AppLanguage.turkish);
      expect(steps.any((s) => s.title == '3. Rekat'), isTrue);
      expect(PrayerHowToGuide.exampleCaption(PrayerName.maghrib, AppLanguage.turkish), contains('Akşam'));
    });

    test('Türkçe büyük harf İkindi olarak yazılır', () {
      expect(PrayerHowToGuide.exampleCaption(PrayerName.asr, AppLanguage.turkish), contains('İkindi'));
    });

    test('Arapça arayüzde okunuş/meal gösterilmez, diğer dillerde gösterilir', () {
      for (final lang in AppLanguage.values) {
        for (final p in PrayerName.values) {
          final steps = PrayerHowToGuide.steps(p, lang);
          expect(steps, isNotEmpty);
          final fatiha = steps.firstWhere((s) => s.arabic?.contains('الْحَمْدُ') ?? false);
          if (lang == AppLanguage.arabic) {
            expect(fatiha.transliteration, isNull);
            expect(fatiha.meaning, isNull);
          } else {
            expect(fatiha.transliteration, isNotEmpty);
            expect(fatiha.meaning, isNotEmpty);
          }
        }
      }
    });
  });
}
