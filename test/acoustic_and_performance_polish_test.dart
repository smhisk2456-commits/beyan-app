import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/services/acoustic_audio_service.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/core/widgets/luxury_page_route.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';
import 'package:islamic_app/features/dua/providers/dua_providers.dart';
import 'package:islamic_app/features/home/models/dynamic_prayer_atmosphere.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/quran/widgets/arabic_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcousticAudioService Testleri', () {
    test('Varsayılan ses ayarları aktif olmalı ve singleton doğru çalışmalı', () {
      final service1 = AcousticAudioService.instance;
      final service2 = AcousticAudioService();

      expect(identical(service1, service2), isTrue);
      expect(service1.isZikrSoundEnabled, isTrue);
      expect(service1.isPageFlipSoundEnabled, isTrue);
      expect(service1.zikrSoundStyle, 0);
    });

    test('Zikir ses stilleri (0: Kadife Tık, 1: Kehribar, 2: Sessiz) doğru geçiş yapmalı', () async {
      final service = AcousticAudioService.instance;

      service.zikrSoundStyle = 1;
      expect(service.zikrSoundStyle, 1);

      service.zikrSoundStyle = 2;
      expect(service.zikrSoundStyle, 2);
      await expectLater(service.playKukaBeadSound(), completes);

      service.zikrSoundStyle = 0;
      expect(service.zikrSoundStyle, 0);
    });

    test('Ses açma ve kapama kontrolleri doğru güncellenmeli', () {
      final service = AcousticAudioService.instance;

      service.isZikrSoundEnabled = false;
      expect(service.isZikrSoundEnabled, isFalse);

      service.isZikrSoundEnabled = true;
      expect(service.isZikrSoundEnabled, isTrue);

      service.isPageFlipSoundEnabled = false;
      expect(service.isPageFlipSoundEnabled, isFalse);

      service.isPageFlipSoundEnabled = true;
      expect(service.isPageFlipSoundEnabled, isTrue);
    });

    test('playKukaBeadSound ses kapalıyken işlem yapmadan dönmeli', () async {
      final service = AcousticAudioService.instance;
      service.isZikrSoundEnabled = false;

      // Hata fırlatmadan sessizce tamamlanmalı
      await expectLater(service.playKukaBeadSound(), completes);
      service.isZikrSoundEnabled = true;
    });

    test('playParchmentPageFlip ses kapalıyken işlem yapmadan dönmeli', () async {
      final service = AcousticAudioService.instance;
      service.isPageFlipSoundEnabled = false;

      // Hata fırlatmadan sessizce tamamlanmalı
      await expectLater(service.playParchmentPageFlip(), completes);
      service.isPageFlipSoundEnabled = true;
    });
  });

  group('LuxuryPageRoute Testleri', () {
    test('3B Lüks geçiş rotası 500ms açılış ve 360ms kapanış süresine sahip olmalı', () {
      final route = LuxuryPageRoute(
        page: const Scaffold(body: Text('Test')),
      );

      expect(route.transitionDuration, const Duration(milliseconds: 500));
      expect(route.reverseTransitionDuration, const Duration(milliseconds: 360));
    });
  });

  group('Apple Music Tarzı Harf Harf Kur\'an Senkronizasyonu Testleri', () {
    test('QuranAudioState wordProgress ve loopVerseNumber değerlerini korumalı', () {
      final state = QuranAudioState(
        selectedReciter: quranRecitersList.first,
        currentSurahId: 1,
        activeVerseNumber: 2,
        activeWordIndex: 1,
        wordProgress: 0.65,
        loopVerseNumber: 2,
        loopRepeatCount: 3,
      );

      expect(state.wordProgress, closeTo(0.65, 0.001));
      expect(state.loopVerseNumber, 2);
      expect(state.loopRepeatCount, 3);

      final updated = state.copyWith(wordProgress: 0.92);
      expect(updated.wordProgress, closeTo(0.92, 0.001));
      expect(updated.loopVerseNumber, 2);

      final clearedLoop = updated.copyWith(clearLoopVerse: true);
      expect(clearedLoop.loopVerseNumber, isNull);
    });

    testWidgets('ArabicText aktif kelimede ShaderMask ile harf harf dolum oluşturmalı', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArabicText(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              highlightedWordIndex: 1,
              highlightedWordProgress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('Dua Kütüphanesi Arama ve Favori Filtreleme Bug Testleri', () {
    test('Kategori seçili olsa bile favoriteDuasProvider tüm favorileri korumalı', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(verifiedDuasList, isNotEmpty);

      final firstDua = verifiedDuasList.first;
      await container.read(favoriteDuasProvider.notifier).toggleFavorite(firstDua.id);

      // Başka bir kategori seçildiğinde filteredDuasListProvider içinde olmasa bile favoriteDuasProvider 1 kalmalı
      final otherCat = DuaCategory.values.firstWhere((c) => c != firstDua.category);
      container.read(selectedDuaCategoryProvider.notifier).state = otherCat;

      final favorites = container.read(favoriteDuasProvider);
      expect(favorites.length, 1);
      expect(favorites.contains(firstDua.id), isTrue);
    });
  });

  group('Tema Geçişleri ve Birleşik Palet (effectivePaletteProvider) Testleri', () {
    test('Seçilen her tema paleti tüm yeşil referans tonlarını kendi renk uzayına dönüştürmeli', () {
      const greenSamples = [
        0xFF012E2B, // LuxuryFloatingDock üst ton
        0xFF021B17, // LuxuryFloatingDock alt ton
        0xFF071B18, // Koyu arka plan
        0xFF0D2823, // AppBar / yüzey
        0xFF133630, // Kart yüzeyi
        0xFF2E7D32, // Hatim tamamlandı yeşili
      ];

      for (final palette in AppThemePalette.values) {
        if (palette == AppThemePalette.emerald) continue;
        BeyanColors.setPalette(palette);

        for (final hex in greenSamples) {
          final transformed = BeyanColors.tone(hex);
          final hsl = HSLColor.fromColor(transformed);
          // Zümrüt dışındaki hiçbir temada yeşil ton (120..180 yüksek doygunluk) kalmamalı
          final isStillEmeraldGreen = hsl.hue >= 120 && hsl.hue <= 180 && hsl.saturation > 0.15;
          expect(
            isStillEmeraldGreen,
            isFalse,
            reason: '$palette temasında 0x${hex.toRadixString(16)} hala yeşil kaldı: $hsl',
          );
        }
      }

      BeyanColors.setPalette(AppThemePalette.emerald);
    });

    test('effectivePaletteProvider ve DynamicPrayerAtmosphere tüm ekranları tek palet altında birleştirmeli', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Manuel palet seçildiğinde effectivePaletteProvider ve BeyanColors senkronize olmalı
      for (final palette in AppThemePalette.values) {
        await container.read(themeProvider.notifier).setPalette(palette);
        final effective = container.read(effectivePaletteProvider);
        expect(effective, palette);
        expect(BeyanColors.palette, palette);

        final darkTheme = AppTheme.buildTheme(effective, isDark: true);
        expect(darkTheme.scaffoldBackgroundColor, palette.darkBackground);
        expect(darkTheme.appBarTheme.backgroundColor, palette.darkSurface);
        expect(darkTheme.cardTheme.color, palette.darkCard);
      }

      // 2. Dinamik namaz vakti atmosferi, ilgili vaktin paleti ile birebir aynı renkleri üretmeli
      for (final prayer in PrayerName.values) {
        final expectedPalette = ThemeNotifier.paletteForPrayer(prayer);
        final atmosphere = DynamicPrayerAtmosphere.forPrayer(prayer);
        expect(atmosphere.backgroundGradient.first, expectedPalette.darkBackground);
        expect(atmosphere.appBarColor, expectedPalette.darkSurface);
        expect(atmosphere.actionCardBg, expectedPalette.darkSurface);
        expect(atmosphere.cardGradient, expectedPalette.prayerCardGradient);
      }

      BeyanColors.setPalette(AppThemePalette.emerald);
    });
  });
}
