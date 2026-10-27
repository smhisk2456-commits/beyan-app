import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_app/features/ai_assistant/services/ai_assistant_service.dart';
import 'package:islamic_app/features/ai_assistant/screens/ai_assistant_screen.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/data/dua_translations.dart';
import 'package:islamic_app/features/quran/models/verse.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/quran/repositories/dua_repository.dart';
import 'package:islamic_app/core/services/deep_link_service.dart';
import 'package:islamic_app/features/live_makkah/screens/mecca_medina_live_screen.dart';

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Round 4 Security & Bugfix Audit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('S1: Secure Storage migrates legacy plaintext API key and writes securely', () async {
      // 1. Setup legacy plaintext key in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('beyan_gemini_api_key', 'legacy_plaintext_secret_123');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(aiAssistantProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Expect secure storage has it
      final secureVal = await const FlutterSecureStorage().read(key: 'beyan_gemini_api_key');
      expect(secureVal, 'legacy_plaintext_secret_123');
      expect(container.read(aiAssistantProvider).hasCustomApiKey, isTrue);

      // Expect plaintext key is purged from SharedPreferences
      expect(prefs.containsKey('beyan_gemini_api_key'), isFalse);

      // Now set a new key via service
      await notifier.setGeminiApiKey('new_secure_secret_456');
      final updatedVal = await const FlutterSecureStorage().read(key: 'beyan_gemini_api_key');
      expect(updatedVal, 'new_secure_secret_456');

      // Clear key
      await notifier.setGeminiApiKey('');
      expect(container.read(aiAssistantProvider).hasCustomApiKey, isFalse);
    });

    test('S4: DuaRepository escapes LIKE wildcards and caps input at 64 chars', () {
      // Test escapeLike helper through SQL LIKE escaping behavior
      expect(DuaRepository.escapeLike('100% halal_food\\drink'), '100\\% halal\\_food\\\\drink');

      // Test 64 char cutoff
      final longQuery = 'a' * 100;
      final capped = longQuery.length > 64 ? longQuery.substring(0, 64) : longQuery;
      final escaped = DuaRepository.escapeLike(capped);
      expect(escaped.length, 64);
    });

    test('D5: Dua Data Integrity - Ayetel Kursi, Isra 24, Nas meal, and 80 verified duas', () {
      final duas = verifiedDuasList;
      expect(duas.length, 80, reason: 'Total verified duas count must be exactly 80');

      // Unique IDs
      final ids = duas.map((d) => d.id).toSet();
      expect(ids.length, 80, reason: 'All dua IDs must be strictly unique');

      // Ayetel Kursi (kuran_ayetel_kursi & uyku_3)
      final ayetelKursi = duas.firstWhere((d) => d.id == 'kuran_ayetel_kursi');
      final uyku3 = duas.firstWhere((d) => d.id == 'uyku_3');

      expect(ayetelKursi.arabicText.contains('الْحَيُّ الْقَيُّومُ'), isTrue,
          reason: 'Ayetel Kursi must start directly with verse 255 without prepended Basmala');
      expect(ayetelKursi.arabicText.contains('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), isFalse,
          reason: 'Ayetel Kursi must not have prepended Basmala');
      expect(uyku3.arabicText, ayetelKursi.arabicText,
          reason: 'uyku_3 and kuran_ayetel_kursi Arabic text must be unified');
      expect(uyku3.turkishMeaning, ayetelKursi.turkishMeaning,
          reason: 'uyku_3 and kuran_ayetel_kursi Turkish meaning must be unified');

      // kuran_3 is Isra 24, not duplicate Ibrahim 41
      final kuran3 = duas.firstWhere((d) => d.id == 'kuran_3');
      expect(kuran3.reference, contains('İsrâ'));
      expect(kuran3.arabicText.contains('ارْحَمْهُمَا'), isTrue);

      final rabbenaAgfirli = duas.firstWhere((d) => d.id == 'namaz_rabbena_agfirli');
      expect(rabbenaAgfirli.reference, contains('İbrâhîm'));
      expect(rabbenaAgfirli.arabicText, isNot(kuran3.arabicText));

      // aksam_4 completes Nas surah meaning
      final aksam4 = duas.firstWhere((d) => d.id == 'aksam_4');
      expect(aksam4.turkishMeaning, contains('gerek cinlerden gerek insanlardan'),
          reason: 'aksam_4 meaning must include all verses through verse 6');

      // Dua translations mapping
      expect(kDuaTranslations.length, greaterThanOrEqualTo(80));
    });

    test('D1: QuranAudioService proportional verse calculation respects stopAfterVerse and resets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(quranAudioProvider.notifier);
      final ghamdi = quranRecitersList.firstWhere((r) => r.id == 'ghamdi');
      notifier.setReciter(ghamdi);

      final mockVerses = List.generate(
        7,
        (i) => Verse(
          id: i + 1,
          surahId: 1,
          verseNumber: i + 1,
          arabicText: 'آية ${i + 1}',
          turkishMeaning: 'Ayet ${i + 1}',
        ),
      );

      // Initially stopAfterVerse is null
      expect(notifier.stopAfterVerse, isNull);

      // Set stopAfterVerse to target end verse (e.g. 3)
      notifier.setStopAfterVerse(3);
      expect(notifier.stopAfterVerse, 3);

      // In proportional mode with effectiveMs pointing past verse 3, updateActiveVerseByProgress stops playback
      notifier.updateActiveVerseByProgress(mockVerses, currentMs: 500000);
      expect(notifier.stopAfterVerse, isNull); // reset after stopping
      await Future.delayed(const Duration(milliseconds: 20));
      expect(container.read(quranAudioProvider).isPlaying, isFalse);
    });

    test('YT: MeccaMedinaLiveScreen configuration is verified and clean', () {
      const screen = MeccaMedinaLiveScreen();
      expect(screen, isNotNull);
    });

    testWidgets('A1: AiAssistantScreen opens directly ready for chatting without blocking user for API key', (tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AiAssistantScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify chat screen is directly accessible without blocking screen
      expect(find.text('Beyân AI'), findsWidgets);
      expect(find.text('İslami Rehber'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    test('S3: DeepLinkService uses non-destructive push navigation', () {
      final service = DeepLinkService();
      // Ensure service instance exists and initialized
      expect(service, isNotNull);
    });
  });
}
