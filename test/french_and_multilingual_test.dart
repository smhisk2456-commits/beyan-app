import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/core/localization/translations/fr_strings.dart';
import 'package:islamic_app/features/monetization/models/premium_product.dart';
import 'package:islamic_app/features/quran/models/verse.dart';

void main() {
  group('Multilingual Verse Translations', () {
    const fatiha1 = Verse(
      id: 1,
      surahId: 1,
      verseNumber: 1,
      arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      turkishMeaning: "Rahman ve Rahim olan Allah'ın adıyla:",
      meaningEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      meaningFr: "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux.",
      meaningId: 'Dengan menyebut nama Allah Yang Maha Pemurah lagi Maha Penyayang.',
    );

    test('Türkçe dilinde Türkçe meal döner', () {
      expect(fatiha1.localizedMeaning('tr'), "Rahman ve Rahim olan Allah'ın adıyla:");
    });

    test('Fransızca dilinde Fransızca meal döner (Hamidullah)', () {
      expect(
        fatiha1.localizedMeaning('fr'),
        "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux.",
      );
    });

    test('İngilizce dilinde İngilizce meal döner (Saheeh)', () {
      expect(
        fatiha1.localizedMeaning('en'),
        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      );
    });

    test('Endonezce dilinde Endonezce meal döner', () {
      expect(
        fatiha1.localizedMeaning('id'),
        'Dengan menyebut nama Allah Yang Maha Pemurah lagi Maha Penyayang.',
      );
    });
  });

  group('French UI Localization for Widget & Settings', () {
    const frAppStrings = AppStrings(AppLanguage.french);

    test('Tüm kritik widget arayüz metinleri Fransızca olmalı, İngilizceye düşmemeli', () {
      expect(frAppStrings.verseView, 'Affichage du verset');
      expect(frAppStrings.translationOnly, 'Traduction uniquement');
      expect(frAppStrings.arabicPlusTranslation, 'Arabe + Traduction');
      expect(frAppStrings.arabicOnly, 'Arabe uniquement');
      expect(frAppStrings.comfortAndSolace, 'Paix & Réconfort');
      expect(frAppStrings.patienceAndGratitude, 'Patience & Gratitude');
      expect(frAppStrings.applySettingsToWidget, 'Appliquer les paramètres au widget');
      expect(
        frAppStrings.dynamicVerseCycleActive,
        contains('Cycle dynamique actif'),
      );
      expect(frAppStrings.displayCategories, 'Catégories affichées');
      expect(frAppStrings.quoteRefreshInterval, 'Fréquence de changement des versets');
      expect(frAppStrings.textSize, 'Taille du texte');
      expect(frAppStrings.fontFamily, 'Police d\'écriture');
    });

    test('frStrings haritasında tüm AppStrings anahtarları mevcut olmalı', () {
      expect(frStrings.containsKey('verseView'), isTrue);
      expect(frStrings.containsKey('applySettingsToWidget'), isTrue);
      expect(frStrings.containsKey('comfortAndSolace'), isTrue);
      expect(frStrings.containsKey('dynamicVerseCycleActive'), isTrue);
    });
  });

  group('Paywall Pricing Options', () {
    test('Yıllık plan ₺299,99 ve %50 indirimli olmalı', () {
      expect(PremiumTier.yearly.defaultPriceText, '₺299,99 / yıl');
      expect(PremiumTier.yearly.badgeText, '%50 İNDİRİM');
      expect(PremiumTier.yearly.subtitle, contains('₺25,00'));
    });

    test('Aylık ve Ömür Boyu planlar doğru tanımlı olmalı', () {
      expect(PremiumTier.monthly.defaultPriceText, '₺49,99 / ay');
      expect(PremiumTier.lifetime.defaultPriceText, '₺499,99 (Tek Seferlik)');
    });
  });
}
