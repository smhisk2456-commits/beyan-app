import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/features/quran/models/verse.dart';
import 'package:islamic_app/features/quran/services/quran_audio_service.dart';
import 'package:islamic_app/features/ai_assistant/services/ai_assistant_service.dart';
import 'package:islamic_app/features/ai_assistant/models/ai_message.dart';
import 'package:islamic_app/features/elif_ba/models/elif_ba_letter.dart';
import 'package:islamic_app/features/elif_ba/models/elif_ba_lesson.dart';
import 'package:islamic_app/features/elif_ba/services/elif_ba_progress_service.dart';
import 'package:islamic_app/features/elif_ba/services/elif_ba_audio_service.dart';
import 'package:islamic_app/features/widget_service/screens/live_activity_settings_sheet.dart';

import 'package:flutter/services.dart';

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

  group('Kur\'an Tilavet Canlı Ayet Takibi (Karaoke) Testleri', () {
    test('QuranAudioState varsayılan değerleri ve copyWith doğru çalışmalı', () {
      final state = QuranAudioState(selectedReciter: quranRecitersList.first);
      expect(state.isPlaying, isFalse);
      expect(state.activeVerseNumber, isNull);
      expect(state.isLiveTrackingEnabled, isTrue);

      final updated = state.copyWith(
        activeVerseNumber: 5,
        isLiveTrackingEnabled: false,
      );
      expect(updated.activeVerseNumber, 5);
      expect(updated.isLiveTrackingEnabled, isFalse);

      final cleared = updated.copyWith(clearActiveVerse: true);
      expect(cleared.activeVerseNumber, isNull);
    });

    test('updateActiveVerseByProgress ayet metin ağırlıklarına göre doğru ayeti belirlemeli', () {
      final notifier = QuranAudioNotifier();

      final mockVerses = [
        const Verse(
          id: 1,
          surahId: 1,
          verseNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          turkishMeaning: 'Rahmân ve Rahîm olan Allah\'ın adıyla.',
        ),
        const Verse(
          id: 2,
          surahId: 1,
          verseNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          turkishMeaning: 'Hamd, âlemlerin Rabbi Allah\'a aittir.',
        ),
        const Verse(
          id: 3,
          surahId: 1,
          verseNumber: 3,
          arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
          turkishMeaning: 'O, Rahmândır, Rahîmdir.',
        ),
      ];

      // Durumu simüle et: toplam süre 60 saniye, şu anki konum 5. saniye (1. ayet aralığı)
      notifier.state = notifier.state.copyWith(
        duration: const Duration(seconds: 60),
        position: const Duration(seconds: 5),
      );

      notifier.updateActiveVerseByProgress(mockVerses);
      expect(notifier.state.activeVerseNumber, 1);

      // İlerleme: 30. saniyede (2. ayet aralığı)
      notifier.state = notifier.state.copyWith(
        position: const Duration(seconds: 30),
      );
      notifier.updateActiveVerseByProgress(mockVerses);
      expect(notifier.state.activeVerseNumber, 2);

      // Canlı takip açık/kapalı anahtarı çalışmalı
      notifier.toggleLiveTracking();
      expect(notifier.state.isLiveTrackingEnabled, isFalse);
      notifier.toggleLiveTracking();
      expect(notifier.state.isLiveTrackingEnabled, isTrue);

      notifier.dispose();
    });
  });

  group('Beyân AI Manevi Rehber & Tefsir Asistanı Testleri', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AiMessage JSON serileştirme ve ters serileştirme doğru çalışmalı', () {
      final msg = AiMessage(
        id: 'msg_1',
        text: 'Rad Suresi 28: Kalpler ancak Allah\'ı anmakla huzur bulur.',
        isUser: false,
        timestamp: DateTime(2026, 10, 19, 12, 0),
        references: const ['Rad Sûresi 28'],
        suggestedFollowUps: const ['Huzur duaları'],
      );

      final json = msg.toJson();
      final fromJson = AiMessage.fromJson(json);

      expect(fromJson.id, msg.id);
      expect(fromJson.text, msg.text);
      expect(fromJson.isUser, isFalse);
      expect(fromJson.references, ['Rad Sûresi 28']);
      expect(fromJson.suggestedFollowUps, ['Huzur duaları']);
    });

    test('AiAssistantNotifier ücretsiz kullanıcılarda günlük 3 soru kotasını takip etmeli', () async {
      final notifier = AiAssistantNotifier();

      // Başlangıç kotası 3 olmalı
      final remainingInitial = await notifier.getRemainingQuota(false);
      expect(remainingInitial, 3);

      // 1. soru sorulur
      final res1 = await notifier.askQuestion('Kalp huzuru için ne yapmalıyım?', isPremium: false);
      expect(res1, isTrue);

      final remainingAfter1 = await notifier.getRemainingQuota(false);
      expect(remainingAfter1, 2);

      // Premium kullanıcı için sınırsız kota dönmeli
      final premiumQuota = await notifier.getRemainingQuota(true);
      expect(premiumQuota, 999);
      expect(await notifier.canAskQuestion(true), isTrue);
    });
  });

  group('Sesli Elif-Bâ & Dua Eğitimi (Duolingo Stili) Testleri', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('28 Arapça harf tam ve doğru tanımlanmış olmalı', () {
      expect(elifBaLettersList.length, 28);

      final elif = elifBaLettersList.first;
      expect(elif.id, 1);
      expect(elif.arabic, 'ا');
      expect(elif.nameTr, 'Elif');
      expect(elif.mahraj.isNotEmpty, isTrue);
      expect(elif.isolated.isNotEmpty, isTrue);
      expect(elif.initial.isNotEmpty, isTrue);

      final be = elifBaLettersList[1];
      expect(be.id, 2);
      expect(be.arabic, 'ب');
      expect(be.initial, 'بـ');
      expect(be.medial, 'ـبـ');
      expect(be.finalForm, 'ـب');
    });

    test('ElifBa dersleri, seviyeler ve soru yapıları eksiksiz olmalı', () {
      expect(elifBaLessonsList.length, 4);

      // Seviye 1 ve 2 Ücretsiz olmalı
      expect(elifBaLessonsList[0].isPremiumOnly, isFalse);
      expect(elifBaLessonsList[1].isPremiumOnly, isFalse);

      // Seviye 3 ve 4 Premium olmalı
      expect(elifBaLessonsList[2].isPremiumOnly, isTrue);
      expect(elifBaLessonsList[3].isPremiumOnly, isTrue);

      // Her dersteki sorular geçerli şıklara ve doğru cevap indeksine sahip olmalı
      for (final lesson in elifBaLessonsList) {
        expect(lesson.questions.isNotEmpty, isTrue);
        for (final q in lesson.questions) {
          expect(q.options.isNotEmpty, isTrue);
          expect(q.correctOptionIndex, inInclusiveRange(0, q.options.length - 1));
          expect(q.explanation.isNotEmpty, isTrue);
        }
      }
    });

    test('ElifBaProgressNotifier ders tamamlama ve XP kazanımını kaydetmeli', () async {
      final notifier = ElifBaProgressNotifier();

      expect(notifier.state.totalXp, 0);
      expect(notifier.state.completedLessonIds.isEmpty, isTrue);

      await notifier.completeLesson('lesson_1_letters_basic', 50);

      expect(notifier.state.totalXp, 50);
      expect(notifier.state.completedLessonIds.contains('lesson_1_letters_basic'), isTrue);

      // İkinci ders tamamlama
      await notifier.completeLesson('lesson_2_harekeler', 70);
      expect(notifier.state.totalXp, 120);
      expect(notifier.state.completedLessonIds.length, 2);
    });
  });

  group('Apple Ekosistemi & Canlı Etkinlik (Live Activity) Zamanlama Testleri', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('LiveActivityTriggerNotifier varsayılan 45 dk olmalı ve seçilen süreyi kaydetmeli', () async {
      final notifier = LiveActivityTriggerNotifier();
      expect(notifier.state, 45);

      await notifier.setTriggerMinutes(60);
      expect(notifier.state, 60);

      await notifier.setTriggerMinutes(-1); // Sürekli
      expect(notifier.state, -1);
    });

    test('liveActivityOptions tüm temel zamanlama seçeneklerini barındırmalı', () {
      expect(liveActivityOptions.length, 6);
      final minutesList = liveActivityOptions.map((o) => o.minutes).toList();
      expect(minutesList, containsAll([-1, 60, 45, 30, 15, 0]));

      for (final opt in liveActivityOptions) {
        expect(opt.localizedTitle('tr').isNotEmpty, isTrue);
        expect(opt.localizedTitle('en').isNotEmpty, isTrue);
        expect(opt.localizedSubtitle('tr').isNotEmpty, isTrue);
        expect(opt.localizedSubtitle('en').isNotEmpty, isTrue);
      }
    });
  });

  group('Sesli Elif-Bâ Telaffuz ve TTS Testleri', () {
    test('ElifBaAudioService speakArabic ve stop metotları hatasız çalışmalı', () async {
      final audioService = ElifBaAudioService();
      expect(audioService.isPlaying, isFalse);

      await audioService.speakArabic('ب');
      await audioService.speakArabic('بَيْت');
      await audioService.stop();
      expect(audioService.isPlaying, isFalse);
    });
  });
}
