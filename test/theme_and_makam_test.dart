import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/features/notifications/models/adhan_makam.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemePalette Testleri', () {
    test('Tüm 4 palet tanımlı ve benzersiz başlıklara sahip olmalı', () {
      expect(AppThemePalette.values.length, 4);

      final titles = AppThemePalette.values.map((p) => p.title).toSet();
      expect(titles.length, 4);
      expect(titles.contains('Zümrüt & Altın'), isTrue);
      expect(titles.contains('Gece Siyahı (OLED)'), isTrue);
      expect(titles.contains('Kâbe Taş Grisi'), isTrue);
      expect(titles.contains('Derin Lacivert'), isTrue);
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
      );

      final updated = initial.copyWith(
        mode: ThemeMode.dark,
        palette: AppThemePalette.deepSapphire,
      );

      expect(updated.mode, ThemeMode.dark);
      expect(updated.palette, AppThemePalette.deepSapphire);
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
