import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/app_constants.dart';
import '../models/prayer_time_model.dart';

/// Namaz vakitlerini hesaplayan ana servis sınıfı.
///
/// Sorumlulukları:
/// 1. [geolocator] ile kullanıcı konumunu almak.
///    Konum alınamazsa → İstanbul (41.0082, 28.9784) varsayılanı.
/// 2. [adhan] paketini kullanarak Diyanet (Turkey) metoduna göre
///    o günün namaz vakitlerini hesaplamak.
/// 3. Sıradaki vakti ve kalan süreyi döndürmek.
class PrayerTimeService {
  // ── Singleton ──────────────────────────────────────────────
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  // ── Konum Servisi ─────────────────────────────────────────

  /// Kullanıcının mevcut konumunu alır.
  ///
  /// Hiyerarşi:
  ///   1. Servis açık + izin verilmiş → GPS konumu
  ///   2. Herhangi bir hata → İstanbul varsayılanı
  Future<LocationData> getCurrentLocation() async {
    try {
      // Konum servisi açık mı?
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _defaultLocation('Konum servisi kapalı');
      }

      // İzin durumunu kontrol et
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // İlk kez isteniyor
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _defaultLocation('Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Kullanıcı "bir daha sorma" seçti
        return _defaultLocation('Konum izni kalıcı olarak reddedildi');
      }

      // GPS konumunu al (düşük güç tüketimi için lastKnown önce dene)
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {
        // getLastKnownPosition bazı cihazlarda hata verebilir
      }

      if (lastKnown != null) {
        // Son bilinen konum 30 dakikadan tazeyse ve emülatör sahte konumu değilse kullan
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

      // Taze GPS konumu al - maksimum 3 saniye bekle, takılırsa hemen İstanbul'a geç
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Konum zaman aşımı'),
      );

      // Emülatörün varsayılan ABD (California) konumu kontrolü:
      if (_isEmulatorOrInvalidLocation(position.latitude, position.longitude)) {
        return _defaultLocation('Emülatör GPS konumu algılandı, İstanbul varsayılanı kullanıldı');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'Mevcut Konum',
        isFromGPS: true,
      );
    } catch (e) {
      // Herhangi bir hata durumunda İstanbul'a fallback
      return _defaultLocation('GPS hatası: $e');
    }
  }

  /// Android emülatör sahte konumunu (Mountain View -122.08) veya geçersiz koordinatları tespit eder.
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

  /// Verilen tarih için namaz vakitlerini hesaplar.
  ///
  /// [location] null ise GPS/varsayılan konum otomatik alınır.
  /// [date] null ise bugünün tarihi kullanılır.
  Future<DailyPrayerTimes> calculatePrayerTimes({
    LocationData? location,
    DateTime? date,
  }) async {
    // Konum belirleme
    final loc = location ?? await getCurrentLocation();
    final targetDate = date ?? DateTime.now();

    // adhan koordinat nesnesi
    final coordinates = Coordinates(loc.latitude, loc.longitude);

    // ── Diyanet (Turkey) Hesaplama Parametreleri ────────────
    // adhan 2.0: turkey artık statik property (parantez yok)
    final params = CalculationMethod.turkey.getParameters();

    // Hanefî mezhebine göre Asr vakti hesabı
    params.madhab = Madhab.hanafi;

    // adhan için DateComponents oluştur
    final dateComponents = DateComponents(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    // Vakitleri hesapla
    final prayerTimes = PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    // PrayerEntry listesi oluştur
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

  /// Türkiye kalıcı UTC+3 saat dilimi dönüşümü (emülatör UTC olsa bile doğru yerel saat)
  DateTime _toTurkeyTime(DateTime time) {
    if (DateTime.now().timeZoneOffset.inHours == 3) {
      return time.toLocal();
    }
    return time.toUtc().add(const Duration(hours: 3));
  }

  /// [PrayerTimes] nesnesinden [PrayerEntry] listesi üretir.
  List<PrayerEntry> _buildPrayerEntries(PrayerTimes pt) {
    return [
      PrayerEntry(
        name: PrayerName.fajr,
        time: _toTurkeyTime(pt.fajr),
      ),
      PrayerEntry(
        name: PrayerName.sunrise,
        time: _toTurkeyTime(pt.sunrise),
      ),
      PrayerEntry(
        name: PrayerName.dhuhr,
        time: _toTurkeyTime(pt.dhuhr),
      ),
      PrayerEntry(
        name: PrayerName.asr,
        time: _toTurkeyTime(pt.asr),
      ),
      PrayerEntry(
        name: PrayerName.maghrib,
        time: _toTurkeyTime(pt.maghrib),
      ),
      PrayerEntry(
        name: PrayerName.isha,
        time: _toTurkeyTime(pt.isha),
      ),
    ];
  }

  // ── Yardımcı Metotlar ─────────────────────────────────────

  /// Sıradaki namaz vaktine kalan süreyi döner.
  Duration getTimeUntilNextPrayer(DailyPrayerTimes daily) {
    return daily.timeUntilNextPrayer;
  }

  /// Sıradaki vaktin progress oranını döner (0.0 – 1.0).
  /// Mevcut vakit başlangıcından sonraki vakte olan ilerleme.
  double getProgressToNextPrayer(DailyPrayerTimes daily) {
    final now = DateTime.now();
    final prayers = daily.prayers;

    // Mevcut vakti bul
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

  /// Verilen [DateTime]'ı "HH:mm" formatında döner.
  String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Kalan süreyi okunabilir formata çevirir.
  /// Örn: "2s 35dk" veya "45:30"
  String formatCountdown(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}s ${m.toString().padLeft(2, '0')}dk';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
