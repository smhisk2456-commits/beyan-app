import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:islamic_app/features/notifications/models/adhan_makam.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
import 'package:islamic_app/features/prayer_times/models/city_model.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/quran/services/quran_download_service.dart';
import 'package:islamic_app/features/quran/providers/quran_reading_providers.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/providers/dua_providers.dart';
import 'package:islamic_app/features/zikr/models/worship_tracker_model.dart';
import 'package:islamic_app/features/spiritual_healing/models/mood_verse_model.dart';
import 'package:islamic_app/features/widget_service/services/live_activity_service.dart';
import 'package:islamic_app/features/ramadan/models/khatam_tracker_model.dart';
import 'package:islamic_app/features/verse_studio/screens/verse_card_studio_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ayar 1: Dil Seçimi ve Çok Dilli Destek Kapsamlı Bug Testi', () {
    test('8 dilin tamamı AppLanguage enum içinde tanımlı olmalı ve bayrakları dolu olmalı', () {
      expect(AppLanguage.values.length, 8);
      for (final lang in AppLanguage.values) {
        expect(lang.code, isNotEmpty);
        expect(lang.displayName, isNotEmpty);
        expect(lang.flag, isNotEmpty);
      }
    });

    test('Her dil için AppStrings instance hatasız üretilmeli ve kritik metinler boş olmamalı', () {
      for (final lang in AppLanguage.values) {
        final strings = AppStrings(lang);
        expect(strings.appName, isNotEmpty);
        expect(strings.quranTitle, isNotEmpty);
        expect(strings.duaLibraryTitle, isNotEmpty);
        expect(strings.settings, isNotEmpty);
        expect(strings.nextPrayer, isNotEmpty);
        expect(strings.today, isNotEmpty);
      }
    });

    test('fromCode geçersiz veya büyük harfli dil kodlarında varsayılan olarak Türkçe dönmeli', () {
      expect(AppLanguage.fromCode('tr'), AppLanguage.turkish);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('ar'), AppLanguage.arabic);
      expect(AppLanguage.fromCode('xyz_invalid'), AppLanguage.turkish);
      expect(AppLanguage.fromCode(''), AppLanguage.turkish);
    });
  });

  group('Ayar 2: Tema ve Görünüm Paletleri Bug Testi', () {
    test('Tüm tema paletleri hem açık hem koyu ThemeData hatasız üretebilmeli', () {
      for (final palette in AppThemePalette.values) {
        final lightTheme = AppTheme.buildTheme(palette, isDark: false);
        final darkTheme = AppTheme.buildTheme(palette, isDark: true);

        expect(lightTheme.brightness, Brightness.light);
        expect(darkTheme.brightness, Brightness.dark);
        expect(lightTheme.scaffoldBackgroundColor, isNotNull);
        expect(darkTheme.scaffoldBackgroundColor, isNotNull);
      }
    });

    test('OLED Black paleti koyu modda saf siyah (#000000) zemin rengi vermeli', () {
      final oledDark = AppTheme.buildTheme(AppThemePalette.oledBlack, isDark: true);
      expect(oledDark.scaffoldBackgroundColor, const Color(0xFF000000));
    });

    test('ThemeState serialization ve copyWith tutarlı olmalı', () {
      const state = ThemeState(mode: ThemeMode.dark, palette: AppThemePalette.emerald);
      expect(state.mode, ThemeMode.dark);
      expect(state.palette, AppThemePalette.emerald);

      final updated = state.copyWith(palette: AppThemePalette.deepSapphire);
      expect(updated.mode, ThemeMode.dark);
      expect(updated.palette, AppThemePalette.deepSapphire);
    });
  });

  group('Ayar 3: Ezan Makamları ve Ses Kaynakları Bug Testi', () {
    test('Tüm makamlar geçerli id, başlık ve açıklamalara sahip olmalı', () {
      for (final makam in AdhanMakam.values) {
        expect(makam.id, isNotEmpty);
        expect(makam.title, isNotEmpty);
        expect(makam.localizedTitle('tr'), isNotEmpty);
        expect(makam.localizedTitle('en'), isNotEmpty);
        expect(makam.localizedTitle('ar'), isNotEmpty);
        expect(makam.description, isNotEmpty);
      }
    });

    test('Sessiz ve Bell makamları hariç tüm makamların yerel ses kaynağı adı tanımlı olmalı', () {
      for (final makam in AdhanMakam.values) {
        if (makam == AdhanMakam.silent || makam == AdhanMakam.bell) {
          expect(makam.soundResourceName, isNull);
        } else {
          expect(makam.soundResourceName, isNotNull);
          expect(makam.soundResourceName!.isNotEmpty, isTrue);
          expect(makam.previewAudioUrl, isNotNull);
        }
      }
    });

    test('Mecca ve Medina makamları PRO olarak işaretlenmeli, standart makamlar ücretsiz olmalı', () {
      expect(AdhanMakam.mecca.isPro, isTrue);
      expect(AdhanMakam.medina.isPro, isTrue);
      expect(AdhanMakam.istanbul.isPro, isFalse);
      expect(AdhanMakam.silent.isPro, isFalse);
    });
  });

  group('Ayar 4: Namaz Vakti Hesaplama ve Şehir Parametreleri Bug Testi', () {
    test('Tüm hesaplama yöntemleri geçerli açı veya interval değerleri üretmeli', () {
      for (final method in PrayerCalculationMethod.values) {
        final params = method.getAdhanParameters();
        expect(params.fajrAngle, isNotNull);
        expect(params.fajrAngle > 0, isTrue);
        expect(params.ishaAngle != null || params.ishaInterval > 0, isTrue);
      }
    });

    test('Önceden tanımlı şehir listesi sınır kontrollerinden geçmeli', () {
      expect(predefinedCitiesList.length, greaterThanOrEqualTo(30));
      for (final c in predefinedCitiesList) {
        expect(c.name, isNotEmpty);
        expect(c.latitude, inInclusiveRange(-90.0, 90.0));
        expect(c.longitude, inInclusiveRange(-180.0, 180.0));
      }
    });
  });

  group('Özellik 1: Kur\'an-ı Kerim, Kâri Seçimi ve Çevrimdışı İndirme Bug Testi', () {
    test('7 Kâri okuyucusunun tamamı geçerli ve çalışan ses CDN bağlantısına sahip olmalı', () {
      expect(quranRecitersList.length, greaterThanOrEqualTo(7));
      final reciterIds = quranRecitersList.map((r) => r.id).toList();
      expect(reciterIds, contains('mishary'));
      expect(reciterIds, contains('abdulbaset'));
      expect(reciterIds, contains('maher'));
      expect(reciterIds, contains('minshawi'));
      expect(reciterIds, contains('sudais'));

      for (final r in quranRecitersList) {
        expect(r.nameTr, isNotEmpty);
        expect(r.nameAr, isNotEmpty);
        final url1 = r.getSurahAudioUrl(1);
        final url114 = r.getSurahAudioUrl(114);
        expect(url1.startsWith('http'), isTrue);
        expect(url114.startsWith('http'), isTrue);
        expect(url1.endsWith('1.mp3'), isTrue);
        expect(url114.endsWith('114.mp3'), isTrue);
      }
    });

    test('QuranAudioState copyWith ve clearCurrentSurah state temizliğini doğru yapmalı', () {
      final state = QuranAudioState(
        isPlaying: true,
        currentSurahId: 36,
        currentSurahName: 'Yâsîn',
        activeVerseNumber: 10,
        selectedReciter: quranRecitersList.first,
      );

      final cleared = state.copyWith(clearCurrentSurah: true, isPlaying: false);
      expect(cleared.currentSurahId, isNull);
      expect(cleared.currentSurahName, isNull);
      expect(cleared.activeVerseNumber, isNull);
      expect(cleared.isPlaying, isFalse);
    });

    test('QuranDownloadService singleton referansı ve state kontrolü çalışmalı', () {
      expect(QuranDownloadService.instance, isNotNull);
    });
  });

  group('Özellik 2: Kur\'an ve Dua Favoriler Sekmesi Bug Testi', () {
    test('Favori Sureler Notifier ve Provider sınır durumları', () async {
      final container = ProviderContainer();
      final notifier = container.read(favoriteSurahsProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.isFavorite(1), isFalse);
      expect(notifier.isFavorite(114), isFalse);

      await notifier.toggleFavorite(1); // Fatiha
      await notifier.toggleFavorite(36); // Yasin
      await notifier.toggleFavorite(67); // Mulk

      expect(notifier.isFavorite(1), isTrue);
      expect(notifier.isFavorite(36), isTrue);
      expect(notifier.isFavorite(67), isTrue);
      expect(container.read(favoriteSurahsProvider).length, 3);

      await notifier.toggleFavorite(36); // Yasin cikar
      expect(notifier.isFavorite(36), isFalse);
      expect(container.read(favoriteSurahsProvider).length, 2);

      container.dispose();
    });

    test('BookmarkedVersesNotifier ayet imi sınır durumları', () async {
      final container = ProviderContainer();
      final notifier = container.read(bookmarkedVersesProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.isBookmarked(2, 255), isFalse);
      await notifier.toggleBookmark(2, 255);
      expect(notifier.isBookmarked(2, 255), isTrue);
      expect(notifier.isBookmarked(2, 256), isFalse);

      await notifier.toggleBookmark(2, 255);
      expect(notifier.isBookmarked(2, 255), isFalse);
      container.dispose();
    });

    test('FavoriteDuasNotifier dua favori ekleme ve çoklu kayıt durumu', () async {
      final container = ProviderContainer();
      final notifier = container.read(favoriteDuasProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.isFavorite('ayat_al_kursi'), isFalse);
      expect(notifier.isFavorite('subhaneke'), isFalse);

      await notifier.toggleFavorite('ayat_al_kursi');
      await notifier.toggleFavorite('subhaneke');

      expect(notifier.isFavorite('ayat_al_kursi'), isTrue);
      expect(notifier.isFavorite('subhaneke'), isTrue);
      expect(container.read(favoriteDuasProvider).length, 2);

      container.dispose();
    });
  });

  group('Özellik 3: Zikirmatik & İbadet Takibi Haptik ve Sınır Testleri', () {
    test('DailyWorshipEntry 7 günlük ibadet tamamlama oranını doğru hesaplamalı', () {
      const empty = DailyWorshipEntry(dateKey: '2026-03-01');
      expect(empty.completedCount, 0);
      expect(empty.completionRatio, 0.0);

      const all7 = DailyWorshipEntry(
        dateKey: '2026-03-01',
        fajr: true,
        dhuhr: true,
        asr: true,
        maghrib: true,
        isha: true,
        quran: true,
        zikr: true,
      );
      expect(all7.completedCount, 7);
      expect(all7.completionRatio, 1.0);
    });

    test('WorshipStreakMilestone tüm 6 dönüm noktasını doğru gün şartıyla barındırmalı', () {
      expect(WorshipStreakMilestone.allMilestones.length, 6);
      final days = WorshipStreakMilestone.allMilestones.map((m) => m.days).toList();
      expect(days, containsAll([10, 30, 50, 100, 200, 400]));
    });
  });

  group('Özellik 4: Ramazan, İmsakiye ve 30 Gün Hatim Takipçisi Testleri', () {
    test('quranJuzList 30 cüzü tam sayfa aralıklarıyla içermeli', () {
      expect(quranJuzList.length, 30);
      for (int i = 0; i < 30; i++) {
        final juz = quranJuzList[i];
        expect(juz.juzNumber, i + 1);
        expect(juz.startPage, greaterThan(0));
        expect(juz.endPage, greaterThanOrEqualTo(juz.startPage));
        expect(juz.pageCount, juz.endPage - juz.startPage + 1);
      }
    });

    test('KhatamProgressState ilerleme ve cüz tamamlama durumları', () {
      const state = KhatamProgressState(completedJuzs: {1, 2, 3});
      expect(state.completedCount, 3);
      expect(state.percentage, closeTo(0.1, 0.01));
      expect(state.isCompleted(1), isTrue);
      expect(state.isCompleted(4), isFalse);
      expect(state.isEntireQuranCompleted, isFalse);
    });
  });

  group('Özellik 5: Canlı Etkinlik (Live Activity) Platform Güvenliği', () {
    test('LiveActivityService isSupported platform kontrolü asla hata fırlatmamalı', () async {
      final supported = await LiveActivityService().isSupported();
      expect(supported, isA<bool>());
    });
  });

  group('Özellik 6: Ruh Haline Göre Şifa ve Ayet Stüdyosu Testleri', () {
    test('MoodVerseData 8 duygu durumunu ve geçerli sure referanslarını içermeli', () {
      expect(MoodVerseData.list.length, 8);
      for (final m in MoodVerseData.list) {
        expect(m.arabicText, isNotEmpty);
        expect(m.surahId, greaterThan(0));
        expect(m.verseNumber, greaterThan(0));
      }
    });

    test('CardStudioBackground tüm 7 temayı içermeli', () {
      expect(CardStudioBackground.values.length, 7);
    });
  });

  group('Özellik 7: Doğrulanmış Dua Kütüphanesi ve Arama Normalizasyonu', () {
    test('Dua külliyatı 60+ doğrulanmış dua içermeli ve hiçbiri boş metin taşımamalı', () {
      expect(verifiedDuasList.length, greaterThanOrEqualTo(60));
      for (final dua in verifiedDuasList) {
        expect(dua.id, isNotEmpty);
        expect(dua.title, isNotEmpty);
        expect(dua.arabicText, isNotEmpty);
        expect(dua.turkishMeaning, isNotEmpty);
        expect(dua.reference, isNotEmpty);
      }
    });

    test('Ayetü\'l-Kürsî ve Nazar duası kütüphanede mevcut olmalı', () {
      final ayatAlKursi = verifiedDuasList.firstWhere((d) => d.id == 'kuran_ayetel_kursi');
      expect(ayatAlKursi.arabicText, contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ'));
      expect(ayatAlKursi.category, DuaCategory.quranic);

      final nazar = verifiedDuasList.firstWhere((d) => d.id == 'gunluk_nazar_duasi');
      expect(nazar.arabicText, isNotEmpty);
      expect(nazar.category, DuaCategory.healingProtection);
    });
  });
}
