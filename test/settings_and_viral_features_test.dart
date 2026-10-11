import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/spiritual_healing/models/mood_verse_model.dart';
import 'package:islamic_app/features/verse_studio/screens/verse_card_studio_screen.dart';

void main() {
  group('Ruh Haline Göre Âyet ve Şifa (MoodVerse) Testleri', () {
    test('MoodVerseData havuzu 8 temel ruh halini eksiksiz barındırmalıdır', () {
      expect(MoodVerseData.list.length, equals(8));
    });

    test('Tüm ruh hallerinin Türkçe, İngilizce ve Arapça verileri dolu olmalıdır', () {
      for (final item in MoodVerseData.list) {
        expect(item.emoji, isNotEmpty);
        expect(item.titleTr, isNotEmpty);
        expect(item.titleEn, isNotEmpty);
        expect(item.titleAr, isNotEmpty);

        expect(item.arabicText, isNotEmpty);
        expect(item.translationTr, isNotEmpty);
        expect(item.translationEn, isNotEmpty);
        expect(item.translationAr, isNotEmpty);

        expect(item.propheticDua, isNotEmpty);
        expect(item.reflectionTr, isNotEmpty);
        expect(item.reflectionEn, isNotEmpty);
        expect(item.reflectionAr, isNotEmpty);

        expect(item.surahId, greaterThan(0));
        expect(item.verseNumber, greaterThan(0));
        expect(item.surahRef, isNotEmpty);
      }
    });

    test('localizedTitle, localizedTranslation ve localizedReflection dile göre doğru metinleri dönmeli', () {
      final lonely = MoodVerseData.list.firstWhere((m) => m.mood == SpiritualMood.yalniz);

      expect(lonely.localizedTitle('tr'), equals('Yalnız'));
      expect(lonely.localizedTitle('en'), equals('Lonely'));
      expect(lonely.localizedTitle('ar'), equals('وحيد'));

      expect(lonely.localizedTranslation('tr'), contains('şah damarından daha yakınız'));
      expect(lonely.localizedTranslation('en'), contains('closer to him than'));
    });
  });

  group('Ayet / Hikaye & Duvar Kağıdı Stüdyosu Testleri', () {
    test('CardStudioBackground tüm 6 estetik temayı barındırmalıdır', () {
      expect(CardStudioBackground.values.length, equals(6));
      expect(CardStudioBackground.values, contains(CardStudioBackground.mistyMosque));
      expect(CardStudioBackground.values, contains(CardStudioBackground.goldenSunset));
      expect(CardStudioBackground.values, contains(CardStudioBackground.starryNight));
      expect(CardStudioBackground.values, contains(CardStudioBackground.kaabaHoly));
      expect(CardStudioBackground.values, contains(CardStudioBackground.islamicArch));
      expect(CardStudioBackground.values, contains(CardStudioBackground.oledBlack));
    });
  });
}
