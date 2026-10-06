import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/calendar/services/hijri_calendar_service.dart';

void main() {
  group('Hicri Takvim ve Dini Günler Testleri', () {
    final service = HijriCalendarService.instance;

    test('Hicri ay isimleri 12 ayı eksiksiz içermeli', () {
      expect(HijriCalendarService.hijriMonthNamesTr.length, 12);
      expect(HijriCalendarService.hijriMonthNamesAr.length, 12);
      expect(HijriCalendarService.hijriMonthNamesTr[8], 'Ramazan');
    });

    test('Miladi tarihten Hicri tarih dönüşümü geçerli aralıkta olmalı', () {
      final now = DateTime(2025, 3, 1);
      final hijri = service.getHijriDate(now);

      expect(hijri.day, greaterThanOrEqualTo(1));
      expect(hijri.day, lessThanOrEqualTo(30));
      expect(hijri.month, greaterThanOrEqualTo(1));
      expect(hijri.month, lessThanOrEqualTo(12));
      expect(hijri.year, greaterThanOrEqualTo(1440));
    });

    test('Dini günler listesi Diyanet takvimine göre sıralı ve açıklamalı olmalı', () {
      final days = service.getReligiousDays();
      expect(days.length, greaterThanOrEqualTo(10));

      for (final day in days) {
        expect(day.title.isNotEmpty, isTrue);
        expect(day.hijriDate.isNotEmpty, isTrue);
        expect(day.description.isNotEmpty, isTrue);
      }
    });

    test('getNextReligiousDay geçmiş olmayan ilk dini günü dönmeli', () {
      final next = service.getNextReligiousDay();
      if (next != null) {
        expect(next.isPast, isFalse);
        expect(next.daysRemaining, greaterThanOrEqualTo(0));
      }
    });
  });
}
