import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/services/acoustic_audio_service.dart';
import 'package:islamic_app/core/widgets/luxury_page_route.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';
import 'package:islamic_app/features/dua/providers/dua_providers.dart';
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
}
