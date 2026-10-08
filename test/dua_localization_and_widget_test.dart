import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/notifications/models/short_verse_notification.dart';

void main() {
  group('Dua Localization & Multilingual Tests', () {
    test('sabah_5 duası İngilizce ve Arapça dillerinde doğru çeviri ve referans dönmeli', () {
      final sabah5 = verifiedDuasList.firstWhere((d) => d.id == 'sabah_5');

      // Turkish
      expect(sabah5.localizedTitle('tr'), 'İlim, Rızık ve Kabul Gören Amel');
      expect(sabah5.localizedMeaning('tr').contains('faydalı ilim'), isTrue);
      expect(sabah5.localizedReference('tr'), 'Sünen-i İbni Mace (925)');

      // English (Fix for Screenshot 3)
      expect(sabah5.localizedTitle('en'), contains('Beneficial Knowledge'));
      expect(sabah5.localizedMeaning('en'), contains('beneficial knowledge'));
      expect(sabah5.localizedReference('en'), 'Sunan Ibn Majah (925)');

      // Arabic
      expect(sabah5.localizedTitle('ar'), contains('طلب العلم'));
      expect(sabah5.localizedMeaning('ar'), contains('علماً نافعاً'));
      expect(sabah5.localizedReference('ar'), 'سنن ابن ماجه (٩٢٥)');
    });

    test('Tüm doğrulanmış dualar İngilizce anlam ve referans sağlamalıdır', () {
      for (final dua in verifiedDuasList) {
        expect(dua.localizedTitle('en').isNotEmpty, isTrue);
        expect(dua.localizedMeaning('en').isNotEmpty, isTrue);
        expect(dua.localizedReference('en').isNotEmpty, isTrue);

        expect(dua.localizedTitle('ar').isNotEmpty, isTrue);
        expect(dua.localizedMeaning('ar').isNotEmpty, isTrue);
        expect(dua.localizedReference('ar').isNotEmpty, isTrue);
      }
    });

    test('ShortVerseNotification localizedReference her 3 dilde doğru sure ismi sağlamalıdır', () {
      final inshirah = ShortVerseNotification.pool.first;
      expect(inshirah.localizedReference('tr'), 'İnşirâh 94:5-6');
      expect(inshirah.localizedReference('en'), 'Ash-Sharh 94:5-6');
      expect(inshirah.localizedReference('ar'), 'الشرح 94:5-6');
    });

    test('AppStrings namaz vakti kısayolları ve hata mesajları doğru dillerde çalışmalı', () {
      final stringsTr = AppStrings(AppLanguage.turkish);
      final stringsEn = AppStrings(AppLanguage.english);
      final stringsAr = AppStrings(AppLanguage.arabic);

      expect(stringsTr.dhuhr, 'Öğle');
      expect(stringsEn.dhuhr, 'Dhuhr');
      expect(stringsAr.dhuhr, 'الظهر');

      expect(stringsTr.asr, 'İkindi');
      expect(stringsEn.asr, 'Asr');
      expect(stringsAr.asr, 'العصر');

      expect(stringsTr.prayerTimesLoadError('timeout'), contains('Vakitler yüklenemedi'));
      expect(stringsEn.prayerTimesLoadError('timeout'), contains('Could not load prayer times'));
      expect(stringsAr.prayerTimesLoadError('timeout'), contains('تعذر تحميل'));
    });
  });
}
