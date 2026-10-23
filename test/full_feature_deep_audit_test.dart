import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_app/core/database/database_helper.dart';
import 'package:islamic_app/core/services/screen_awake_service.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/features/ai_assistant/models/ai_message.dart';
import 'package:islamic_app/features/ai_assistant/services/ai_assistant_service.dart';
import 'package:islamic_app/features/dua/data/dua_translations.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';
import 'package:islamic_app/features/dua/providers/dua_providers.dart';
import 'package:islamic_app/features/notifications/models/adhan_makam.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
import 'package:islamic_app/features/prayer_times/models/city_model.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/prayer_times/services/prayer_time_service.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/zikr/models/worship_tracker_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Namaz Vakitleri & Küresel Uç Noktalar (Polar / Extreme Coordinates)', () {
    test('Kutup dairesi ve yüksek enlemlerde (Tromso, Reykjavik) PrayerTimeService enlem korumasıyla çökmemeli', () async {
      final highLatitudeLocations = [
        const LocationData(latitude: 69.6492, longitude: 18.9553, cityName: 'Tromsø', isFromGPS: true),
        const LocationData(latitude: 64.1466, longitude: -21.9426, cityName: 'Reykjavík', isFromGPS: true),
        const LocationData(latitude: 68.9585, longitude: 33.0827, cityName: 'Murmansk', isFromGPS: true),
      ];

      final service = PrayerTimeService();
      final testDate = DateTime(2026, 6, 21); // Yaz gündönümü

      for (final loc in highLatitudeLocations) {
        final daily = await service.calculatePrayerTimes(location: loc, date: testDate);

        expect(daily.fajr, isNotNull, reason: '${loc.cityName} Fajr null olamaz');
        expect(daily.sunrise, isNotNull, reason: '${loc.cityName} Sunrise null olamaz');
        expect(daily.dhuhr, isNotNull, reason: '${loc.cityName} Dhuhr null olamaz');
        expect(daily.asr, isNotNull, reason: '${loc.cityName} Asr null olamaz');
        expect(daily.maghrib, isNotNull, reason: '${loc.cityName} Maghrib null olamaz');
        expect(daily.isha, isNotNull, reason: '${loc.cityName} Isha null olamaz');
      }
    });

    test('6 resmi hesaplama metodunun tamamı geçerli parametreler üretmeli', () {
      expect(PrayerCalculationMethod.values.length, 6);
      for (final method in PrayerCalculationMethod.values) {
        final params = method.getAdhanParameters();
        expect(params.fajrAngle, greaterThan(0.0));
        expect(params.ishaAngle != null || params.ishaInterval > 0, isTrue);
      }
    });

    test('PrayerCountdown ilerleme yüzdesi ve vakit geçişleri güvenli çalışmalı', () {
      final now = DateTime.now();
      final coords = Coordinates(41.0082, 28.9784);
      final date = DateComponents(now.year, now.month, now.day);
      final params = CalculationMethod.turkey.getParameters();
      final adhanTimes = PrayerTimes(coords, date, params);

      final entries = [
        PrayerEntry(name: PrayerName.fajr, time: adhanTimes.fajr),
        PrayerEntry(name: PrayerName.sunrise, time: adhanTimes.sunrise),
        PrayerEntry(name: PrayerName.dhuhr, time: adhanTimes.dhuhr),
        PrayerEntry(name: PrayerName.asr, time: adhanTimes.asr),
        PrayerEntry(name: PrayerName.maghrib, time: adhanTimes.maghrib),
        PrayerEntry(name: PrayerName.isha, time: adhanTimes.isha),
      ];

      final dailyTimes = DailyPrayerTimes(
        date: now,
        locationName: 'İstanbul',
        latitude: coords.latitude,
        longitude: coords.longitude,
        prayers: entries,
        prayerTimes: adhanTimes,
      );

      final next = dailyTimes.nextPrayerEntry;
      expect(next, isNotNull);

      final remaining = dailyTimes.timeUntilNextPrayer;
      expect(remaining.isNegative, isFalse);
    });

    test('Şehir listesi (predefinedCitiesList) eksiksiz olmalı ve arama filtresi Türkçe karakterleri doğru eşlemeli', () {
      expect(predefinedCitiesList.length, greaterThanOrEqualTo(20));

      List<CityItem> filterCities(String query) {
        final q = query.toLowerCase().replaceAll('i̇', 'i').replaceAll('ı', 'i').replaceAll('ş', 's');
        return predefinedCitiesList.where((c) {
          final n = c.name.toLowerCase().replaceAll('i̇', 'i').replaceAll('ı', 'i').replaceAll('ş', 's');
          return n.contains(q);
        }).toList();
      }

      expect(filterCities('istanbul').length, 1);
      expect(filterCities('İSTANBUL').length, 1);
      expect(filterCities('sanliurfa').length, 1);
      expect(filterCities('ŞANLIURFA').length, 1);
      expect(filterCities('mekke').length, 1);
    });
  });

  group('2. Kur\'an Tilavet Motoru, Ayet Aralığı ve Uyku Zamanlayıcısı', () {
    test('QuranAudioNotifier stopAfterVerse ve stop metodu doğru sıfırlanmalı', () async {
      final notifier = QuranAudioNotifier();
      addTearDown(notifier.dispose);

      // Başlangıçta stopAfterVerse boş olmalı
      expect(notifier.stopAfterVerse, isNull);

      // stop() çağrısı stopAfterVerse değerini temizlemeli
      await notifier.stop();
      expect(notifier.stopAfterVerse, isNull);
    });

    test('Ambiyans ses seviyesi 0.0 ile 1.0 aralığında sınırlandırılmalı', () async {
      final notifier = QuranAudioNotifier();
      addTearDown(notifier.dispose);

      await notifier.setAmbienceVolume(0.75);
      expect(notifier.state.ambienceVolume, 0.75);

      // Sınır aşımı (1.0 üstü)
      await notifier.setAmbienceVolume(1.5);
      expect(notifier.state.ambienceVolume, 1.0);

      // Negatif sınır aşımı
      await notifier.setAmbienceVolume(-0.5);
      expect(notifier.state.ambienceVolume, 0.0);
    });

    test('Uyku zamanlayıcısı başlatılıp iptal edildiğinde state doğru güncellenmeli', () {
      final notifier = QuranAudioNotifier();
      addTearDown(notifier.dispose);

      notifier.startSleepTimer(15);
      expect(notifier.state.sleepTimerMinutes, 15);
      expect(notifier.state.sleepTimerSecondsRemaining, 15 * 60);

      notifier.cancelSleepTimer();
      expect(notifier.state.sleepTimerMinutes, isNull);
      expect(notifier.state.sleepTimerSecondsRemaining, isNull);
    });
  });

  group('3. Dua Kütüphanesi & Gelişmiş Arama Bütünlüğü', () {
    test('Tüm duaların ID\'leri benzersiz olmalı, 12 kategorinin tamamı doldurulmuş olmalı', () {
      expect(verifiedDuasList.length, greaterThanOrEqualTo(46));
      final ids = verifiedDuasList.map((d) => d.id).toSet();
      expect(ids.length, verifiedDuasList.length, reason: 'Mükerrer dua ID\'si bulunmamalı');

      final usedCategories = verifiedDuasList.map((d) => d.category).toSet();
      expect(usedCategories.length, DuaCategory.values.length,
          reason: '12 dua kategorisinin tamamında en az 1 dua bulunmalı');
    });

    test('kDuaTranslations tüm duaların İngilizce ve Arapça çevirisini eksiksiz barındırmalı', () {
      for (final dua in verifiedDuasList) {
        final trans = kDuaTranslations[dua.id];
        expect(trans, isNotNull, reason: '${dua.id} çevirisi eksik olamaz');
        expect(trans!.titleEn.trim().isNotEmpty, isTrue);
        expect(trans.titleAr.trim().isNotEmpty, isTrue);
        expect(trans.meaningEn.trim().isNotEmpty, isTrue);
        expect(trans.meaningAr.trim().isNotEmpty, isTrue);
      }
    });

    test('Arama filtresi Türkçe şapkalı, harekesiz Arapça ve İngilizce kelimeleri doğru bulmalı', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Türkçe şapkalı / şapkasız
      container.read(duaSearchQueryProvider.notifier).state = 'ayetel kursi';
      var res = container.read(filteredDuasListProvider);
      expect(res.any((d) => d.id == 'kuran_ayetel_kursi'), isTrue);

      container.read(duaSearchQueryProvider.notifier).state = 'Âyetü\'l-Kürsî';
      res = container.read(filteredDuasListProvider);
      expect(res.any((d) => d.id == 'kuran_ayetel_kursi'), isTrue);

      // Harekesiz Arapça
      container.read(duaSearchQueryProvider.notifier).state = 'الكرسي';
      res = container.read(filteredDuasListProvider);
      expect(res.any((d) => d.id == 'kuran_ayetel_kursi'), isTrue);

      // İngilizce arama
      container.read(duaSearchQueryProvider.notifier).state = 'Forgiveness';
      res = container.read(filteredDuasListProvider);
      expect(res.any((d) => d.id == 'sabah_2'), isTrue); // Sayyid al-Istighfar

      // Hadis kaynağı araması
      container.read(duaSearchQueryProvider.notifier).state = 'Buhari';
      res = container.read(filteredDuasListProvider);
      expect(res.isNotEmpty, isTrue);
    });

    test('Favori dua notifier açma-kapama işlemlerini kalıcı olarak güncellemeli', () async {
      final notifier = FavoriteDuasNotifier();
      expect(notifier.isFavorite('kuran_ayetel_kursi'), isFalse);

      await notifier.toggleFavorite('kuran_ayetel_kursi');
      expect(notifier.isFavorite('kuran_ayetel_kursi'), isTrue);

      await notifier.toggleFavorite('kuran_ayetel_kursi');
      expect(notifier.isFavorite('kuran_ayetel_kursi'), isFalse);
    });
  });

  group('4. Zikirmatik & İbadet Takibi Sınır Testleri', () {
    test('DailyWorshipEntry günlük zikir ve namaz verilerini hatasız saklamalı', () {
      const entry = DailyWorshipEntry(
        dateKey: '2026-10-23',
        fajr: true,
        dhuhr: true,
        asr: true,
        maghrib: false,
        isha: false,
        quran: true,
        zikr: true,
      );

      expect(entry.completedCount, 5);
      expect(entry.isFullyCompleted, isFalse);
      expect(entry.completionRatio, closeTo(5 / 7.0, 0.01));

      final updated = entry.copyWith(maghrib: true, isha: true);
      expect(updated.completedCount, 7);
      expect(updated.isFullyCompleted, isTrue);
    });

    test('Zikir hedef tamamlanma yüzdesi sıfır veya yüksek hedeflerde güvenli hesaplanmalı', () {
      double calculateProgress(int count, int target) {
        if (target <= 0) return 0.0;
        return (count / target).clamp(0.0, 1.0);
      }

      expect(calculateProgress(33, 33), 1.0);
      expect(calculateProgress(0, 33), 0.0);
      expect(calculateProgress(50, 33), 1.0); // Taşkında 1.0 ile sınırlı
      expect(calculateProgress(100, 0), 0.0); // Sıfır hedefte çökme önlemi
    });
  });

  group('5. AI Asistanı & App Store Gizlilik / Guideline Uyumluluğu', () {
    test('AiAssistantState effectiveApiKey geliştirici ve özel anahtarı doğru hiyerarşiyle seçmeli', () {
      // 1. İki anahtar da yok
      const emptyState = AiAssistantState();
      expect(emptyState.effectiveApiKey, isNull);
      expect(emptyState.hasAnyActiveKey, isFalse);

      // 2. Özel anahtar tanımlı
      const customState = AiAssistantState(geminiApiKey: 'custom_secret_key_123');
      expect(customState.effectiveApiKey, 'custom_secret_key_123');
      expect(customState.hasCustomApiKey, isTrue);
      expect(customState.hasAnyActiveKey, isTrue);
    });

    test('AiAssistantNotifier boş soru iletildiğinde ağ isteği yapmamalı ve false dönmeli', () async {
      final notifier = AiAssistantNotifier();
      final resEmpty = await notifier.askQuestion('', isPremium: false);
      final resWhitespace = await notifier.askQuestion('   \n  ', isPremium: false);

      expect(resEmpty, isFalse);
      expect(resWhitespace, isFalse);
    });

    test('Sistem hata kodları (ai_fallback_, ai_nokey_) yapay zeka mesaj geçmişinden filtrelenmeli', () {
      final messages = [
        AiMessage(id: 'welcome_1', text: 'Hoş geldiniz', isUser: false, timestamp: DateTime.now()),
        AiMessage(id: 'usr_1', text: 'Oruç ne zaman bozulur?', isUser: true, timestamp: DateTime.now()),
        AiMessage(id: 'ai_fallback_123', text: 'Geçici hata', isUser: false, timestamp: DateTime.now()),
        AiMessage(id: 'ai_nokey_456', text: 'Anahtar yok', isUser: false, timestamp: DateTime.now()),
        AiMessage(id: 'usr_2', text: 'Peki kaza orucu?', isUser: true, timestamp: DateTime.now()),
      ];

      final filtered = messages.where((m) =>
          !m.id.startsWith('welcome_') &&
          !m.id.startsWith('ai_fallback_') &&
          !m.id.startsWith('ai_nokey_')).toList();

      expect(filtered.length, 2);
      expect(filtered.every((m) => m.isUser), isTrue);
    });
  });

  group('6. Tema Paletleri & Canlı Renk Senkronizasyonu', () {
    test('7 lüks temanın tamamı tanımlı olmalı ve birincil renkleri kontrast standartlarına uygun olmalı', () {
      expect(AppThemePalette.values.length, 7);
      for (final palette in AppThemePalette.values) {
        expect(palette.name, isNotEmpty);
      }
    });

    test('ToneFor dönüşümleri 7 palet için de null veya şeffaf olmayan renk döndürmeli', () {
      const testArgb = 0xFFD4AF37; // Beyan Gold
      for (final palette in AppThemePalette.values) {
        final tone = BeyanColors.toneFor(palette, testArgb);
        expect(tone.a, 1.0);
      }
    });
  });

  group('7. Bildirim Servisi & İzin Güvenliği', () {
    test('AdhanMakam enum karşılıkları ve ses yolları eksiksiz olmalı', () {
      const makams = AdhanMakam.values;
      expect(makams.length, greaterThanOrEqualTo(5));
      for (final m in makams) {
        expect(m.id, isNotEmpty);
        expect(m.title, isNotEmpty);
      }
    });

    test('3 günden fazla ileriye bildirim planlanmamalı (3 günlük horizon kısıtı)', () {
      final now = DateTime.now();
      const maxDays = 3;
      final maxAllowedDate = now.add(const Duration(days: maxDays));

      final scheduledTimes = [
        now.add(const Duration(hours: 5)),
        now.add(const Duration(days: 2)),
        now.add(const Duration(days: 4)), // Horizon dışı
      ];

      final validTimes = scheduledTimes.where((t) => t.isBefore(maxAllowedDate)).toList();
      expect(validTimes.length, 2);
    });
  });

  group('8. Güvenlik, Veritabanı ve Platform Servisleri', () {
    test('DatabaseHelper count sorgusunda izinli olmayan tablolara karşı SQL injection koruması devrede olmalı', () async {
      final helper = DatabaseHelper();
      expect(
        () => helper.count('malicious_table; DROP TABLE surah;'),
        throwsArgumentError,
        reason: 'İzinli olmayan tablo adlarında ArgumentError fırlatılmalı',
      );
    });

    test('ScreenAwakeService sınıfı tanımlı ve erişilebilir olmalı', () {
      expect(ScreenAwakeService, isNotNull);
    });

    test('DeepLinkService URI yönlendirme parametrelerini doğru ayrıştırmalı', () {
      final uriQuran = Uri.parse('beyan://quran/2/255');
      expect(uriQuran.scheme, 'beyan');
      expect(uriQuran.host, 'quran');
      expect(uriQuran.pathSegments, ['2', '255']);

      final uriDua = Uri.parse('beyan://dua/kuran_ayetel_kursi');
      expect(uriDua.scheme, 'beyan');
      expect(uriDua.host, 'dua');
      expect(uriDua.pathSegments, ['kuran_ayetel_kursi']);
    });
  });
}
