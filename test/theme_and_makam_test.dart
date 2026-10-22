import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/features/notifications/models/adhan_makam.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemePalette Testleri', () {
    test('Tüm 7 lüks palet tanımlı ve benzersiz başlıklara sahip olmalı', () {
      expect(AppThemePalette.values.length, 7);

      final titles = AppThemePalette.values.map((p) => p.title).toSet();
      expect(titles.length, 7);
      expect(titles.contains('Zümrüt & Altın'), isTrue);
      expect(titles.contains('Gece Siyahı (OLED)'), isTrue);
      expect(titles.contains('Kâbe Füme'), isTrue);
      expect(titles.contains('Derin Lacivert'), isTrue);
      expect(titles.contains('Osmanlı Bordosu'), isTrue);
      expect(titles.contains('Seher Moru'), isTrue);
      expect(titles.contains('Medine Hurması'), isTrue);
    });

    test('BeyanColors.tone her palet değiştiğinde yeşil tonları o paletin rengine dönüştürmeli', () {
      BeyanColors.setPalette(AppThemePalette.emerald);
      final emeraldCard = BeyanColors.tone(0xFF012E2B);
      expect(emeraldCard, const Color(0xFF012E2B));

      BeyanColors.setPalette(AppThemePalette.deepSapphire);
      final sapphireCard = BeyanColors.tone(0xFF012E2B);
      expect(sapphireCard, isNot(equals(emeraldCard)));

      BeyanColors.setPalette(AppThemePalette.ottomanBurgundy);
      final burgundyCard = BeyanColors.tone(0xFF012E2B);
      expect(burgundyCard, isNot(equals(emeraldCard)));
      expect(burgundyCard, isNot(equals(sapphireCard)));

      BeyanColors.setPalette(AppThemePalette.emerald);
    });

    test('OLED Black paleti saf siyah (#000000) zemin rengine sahip olmalı', () {
      const oled = AppThemePalette.oledBlack;
      expect(oled.darkBackground.toARGB32(), 0xFF000000);
      expect(oled.accentGold, isNotNull);
    });

    test('Her palet için hem açık hem koyu tema başarıyla inşa edilebilmeli', () {
      for (final palette in AppThemePalette.values) {
        final light = AppTheme.buildTheme(palette, isDark: false);
        final dark = AppTheme.buildTheme(palette, isDark: true);

        expect(light.brightness, Brightness.light);
        expect(dark.brightness, Brightness.dark);
        expect(light.colorScheme.primary, isNotNull);
        expect(dark.colorScheme.primary, isNotNull);
      }
    });

    test('ThemeState copyWith doğru çalışmalı', () {
      const initial = ThemeState(
        mode: ThemeMode.light,
        palette: AppThemePalette.emerald,
        isDynamicPrayerTheme: false,
      );

      final updated = initial.copyWith(
        mode: ThemeMode.dark,
        palette: AppThemePalette.deepSapphire,
        isDynamicPrayerTheme: true,
      );

      expect(updated.mode, ThemeMode.dark);
      expect(updated.palette, AppThemePalette.deepSapphire);
      expect(updated.isDynamicPrayerTheme, isTrue);
    });

    test('Her palet için uyumlu prayerCardGradient ve prayerCardGlow tanımlı olmalı', () {
      for (final palette in AppThemePalette.values) {
        expect(palette.prayerCardGradient.length, 3);
        expect(palette.prayerCardGlow, isNotNull);
      }
      expect(AppThemePalette.emerald.prayerCardGradient.first, const Color(0xFF02362E));
    });
  });

  group('AdhanMakam Testleri', () {
    test('Tüm ezan makamları ve ses kaynakları doğru tanımlanmış olmalı', () {
      expect(AdhanMakam.values.length, 6);

      expect(AdhanMakam.istanbul.soundResourceName, 'adhan_istanbul');
      expect(AdhanMakam.mecca.soundResourceName, 'adhan_mecca');
      expect(AdhanMakam.medina.soundResourceName, 'adhan_medina');
      expect(AdhanMakam.tekbir.soundResourceName, 'adhan_tekbir');
      expect(AdhanMakam.silent.soundResourceName, isNull);
      expect(AdhanMakam.bell.soundResourceName, isNull);
    });

    test('Makamların başlık ve açıklamaları boş olmamalı', () {
      for (final makam in AdhanMakam.values) {
        expect(makam.title.isNotEmpty, isTrue);
        expect(makam.description.isNotEmpty, isTrue);
        expect(makam.icon, isNotNull);
      }
    });

    test('Sessiz hariç sesli makamların önizleme bağlantısı tanımlı olmalı', () {
      expect(AdhanMakam.istanbul.previewAudioUrl.isNotEmpty, isTrue);
      expect(AdhanMakam.mecca.previewAudioUrl.isNotEmpty, isTrue);
      expect(AdhanMakam.medina.previewAudioUrl.isNotEmpty, isTrue);
      expect(AdhanMakam.silent.previewAudioUrl.isEmpty, isTrue);
    });

    test('Yerel asset yolları doğru formatta olmalı', () {
      expect(AdhanMakam.istanbul.assetPath, 'audio/adhan_istanbul.mp3');
      expect(AdhanMakam.mecca.assetPath, 'audio/adhan_mecca.mp3');
      expect(AdhanMakam.medina.assetPath, 'audio/adhan_medina.mp3');
      expect(AdhanMakam.tekbir.assetPath, 'audio/adhan_tekbir.mp3');
      expect(AdhanMakam.silent.assetPath, isEmpty);
    });

    test('Mecca ve Medina PRO makam olmalı, diğerleri ücretsiz olmalı', () {
      expect(AdhanMakam.mecca.isPro, isTrue);
      expect(AdhanMakam.medina.isPro, isTrue);
      expect(AdhanMakam.istanbul.isPro, isFalse);
      expect(AdhanMakam.tekbir.isPro, isFalse);
      expect(AdhanMakam.bell.isPro, isFalse);
      expect(AdhanMakam.silent.isPro, isFalse);
    });

    test('Makamların 3 dildeki başlık ve açıklamaları doğru olmalı', () {
      for (final makam in AdhanMakam.values) {
        expect(makam.localizedTitle('tr').isNotEmpty, isTrue);
        expect(makam.localizedTitle('en').isNotEmpty, isTrue);
        expect(makam.localizedTitle('ar').isNotEmpty, isTrue);
        expect(makam.localizedDescription('tr').isNotEmpty, isTrue);
        expect(makam.localizedDescription('en').isNotEmpty, isTrue);
        expect(makam.localizedDescription('ar').isNotEmpty, isTrue);
      }
    });

    test('QuranAudioState copyWith clearCurrentSurah surah ID ve ismini temizlemelidir', () {
      final state = QuranAudioState(
        isPlaying: true,
        currentSurahId: 1,
        currentSurahName: 'Fatiha',
        selectedReciter: quranRecitersList.first,
      );

      final cleared = state.copyWith(clearCurrentSurah: true, isPlaying: false);
      expect(cleared.currentSurahId, isNull);
      expect(cleared.currentSurahName, isNull);
      expect(cleared.isPlaying, isFalse);
    });
  });
}
