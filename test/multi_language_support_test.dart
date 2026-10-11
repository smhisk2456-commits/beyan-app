import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/notifications/models/short_verse_notification.dart';

void main() {
  group('Çok Dilli (8 Dil) Sistem Testleri', () {
    test('AppLanguage enum tüm 8 dili eksiksiz barındırmalıdır', () {
      expect(AppLanguage.values.length, 8);
      final codes = AppLanguage.values.map((l) => l.code).toSet();
      expect(codes, containsAll(['tr', 'en', 'ar', 'id', 'fr', 'ur', 'de', 'ru']));
    });

    test('AppLanguage.fromCode tüm 8 dil kodunu doğru eşleştirmelidir', () {
      expect(AppLanguage.fromCode('tr'), AppLanguage.turkish);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('ar'), AppLanguage.arabic);
      expect(AppLanguage.fromCode('id'), AppLanguage.indonesian);
      expect(AppLanguage.fromCode('fr'), AppLanguage.french);
      expect(AppLanguage.fromCode('ur'), AppLanguage.urdu);
      expect(AppLanguage.fromCode('de'), AppLanguage.german);
      expect(AppLanguage.fromCode('ru'), AppLanguage.russian);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.turkish); // fallback
    });

    test('isRTL yalnızca Arapça ve Urduca için true dönmelidir', () {
      expect(AppLanguage.arabic.isRTL, isTrue);
      expect(AppLanguage.urdu.isRTL, isTrue);
      expect(AppLanguage.turkish.isRTL, isFalse);
      expect(AppLanguage.english.isRTL, isFalse);
      expect(AppLanguage.indonesian.isRTL, isFalse);
      expect(AppLanguage.french.isRTL, isFalse);
      expect(AppLanguage.german.isRTL, isFalse);
      expect(AppLanguage.russian.isRTL, isFalse);
    });

    test('AppStrings tüm 8 dilde temel anahtarları ve İslami terimleri doğru sunmalıdır', () {
      for (final lang in AppLanguage.values) {
        final strings = AppStrings(lang);
        expect(strings.appName, 'Beyân');
        expect(strings.tabHome.isNotEmpty, isTrue);
        expect(strings.tabPrayers.isNotEmpty, isTrue);
        expect(strings.tabQuran.isNotEmpty, isTrue);
        expect(strings.tabZikr.isNotEmpty, isTrue);
        expect(strings.prayerNameFajr.isNotEmpty, isTrue);
        expect(strings.prayerNameMaghrib.isNotEmpty, isTrue);
        expect(strings.paywallTitle.isNotEmpty, isTrue);
        expect(strings.allDuasLink.isNotEmpty, isTrue);
      }

      // Özgün dil kontrolleri
      expect(const AppStrings(AppLanguage.indonesian).tabPrayers, 'Jadwal Sholat');
      expect(const AppStrings(AppLanguage.french).tabHome, 'Accueil');
      expect(const AppStrings(AppLanguage.urdu).tabQuran, 'قرآن پاک');
      expect(const AppStrings(AppLanguage.german).tabHome, 'Startseite');
      expect(const AppStrings(AppLanguage.russian).tabPrayers, 'Время намаза');
    });

    test('AppStrings 26 parametreli metodu tüm 8 dilde eksiksiz formatlamalıdır', () {
      for (final lang in AppLanguage.values) {
        final strings = AppStrings(lang);
        expect(strings.surahBadge(7).contains('7'), isTrue);
        expect(strings.surahNumber(1).contains('1'), isTrue);
        expect(strings.targetLabel(33).contains('33'), isTrue);
        expect(strings.minutesSuffix(15).contains('15'), isTrue);
        expect(strings.surahVerseLabel('Bakara', 255).contains('255'), isTrue);
        expect(strings.daysRemainingText(5).contains('5'), isTrue);
        expect(strings.lapsText(3).contains('3'), isTrue);
        expect(strings.streakDaysTitle(10).contains('10'), isTrue);
        expect(strings.remainingTasksText(2).contains('2'), isTrue);
        expect(strings.bestStreakLabel(14).contains('14'), isTrue);
        expect(strings.rakatsCount(4).contains('4'), isTrue);
        expect(strings.dayTasksCompleted(1).contains('1'), isTrue);
        expect(strings.trialActiveBanner(3).contains('3'), isTrue);
        expect(strings.adjustmentDaysLabel(1).contains('1'), isTrue);
        expect(strings.allDuasWithCount(40).contains('40'), isTrue);
        expect(strings.kaabaDistance(2500).contains('2500'), isTrue);
        expect(strings.turnRightDeg(45).contains('45'), isTrue);
        expect(strings.turnLeftDeg(30).contains('30'), isTrue);
        expect(strings.fastingDaysCount(30).contains('30'), isTrue);
        expect(strings.surahNumberBadge(18).contains('18'), isTrue);
        expect(strings.verseCopied('2:255').contains('2:255'), isTrue);
        expect(strings.recitationOfSurah('Yasin').contains('Yasin'), isTrue);
      }
    });

    test('PrayerName localizedName ve localizedRakat 8 dilde doğrulanmalıdır', () {
      expect(PrayerName.fajr.localizedName('id'), 'Subuh');
      expect(PrayerName.fajr.localizedName('fr'), 'Fajr');
      expect(PrayerName.fajr.localizedName('ur'), 'فجر');
      expect(PrayerName.fajr.localizedName('de'), 'Fadschr');
      expect(PrayerName.fajr.localizedName('ru'), 'Фаджр');

      expect(PrayerName.maghrib.localizedName('id'), 'Maghrib');
      expect(PrayerName.maghrib.localizedName('ur'), 'مغرب');
      expect(PrayerName.maghrib.localizedName('ru'), 'Магриб');

      expect(PrayerName.fajr.localizedRakat('id'), contains('4 Rakaat'));
      expect(PrayerName.fajr.localizedRakat('fr'), contains('4 Rakats'));
      expect(PrayerName.fajr.localizedRakat('ur'), contains('۴ رکعت'));
      expect(PrayerName.fajr.localizedRakat('de'), contains('4 Raka\'at'));
      expect(PrayerName.fajr.localizedRakat('ru'), contains('4 ракаата'));
    });

    test('ShortVerseNotification localizedTitle tüm 8 dilde doğru format dönmelidir', () {
      final verse = ShortVerseNotification.getByIndex(0);
      expect(verse.localizedTitle('tr'), contains('Günün Âyeti'));
      expect(verse.localizedTitle('en'), contains('Verse of the Day'));
      expect(verse.localizedTitle('ar'), contains('آية اليوم'));
      expect(verse.localizedTitle('id'), contains('Ayat Hari Ini'));
      expect(verse.localizedTitle('fr'), contains('Verset du Jour'));
      expect(verse.localizedTitle('ur'), contains('آج کی آیت'));
      expect(verse.localizedTitle('de'), contains('Vers des Tages'));
      expect(verse.localizedTitle('ru'), contains('Аят Дня'));

      expect(verse.localizedTitle('id', isEvening: true), contains('Renungan Malam'));
      expect(verse.localizedTitle('fr', isEvening: true), contains('Méditation du Soir'));
      expect(verse.localizedTitle('ur', isEvening: true), contains('شام کی فکر'));
      expect(verse.localizedTitle('de', isEvening: true), contains('Abend-Besinnung'));
      expect(verse.localizedTitle('ru', isEvening: true), contains('Вечернее размышление'));
    });
  });
}
