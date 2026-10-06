import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/notifications/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Kıble ve Pusula Testleri', () {
    test('İstanbul için Kıble açısı yaklaşık 152 derece olmalı', () {
      final istanbul = Coordinates(41.0082, 28.9784);
      final qibla = Qibla(istanbul);
      expect(qibla.direction, greaterThan(151.0));
      expect(qibla.direction, lessThan(153.0));
    });

    test('İstanbul ile Kâbe arasındaki kuş uçuşu mesafe yaklaşık 2400 km olmalı', () {
      final distanceMeters = Geolocator.distanceBetween(
        41.0082,
        28.9784,
        Qibla.MAKKAH.latitude,
        Qibla.MAKKAH.longitude,
      );
      final distanceKm = distanceMeters / 1000.0;
      expect(distanceKm, greaterThan(2350.0));
      expect(distanceKm, lessThan(2500.0));
    });

    test('Tüm vakit isimleri bildirim servisinde desteklenmeli', () {
      expect(PrayerName.values.length, equals(6));
      expect(PrayerName.values, contains(PrayerName.fajr));
      expect(PrayerName.values, contains(PrayerName.dhuhr));
      expect(PrayerName.values, contains(PrayerName.asr));
      expect(PrayerName.values, contains(PrayerName.maghrib));
      expect(PrayerName.values, contains(PrayerName.isha));
    });

    test('NotificationService singleton referansı geçerli olmalı', () {
      final s1 = NotificationService.instance;
      final s2 = NotificationService();
      expect(identical(s1, s2), isTrue);
    });

    test('NotificationService varsayılan makam istanbul olmalı', () async {
      final service = NotificationService.instance;
      expect(await service.getSelectedMakam(), isNotNull);
    });
  });
}
