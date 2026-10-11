import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/notifications/models/short_verse_notification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShortVerseNotification Testleri', () {
    test('Havuz 120 zengin ve doğrulanmış ayet içermelidir', () {
      expect(ShortVerseNotification.pool.length, equals(120));
    });

    test('getNonRepeatingBatch eşsiz ve mükerrer olmayan ayetler üretmelidir', () async {
      SharedPreferences.setMockInitialValues({});

      final batch1 = await ShortVerseNotification.getNonRepeatingBatch(14);
      expect(batch1.length, equals(14));

      // Batch 1 içindeki ayetler benzersiz olmalı
      final refs1 = batch1.map((v) => v.verseReference).toSet();
      expect(refs1.length, equals(14));

      // İkinci parti çağrıldığında ilk partiyle çakışmayan yeni ayetler dönmeli
      final batch2 = await ShortVerseNotification.getNonRepeatingBatch(14);
      expect(batch2.length, equals(14));

      final refs2 = batch2.map((v) => v.verseReference).toSet();
      expect(refs2.length, equals(14));

      // İki ardışık partideki kesişim boş olmalıdır (deduplication çalışır)
      final intersection = refs1.intersection(refs2);
      expect(intersection.isEmpty, isTrue);
    });

    test('Tüm ayetlerin referansı ve 3 dildeki çevirileri dolu olmalıdır', () {
      for (final verse in ShortVerseNotification.pool) {
        expect(verse.verseReference.isNotEmpty, isTrue);
        expect(verse.arabicText.isNotEmpty, isTrue);
        expect(verse.textTr.isNotEmpty, isTrue);
        expect(verse.textEn.isNotEmpty, isTrue);
        expect(verse.textAr.isNotEmpty, isTrue);
        expect(verse.surahNameTr.isNotEmpty, isTrue);
        expect(verse.surahNameEn.isNotEmpty, isTrue);
        expect(verse.surahNameAr.isNotEmpty, isTrue);

        // Bildirim metinlerinin kısa ve vurucu olduğunu kontrol et (< 160 karakter)
        expect(verse.textTr.length, lessThan(160));
        expect(verse.textEn.length, lessThan(160));
      }
    });

    test('Dile göre localizedText ve localizedTitle doğru metni dönmelidir', () {
      final verse = ShortVerseNotification.pool.first;
      expect(verse.localizedText('tr'), verse.textTr);
      expect(verse.localizedText('en'), verse.textEn);
      expect(verse.localizedText('ar'), verse.textAr);

      expect(verse.localizedTitle('tr').contains('Günün Âyeti'), isTrue);
      expect(verse.localizedTitle('en').contains('Verse of the Day'), isTrue);
      expect(verse.localizedTitle('ar').contains('آية اليوم'), isTrue);

      expect(verse.localizedTitle('tr', isEvening: true).contains('Akşam Tefekkürü'), isTrue);
      expect(verse.localizedTitle('en', isEvening: true).contains('Evening Reflection'), isTrue);
      expect(verse.localizedTitle('ar', isEvening: true).contains('تأمل المساء'), isTrue);
    });

    test('getNextRotatingVerse her çağrıda indeksi sırayla arttırmalıdır', () async {
      SharedPreferences.setMockInitialValues({});

      final v1 = await ShortVerseNotification.getNextRotatingVerse();
      final v2 = await ShortVerseNotification.getNextRotatingVerse();
      final v3 = await ShortVerseNotification.getNextRotatingVerse();

      expect(v1, isNotNull);
      expect(v2, isNotNull);
      expect(v3, isNotNull);
      expect(v1.verseReference, isNot(equals(v2.verseReference)));
      expect(v2.verseReference, isNot(equals(v3.verseReference)));
    });

    test('AppStrings tüm 3 dilde bildirim başlıklarını ve etiketlerini eksiksiz sunmalıdır', () {
      for (final lang in AppLanguage.values) {
        final strings = AppStrings(lang);
        expect(strings.sectionVerseAlerts.isNotEmpty, isTrue);
        expect(strings.verseReminderTitle.isNotEmpty, isTrue);
        expect(strings.testVerseBtn.isNotEmpty, isTrue);
        expect(strings.verseFreq2PerHour.isNotEmpty, isTrue);
        expect(strings.verseFreqMorningEvening.isNotEmpty, isTrue);
      }
    });
  });
}
