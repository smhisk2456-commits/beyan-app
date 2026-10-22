import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/dua/models/morning_evening_adhkar_model.dart';
import 'package:islamic_app/features/quran/providers/quran_reading_providers.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Sabah & Akşam Duaları (Hısnu\'l-Müslim) Testleri', () {
    test('verifiedMorningEveningAdhkar listesi tüm temel virdleri içermelidir', () {
      expect(verifiedMorningEveningAdhkar.isNotEmpty, isTrue);
      expect(verifiedMorningEveningAdhkar.length, greaterThanOrEqualTo(10));

      final ayetelKursi = verifiedMorningEveningAdhkar.firstWhere((a) => a.id == 'adhkar_ayetel_kursi');
      expect(ayetelKursi.targetCount, 1);
      expect(ayetelKursi.timeType, AdhkarTimeType.both);

      final seyyidulIstigfar = verifiedMorningEveningAdhkar.firstWhere((a) => a.id == 'adhkar_seyyidul_istigfar');
      expect(seyyidulIstigfar.targetCount, 1);
      expect(seyyidulIstigfar.timeType, AdhkarTimeType.both);

      final bismillahillezi = verifiedMorningEveningAdhkar.firstWhere((a) => a.id == 'adhkar_bismillahillezi');
      expect(bismillahillezi.targetCount, 3);
    });

    test('Sabah ve Akşam filtreleri virdleri doğru ayırmalıdır', () {
      final morningList = verifiedMorningEveningAdhkar.where((item) {
        return item.timeType == AdhkarTimeType.morning || item.timeType == AdhkarTimeType.both;
      }).toList();

      final eveningList = verifiedMorningEveningAdhkar.where((item) {
        return item.timeType == AdhkarTimeType.evening || item.timeType == AdhkarTimeType.both;
      }).toList();

      expect(morningList.isNotEmpty, isTrue);
      expect(eveningList.isNotEmpty, isTrue);

      // Sadece sabah olan vird akşam listesinde olmamalı
      expect(eveningList.any((a) => a.id == 'adhkar_sabah_asbahna'), isFalse);
      // Sadece akşam olan vird sabah listesinde olmamalı
      expect(morningList.any((a) => a.id == 'adhkar_aksam_emseyna'), isFalse);
    });

    test('AdhkarItem çoklu dil lokalizasyonu doğru metinleri dönmelidir', () {
      final item = verifiedMorningEveningAdhkar.first;

      expect(item.localizedTitle('tr'), item.titleTr);
      expect(item.localizedTitle('en'), item.titleEn);
      expect(item.localizedTitle('ar'), item.titleAr);

      expect(item.localizedMeaning('tr'), item.meaningTr);
      expect(item.localizedMeaning('en'), item.meaningEn);

      expect(item.localizedVirtue('tr'), item.virtueTr);
      expect(item.localizedVirtue('en'), item.virtueEn);
    });
  });

  group('Ezber & Hafızlık Asistanı (Kelimeleri Gizle & Hatırla) Testleri', () {
    test('QuranMemorizationNotifier aktiflik ve kelime açma işlemlerini doğru yönetmeli', () {
      final notifier = QuranMemorizationNotifier();

      expect(notifier.state.isActive, isFalse);
      expect(notifier.state.revealedWordsByVerse.isEmpty, isTrue);

      // Modu aç
      notifier.toggleMode();
      expect(notifier.state.isActive, isTrue);

      // 1. Ayetin 2. kelimesini aç
      notifier.revealWord(1, 2);
      expect(notifier.state.revealedWordsByVerse[1]?.contains(2), isTrue);
      expect(notifier.state.revealedWordsByVerse[1]?.contains(0), isFalse);

      // Ayetteki tüm kelimeleri aç
      notifier.revealAllInVerse(1, 4);
      expect(notifier.state.revealedWordsByVerse[1]?.length, 4);

      // Ayetteki tüm kelimeleri tekrar gizle
      notifier.hideAllInVerse(1);
      expect(notifier.state.revealedWordsByVerse[1], isNull);

      // Modu kapat
      notifier.toggleMode();
      expect(notifier.state.isActive, isFalse);
    });

    test('ComparativeMealNotifier durum toggle ve başlangıç kontrolü', () async {
      final notifier = ComparativeMealNotifier();
      expect(notifier.state, isFalse);

      await notifier.toggle();
      expect(notifier.state, isTrue);

      await notifier.toggle();
      expect(notifier.state, isFalse);
    });
  });

  group('Kur\'an Tilaveti Döngü, Ambiyans ve Uyku Zamanlayıcısı Testleri', () {
    test('Döngü / Tekrar modu (cycleLoopRepeat) döngüsel olarak ilerlemeli', () {
      final notifier = QuranAudioNotifier();

      expect(notifier.state.loopRepeatCount, 1);

      // 1 -> 3
      notifier.cycleLoopRepeat();
      expect(notifier.state.loopRepeatCount, 3);

      // 3 -> 5
      notifier.cycleLoopRepeat();
      expect(notifier.state.loopRepeatCount, 5);

      // 5 -> 10
      notifier.cycleLoopRepeat();
      expect(notifier.state.loopRepeatCount, 10);

      // 10 -> -1 (Sonsuz)
      notifier.cycleLoopRepeat();
      expect(notifier.state.loopRepeatCount, -1);

      // -1 -> 1 (Normal)
      notifier.cycleLoopRepeat();
      expect(notifier.state.loopRepeatCount, 1);
    });

    test('Tek âyet döngüsü (setLoopVerse) doğru ayarlanmalı ve temizlenmeli', () {
      final notifier = QuranAudioNotifier();

      notifier.setLoopVerse(255);
      expect(notifier.state.loopVerseNumber, 255);
      expect(notifier.state.currentLoopIteration, 1);

      notifier.setLoopVerse(null);
      expect(notifier.state.loopVerseNumber, isNull);
    });

    test('Ambiyans sesleri (setAmbience & setAmbienceVolume) durumu doğru güncellemeli', () async {
      final notifier = QuranAudioNotifier();

      expect(notifier.state.activeAmbience, isNull);

      await notifier.setAmbience('rain');
      expect(notifier.state.activeAmbience, 'rain');

      await notifier.setAmbienceVolume(0.7);
      expect(notifier.state.ambienceVolume, 0.7);

      await notifier.setAmbience(null);
      expect(notifier.state.activeAmbience, isNull);
    });

    test('Uyku Zamanlayıcısı (startSleepTimer & cancelSleepTimer) doğru başlamalı ve iptal edilmeli', () {
      final notifier = QuranAudioNotifier();

      notifier.startSleepTimer(30);
      expect(notifier.state.sleepTimerMinutes, 30);
      expect(notifier.state.sleepTimerSecondsRemaining, 1800);

      notifier.cancelSleepTimer();
      expect(notifier.state.sleepTimerMinutes, isNull);
      expect(notifier.state.sleepTimerSecondsRemaining, isNull);
    });
  });
}
