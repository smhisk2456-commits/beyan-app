import 'dart:async';
import 'package:flutter/foundation.dart';
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
        if (age.inMinutes < 15 && !_isEmulatorOrInvalidLocation(lastKnown.latitude, lastKnown.longitude)) {
          await _saveVerifiedGps(prefs, lastKnown.latitude, lastKnown.longitude);
          return LocationData(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            cityName: 'Mevcut Konum',
            isFromGPS: true,
          );
        }
      }

      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 7),
        );

        if (!_isEmulatorOrInvalidLocation(position.latitude, position.longitude)) {
          await _saveVerifiedGps(prefs, position.latitude, position.longitude);
          return LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: 'Mevcut Konum',
            isFromGPS: true,
          );
        }
      } catch (_) {
        // Canlı GPS zaman aşımına uğrarsa son bilinen gerçek donanım konumunu kullan
        if (lastKnown != null && !_isEmulatorOrInvalidLocation(lastKnown.latitude, lastKnown.longitude)) {
          return LocationData(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            cityName: 'Mevcut Konum',
            isFromGPS: true,
          );
        }
        final savedLat = prefs.getDouble('beyan_verified_gps_lat');
        final savedLng = prefs.getDouble('beyan_verified_gps_lng');
        if (savedLat != null && savedLng != null && !_isEmulatorOrInvalidLocation(savedLat, savedLng)) {
          return LocationData(
            latitude: savedLat,
            longitude: savedLng,
            cityName: prefs.getString('beyan_verified_gps_title') ?? 'Mevcut Konum',
            isFromGPS: true,
          );
        }
      }

      return _defaultLocation('Emülatör veya geçersiz GPS algılandı');
    } catch (e) {
      return _defaultLocation('GPS hatası: $e');
    }
  }

  Future<void> _saveVerifiedGps(SharedPreferences prefs, double lat, double lng) async {
    try {
      await prefs.setDouble('beyan_verified_gps_lat', lat);
      await prefs.setDouble('beyan_verified_gps_lng', lng);
    } catch (_) {}
  }

  /// Geçersiz veya bozuk koordinatları tespit eder.
  /// Null Island (0,0) ve dünya koordinat sınırları (-90..90, -180..180) dışını filtreler.
  /// Gerçek kullanıcıların (Amerika, Avrupa vb.) veya App Store inceleme ekibinin
  /// koordinatlarının yanlışlıkla reddedilmemesi için genel boylam filtresi kaldırılmıştır;
  /// yalnızca debug modunda varsayılan Google emülatör koordinatı yakalanır.
  bool _isEmulatorOrInvalidLocation(double lat, double lon) {
    if (lat < -90.0 || lat > 90.0 || lon < -180.0 || lon > 180.0) {
      return true;
    }
    if (lat == 0.0 && lon == 0.0) {
      return true;
    }
    if (kDebugMode) {
      final isGoogleEmulator =
          (lat >= 37.4215 && lat <= 37.4225 && lon >= -122.0845 && lon <= -122.0835);
      if (isGoogleEmulator) {
        return true;
      }
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

  /// Yerel cihaz saat dilimi dönüşümü (adhan kütüphanesinden yerel saate)
  DateTime _toLocalTime(DateTime time) {
    return time.toLocal();
  }

  List<PrayerEntry> _buildPrayerEntries(PrayerTimes pt) {
    return [
      PrayerEntry(name: PrayerName.fajr, time: _toLocalTime(pt.fajr)),
      PrayerEntry(name: PrayerName.sunrise, time: _toLocalTime(pt.sunrise)),
      PrayerEntry(name: PrayerName.dhuhr, time: _toLocalTime(pt.dhuhr)),
      PrayerEntry(name: PrayerName.asr, time: _toLocalTime(pt.asr)),
      PrayerEntry(name: PrayerName.maghrib, time: _toLocalTime(pt.maghrib)),
      PrayerEntry(name: PrayerName.isha, time: _toLocalTime(pt.isha)),
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
        if (i > 0) {
          current = prayers[i - 1];
        } else {
          // İmsak öncesi: bir önceki vaktimiz dünkü Yatsı
          current = PrayerEntry(
            name: PrayerName.isha,
            time: daily.isha.time.subtract(const Duration(days: 1)),
          );
        }
        break;
      }
    }

    // Günün tüm vakitleri geçmişse (Yatsı sonrası):
    if (next == null) {
      current = daily.isha;
      next = PrayerEntry(
        name: PrayerName.fajr,
        time: daily.fajr.time.add(const Duration(days: 1)),
      );
    }

    final cur = current;
    final nxt = next;
    if (cur == null) return 1.0;

    final totalDuration = nxt.time.difference(cur.time);
    final elapsed = now.difference(cur.time);

    if (totalDuration.inSeconds <= 0) return 0.0;
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
      switch (lang) {
        case AppLanguage.indonesian:
          return '$h jam $mStr mnt';
        case AppLanguage.english:
          return '${h}h ${mStr}m';
        case AppLanguage.arabic:
          return '$h س $mStr د';
        case AppLanguage.french:
          return '${h}h ${mStr}m';
        case AppLanguage.urdu:
          return '$h گھنٹے $mStr منٹ';
        case AppLanguage.german:
          return '$h Std. $mStr Min.';
        case AppLanguage.russian:
          return '$h ч $mStr мин';
        case AppLanguage.turkish:
        case null:
          return '${h}s ${mStr}dk';
      }
    }
    return '$mStr:$sStr';
  }
}
