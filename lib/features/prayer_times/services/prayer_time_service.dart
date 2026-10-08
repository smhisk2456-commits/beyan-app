import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../models/prayer_time_model.dart';
import '../models/city_model.dart';
import '../models/calculation_settings_model.dart';

/// Namaz vakitlerini hesaplayan ana servis sınıfı.
///
/// Sorumlulukları:
/// 1. Kullanıcı konumunu (Manuel seçilen şehir veya GPS) almak.
/// 2. Seçilen hesaplama yöntemine göre (Diyanet, MWL, ISNA, Umm al-Qura vb.)
///    namaz vakitlerini hesaplamak.
/// 3. Sıradaki vakti ve kalan süreyi döndürmek.
class PrayerTimeService {
  // ── Singleton ──────────────────────────────────────────────
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  static PrayerTimeService get instance => _instance;
  PrayerTimeService._internal();

  static const _prefManualCityKey = 'selected_manual_city_name';
  static const _prefMethodKey = 'selected_calculation_method';

  // ── Konum Servisi ─────────────────────────────────────────

  /// Kullanıcının konumunu alır.
  /// Öncelik:
  ///   1. Kullanıcı manuel bir şehir seçtiyse o şehrin koordinatları
  ///   2. GPS açık ve izin verilmişse GPS koordinatları
  ///   3. Herhangi bir hata veya izin yoksa İstanbul varsayılanı
  Future<LocationData> getCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final manualCityName = prefs.getString(_prefManualCityKey);

      if (manualCityName != null && manualCityName.isNotEmpty) {
        final found = predefinedCitiesList.firstWhere(
          (c) => c.name.toLowerCase() == manualCityName.toLowerCase(),
          orElse: () => predefinedCitiesList.first,
        );
        return LocationData(
          latitude: found.latitude,
          longitude: found.longitude,
          cityName: found.name,
          isFromGPS: false,
        );
      }

      // Konum servisi açık mı?
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _defaultLocation('Konum servisi kapalı');
      }

      // İzin durumunu kontrol et
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _defaultLocation('Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _defaultLocation('Konum izni kalıcı olarak reddedildi');
      }

      // GPS konumunu al
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (lastKnown != null) {
        final age = DateTime.now().difference(lastKnown.timestamp);
        if (age.inMinutes < 30 && !_isEmulatorOrInvalidLocation(lastKnown.latitude, lastKnown.longitude)) {
          return LocationData(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            cityName: 'Mevcut Konum',
            isFromGPS: true,
          );
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Konum zaman aşımı'),
      );

      if (_isEmulatorOrInvalidLocation(position.latitude, position.longitude)) {
        return _defaultLocation('Emülatör GPS algılandı, varsayılan konum kullanıldı');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'Mevcut Konum',
        isFromGPS: true,
      );
    } catch (e) {
      return _defaultLocation('GPS hatası: $e');
    }
  }

  /// Android emülatör sahte konumunu veya geçersiz koordinatları tespit eder.
  bool _isEmulatorOrInvalidLocation(double lat, double lon) {
    if (lon < -50 || (lat >= 36.5 && lat <= 38.5 && lon >= -123.0 && lon <= -120.0)) {
      return true;
    }
    if (lat == 0.0 && lon == 0.0) {
      return true;
    }
    return false;
  }

  /// İstanbul varsayılan konum verisi döner.
  LocationData defaultLocation([String? reason]) => _defaultLocation(reason);
  LocationData _defaultLocation([String? reason]) {
    return const LocationData(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      cityName: AppConstants.defaultCityName,
      isFromGPS: false,
    );
  }

  // ── Namaz Vakitleri Hesaplama ─────────────────────────────

  /// Verilen tarih ve hesaplama yöntemi için namaz vakitlerini hesaplar.
  Future<DailyPrayerTimes> calculatePrayerTimes({
    LocationData? location,
    DateTime? date,
    PrayerCalculationMethod? method,
  }) async {
    final loc = location ?? await getCurrentLocation();
    final targetDate = date ?? DateTime.now();

    final coordinates = Coordinates(loc.latitude, loc.longitude);

    // Hesaplama parametrelerini al
    final calcMethod = method ?? await getSavedCalculationMethod();
    final params = calcMethod.getAdhanParameters();

    final dateComponents = DateComponents(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final prayerTimes = PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    final entries = _buildPrayerEntries(prayerTimes);

    return DailyPrayerTimes(
      date: targetDate,
      locationName: loc.cityName,
      latitude: loc.latitude,
      longitude: loc.longitude,
      prayers: entries,
      prayerTimes: prayerTimes,
    );
  }

  Future<PrayerCalculationMethod> getSavedCalculationMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefMethodKey);
      if (name != null) {
        return PrayerCalculationMethod.values.firstWhere(
          (m) => m.name == name,
          orElse: () => PrayerCalculationMethod.diyanet,
        );
      }
    } catch (_) {}
    return PrayerCalculationMethod.diyanet;
  }

  Future<void> saveCalculationMethod(PrayerCalculationMethod method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefMethodKey, method.name);
    } catch (_) {}
  }

  Future<void> saveManualCity(String? cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (cityName == null) {
        await prefs.remove(_prefManualCityKey);
      } else {
        await prefs.setString(_prefManualCityKey, cityName);
      }
    } catch (_) {}
  }

  /// Türkiye kalıcı UTC+3 saat dilimi dönüşümü
  DateTime _toTurkeyTime(DateTime time) {
    if (DateTime.now().timeZoneOffset.inHours == 3) {
      return time.toLocal();
    }
    return time.toUtc().add(const Duration(hours: 3));
  }

  List<PrayerEntry> _buildPrayerEntries(PrayerTimes pt) {
    return [
      PrayerEntry(name: PrayerName.fajr, time: _toTurkeyTime(pt.fajr)),
      PrayerEntry(name: PrayerName.sunrise, time: _toTurkeyTime(pt.sunrise)),
      PrayerEntry(name: PrayerName.dhuhr, time: _toTurkeyTime(pt.dhuhr)),
      PrayerEntry(name: PrayerName.asr, time: _toTurkeyTime(pt.asr)),
      PrayerEntry(name: PrayerName.maghrib, time: _toTurkeyTime(pt.maghrib)),
      PrayerEntry(name: PrayerName.isha, time: _toTurkeyTime(pt.isha)),
    ];
  }

  Duration getTimeUntilNextPrayer(DailyPrayerTimes daily) {
    return daily.timeUntilNextPrayer;
  }

  double getProgressToNextPrayer(DailyPrayerTimes daily) {
    final now = DateTime.now();
    final prayers = daily.prayers;

    PrayerEntry? current;
    PrayerEntry? next;

    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].time.isAfter(now)) {
        next = prayers[i];
        current = i > 0 ? prayers[i - 1] : null;
        break;
      }
    }

    if (current == null || next == null) return 1.0;

    final totalDuration = next.time.difference(current.time);
    final elapsed = now.difference(current.time);

    if (totalDuration.inSeconds == 0) return 0.0;
    final progress = elapsed.inSeconds / totalDuration.inSeconds;
    return progress.clamp(0.0, 1.0);
  }

  String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String formatCountdown(Duration duration, {AppLanguage? lang}) {
    if (duration == Duration.zero) return '--:--';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    if (h > 0) {
      if (lang == AppLanguage.english) {
        return '${h}h ${mStr}m';
      } else if (lang == AppLanguage.arabic) {
        return '$h س $mStr د';
      }
      return '${h}s ${mStr}dk';
    }
    return '$mStr:$sStr';
  }
}
