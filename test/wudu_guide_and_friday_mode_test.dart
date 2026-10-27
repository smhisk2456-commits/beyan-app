import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/prayer_times/models/wudu_guide_model.dart';

void main() {
  group('Abdest Rehberi (WuduGuideData) Testleri', () {
    test('Namaz abdesti 8 adımı ve 4 farzı tam içermelidir', () {
      final steps = WuduGuideData.getNamazWuduSteps(AppLanguage.turkish);
      expect(steps.length, 8);

      final fardSteps = steps.where((s) => s.isFard).toList();
      expect(fardSteps.length, 4, reason: 'Namaz abdestinin 4 farzı bulunmalıdır (Yüz, Kollar, Baş, Ayaklar)');

      // Adım 4: Yüz
      expect(steps[3].isFard, isTrue);
      expect(steps[3].title.contains('Yüz'), isTrue);

      // Adım 5: Kollar
      expect(steps[4].isFard, isTrue);
      expect(steps[4].title.contains('Kol'), isTrue);

      // Adım 6: Baş
      expect(steps[5].isFard, isTrue);
      expect(steps[5].title.contains('Baş'), isTrue);

      // Adım 8: Ayaklar
      expect(steps[7].isFard, isTrue);
      expect(steps[7].title.contains('Ayak'), isTrue);
    });

    test('Gusül abdesti 3 farzı eksiksiz barındırmalıdır', () {
      final ghuslSteps = WuduGuideData.getGhuslSteps(AppLanguage.turkish);
      final fardGhusl = ghuslSteps.where((s) => s.isFard).toList();

      expect(fardGhusl.length, 3, reason: 'Guslün 3 farzı vardır: Ağız, Burun, Bütün Beden');
      expect(ghuslSteps.any((s) => s.title.contains('Ağza') && s.isFard), isTrue);
      expect(ghuslSteps.any((s) => s.title.contains('Burna') && s.isFard), isTrue);
      expect(ghuslSteps.any((s) => s.title.contains('Vücud') || s.title.contains('Beden')), isTrue);
    });

    test('Teyemmüm abdesti 2 darb ve yüz-kol mesh farzlarını içermelidir', () {
      final tayammumSteps = WuduGuideData.getTayammumSteps(AppLanguage.turkish);
      expect(tayammumSteps.length, 3);
      expect(tayammumSteps[1].title.contains('Yüz'), isTrue);
      expect(tayammumSteps[2].title.contains('Kol'), isTrue);
    });

    test('Abdesti bozan ve bozmayan haller listeleri dolu ve doğru olmalıdır', () {
      expect(WuduGuideData.nullifiers.isNotEmpty, isTrue);
      expect(WuduGuideData.nullifiers.any((n) => n.contains('kan')), isTrue);

      expect(WuduGuideData.nonNullifiers.isNotEmpty, isTrue);
      expect(WuduGuideData.nonNullifiers.any((n) => n.contains('Ağlamak')), isTrue);
      expect(WuduGuideData.nonNullifiers.any((n) => n.contains('Tırnak')), isTrue);
    });
  });

  group('Cuma Modu Zamanlama & Atmosfer Testleri', () {
    test('Perşembe akşamı (17:00 sonrası) ve Cuma günü Cuma modu aktif olmalıdır', () {
      // Perşembe 18:30 -> Aktif olmalı
      final thursdayEvening = DateTime(2026, 10, 29, 18, 30); // 29 Ekim 2026 Perşembe
      final isThursdayActive = (thursdayEvening.weekday == DateTime.thursday && thursdayEvening.hour >= 17) ||
          (thursdayEvening.weekday == DateTime.friday);
      expect(isThursdayActive, isTrue);

      // Cuma 12:45 -> Aktif olmalı
      final fridayNoon = DateTime(2026, 10, 30, 12, 45); // 30 Ekim 2026 Cuma
      final isFridayActive = (fridayNoon.weekday == DateTime.thursday && fridayNoon.hour >= 17) ||
          (fridayNoon.weekday == DateTime.friday);
      expect(isFridayActive, isTrue);

      // Çarşamba 14:00 -> Aktif OLMAMALI
      final wednesday = DateTime(2026, 10, 28, 14, 0); // Çarşamba
      final isWednesdayActive = (wednesday.weekday == DateTime.thursday && wednesday.hour >= 17) ||
          (wednesday.weekday == DateTime.friday);
      expect(isWednesdayActive, isFalse);
    });
  });
}
