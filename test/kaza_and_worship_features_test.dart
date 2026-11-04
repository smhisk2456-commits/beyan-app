import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/features/kaza/models/kaza_tracker_model.dart';
import 'package:islamic_app/features/kaza/providers/kaza_tracker_provider.dart';
import 'package:islamic_app/features/kaza/screens/kaza_tracker_screen.dart';
import 'package:islamic_app/features/home/widgets/worship_rings_card.dart';
import 'package:islamic_app/features/prayer_guide/models/prayer_guide_data.dart';
import 'package:islamic_app/features/prayer_guide/screens/interactive_prayer_guide_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KazaTrackerModel & Provider Testleri', () {
    test('Başlangıçta kaza durumu boş olmalı ve doğru toplam hesaplanmalı', () {
      final state = KazaTrackerState.empty();
      expect(state.totalRemainingPrayers, 0);
      expect(state.remainingFasting, 0);
      expect(state.completedPrayers, 0);
      expect(state.progressRatio, 0.0);
    });

    test('Süre hesaplama (2 Yıl 3 Ay) 6 vakit ve orucu doğru çarpmalı', () {
      final notifier = KazaTrackerNotifier();
      // 2 yıl = 730 gün, 3 ay = 90 gün => Toplam 820 gün
      notifier.calculateFromDuration(years: 2, months: 3);

      final state = notifier.state;
      expect(state.getCount(KazaType.fajr), 820);
      expect(state.getCount(KazaType.dhuhr), 820);
      expect(state.getCount(KazaType.asr), 820);
      expect(state.getCount(KazaType.maghrib), 820);
      expect(state.getCount(KazaType.isha), 820);
      expect(state.getCount(KazaType.witr), 820);
      expect(state.remainingFasting, 60); // 2 yıl * 30 gün
      expect(state.totalRemainingPrayers, 820 * 6);
    });

    test('1 Vakit Tamamlandığında kalan 1 azalmalı ve geçmişe eklenmeli', () {
      final notifier = KazaTrackerNotifier();
      notifier.setCount(KazaType.fajr, 100, updateInitial: true);

      expect(notifier.state.getCount(KazaType.fajr), 100);
      notifier.markCompleted(KazaType.fajr, amount: 1);

      expect(notifier.state.getCount(KazaType.fajr), 99);
      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.type, KazaType.fajr);
    });

    test('1 Günlük Tam Kaza (6 Vakit) tüm vakitleri 1\'er azaltmalı', () {
      final notifier = KazaTrackerNotifier();
      notifier.calculateFromDuration(years: 1, months: 0); // 365 gün

      notifier.markFullDailySetCompleted();
      final state = notifier.state;

      expect(state.getCount(KazaType.fajr), 364);
      expect(state.getCount(KazaType.dhuhr), 364);
      expect(state.getCount(KazaType.asr), 364);
      expect(state.getCount(KazaType.maghrib), 364);
      expect(state.getCount(KazaType.isha), 364);
      expect(state.getCount(KazaType.witr), 364);
      expect(state.history.last.isFullDailySet, true);
    });

    test('Undo (Geri Al) son işlemi eksiksiz geri yüklemeli', () {
      final notifier = KazaTrackerNotifier();
      notifier.setCount(KazaType.maghrib, 50, updateInitial: true);

      notifier.markCompleted(KazaType.maghrib, amount: 1);
      expect(notifier.state.getCount(KazaType.maghrib), 49);

      final undone = notifier.undo();
      expect(undone, true);
      expect(notifier.state.getCount(KazaType.maghrib), 50);
      expect(notifier.state.history.isEmpty, true);
    });

    test('Tahmin Motoru (Estimator) doğru gün ve format üretmeli', () {
      final notifier = KazaTrackerNotifier();
      // 100 gün borç (6 vakit = 600 vakit)
      notifier.calculateFromDuration(years: 0, months: 0, days: 100);

      // Günde 6 vakit kılınırsa 100 günde biter
      expect(notifier.state.estimatedDaysToFinish(6), 100);
      // Günde 1 vakit kılınırsa 600 günde biter
      expect(notifier.state.estimatedDaysToFinish(1), 600);

      expect(KazaTrackerState.formatEstimatedDuration(400), '1 Yıl 1 Ay');
      expect(KazaTrackerState.formatEstimatedDuration(15), '15 Gün');
    });
  });

  group('PrayerGuide & Duas Veri Testleri', () {
    test('Namaz Duaları ve Sûreleri listesi dolu ve Arapça metinleri mevcut olmalı', () {
      expect(NamazDuaItem.allDuas.length, greaterThanOrEqualTo(10));
      for (final dua in NamazDuaItem.allDuas) {
        expect(dua.title.isNotEmpty, true);
        expect(dua.arabic.isNotEmpty, true);
        expect(dua.transliteration.isNotEmpty, true);
        expect(dua.meaning.isNotEmpty, true);
        expect(dua.whereRead.isNotEmpty, true);
      }
    });

    test('5 Vakit Namaz kılınış adımları eksiksiz tanımlı olmalı', () {
      expect(PrayerGuideVakit.allPrayers.length, greaterThanOrEqualTo(5));
      for (final v in PrayerGuideVakit.allPrayers) {
        expect(v.name.isNotEmpty, true);
        expect(v.totalRakats.isNotEmpty, true);
        expect(v.rakats.isNotEmpty, true);
        for (final rakat in v.rakats) {
          expect(rakat.steps.isNotEmpty, true);
        }
      }
    });
  });

  group('Ekran Widget Testleri', () {
    testWidgets('WorshipRingsCard hatasız render edilmeli', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WorshipRingsCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GÜNLÜK İBADET HALKALARI'), findsOneWidget);
      expect(find.text('Namaz'), findsOneWidget);
      expect(find.text('Sabah'), findsOneWidget);
      expect(find.text('Öğle'), findsOneWidget);
    });

    testWidgets('KazaTrackerScreen hatasız açılmalı', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KazaTrackerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kaza Namazı Takibi'), findsOneWidget);
      expect(find.text('Akıllı Tamamlama Öngörüsü'), findsOneWidget);
      expect(find.text('+1 Günlük Tam Kaza Kıldım (6 Vakit)'), findsOneWidget);
    });

    testWidgets('InteractivePrayerGuideScreen sekmeleriyle render edilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InteractivePrayerGuideScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Namaz & Dua Rehberi'), findsOneWidget);
      expect(find.text('Namaz Kılınışı'), findsOneWidget);
      expect(find.text('Namaz Duaları'), findsOneWidget);
      expect(find.text('Abdest Rehberi'), findsOneWidget);
    });
  });
}
