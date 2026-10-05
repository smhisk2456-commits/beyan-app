import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_time_service.dart';

// ════════════════════════════════════════════════════════════════
// Servis Provider'ı
// ════════════════════════════════════════════════════════════════

/// [PrayerTimeService] singleton provider'ı.
final prayerTimeServiceProvider = Provider<PrayerTimeService>((ref) {
  return PrayerTimeService();
});

// ════════════════════════════════════════════════════════════════
// Konum Provider'ı
// ════════════════════════════════════════════════════════════════

/// Kullanıcının konumunu asenkron olarak döner.
/// GPS alınamazsa İstanbul varsayılanını kullanır.
final locationProvider = FutureProvider<LocationData>((ref) async {
  final service = ref.watch(prayerTimeServiceProvider);
  return service.getCurrentLocation();
});

// ════════════════════════════════════════════════════════════════
// Namaz Vakitleri Provider'ı
// ════════════════════════════════════════════════════════════════

/// Bugünün namaz vakitlerini hesaplar ve döner.
///
/// [locationProvider]'a bağlıdır; konum değişirse yeniden hesaplar.
final dailyPrayerTimesProvider = FutureProvider<DailyPrayerTimes>((ref) async {
  final service = ref.watch(prayerTimeServiceProvider);
  // Konumu al (GPS veya İstanbul)
  final location = await ref.watch(locationProvider.future);
  // Diyanet metoduyla hesapla
  return service.calculatePrayerTimes(location: location);
});

/// Belirli bir tarih için namaz vakitlerini hesaplar.
/// Ana ekranda haftalık görünüm için kullanılabilir.
final prayerTimesForDateProvider = FutureProvider.family<
  DailyPrayerTimes,
  DateTime
>((ref, date) async {
  final service = ref.watch(prayerTimeServiceProvider);
  final location = await ref.watch(locationProvider.future);
  return service.calculatePrayerTimes(location: location, date: date);
});

// ════════════════════════════════════════════════════════════════
// Sıradaki Namaz Provider'ı
// ════════════════════════════════════════════════════════════════

/// Sıradaki namaz vakti bilgisi – sadece ilgili alanları döner.
final nextPrayerProvider = FutureProvider<PrayerEntry?>((ref) async {
  final daily = await ref.watch(dailyPrayerTimesProvider.future);
  return daily.nextPrayerEntry;
});

/// Namaz vakitleri ilerleme oranı (0.0 → 1.0).
/// Mevcut vakitten sonraki vakite kadar geçen sürenin oranı.
final prayerProgressProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(prayerTimeServiceProvider);
  final daily = await ref.watch(dailyPrayerTimesProvider.future);
  return service.getProgressToNextPrayer(daily);
});

// ════════════════════════════════════════════════════════════════
// Countdown Timer (Gerçek Zamanlı Geri Sayım)
// ════════════════════════════════════════════════════════════════

/// Sıradaki namaz vaktine kalan süreyi saniyede bir güncelleyen provider.
///
/// [StreamProvider] kullanılır; her saniye yeni bir [Duration] yayar.
/// Widget, `ref.watch(prayerCountdownProvider)` ile otomatik güncellenir.
final prayerCountdownProvider = StreamProvider<Duration>((ref) {
  // Her saniye tetiklenen timer stream'i
  return Stream.periodic(const Duration(seconds: 1), (_) => _).asyncMap(
    (_) async {
      // Namaz vakitlerini al (cache'ten gelir, yeniden hesaplanmaz)
      final daily = await ref.watch(dailyPrayerTimesProvider.future);
      return daily.timeUntilNextPrayer;
    },
  );
});

/// Countdown'ı formatlanmış string olarak döner (ör: "02:45" veya "1s 30dk").
final countdownStringProvider = StreamProvider<String>((ref) {
  final service = ref.watch(prayerTimeServiceProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => _).asyncMap(
    (_) async {
      final daily = await ref.watch(dailyPrayerTimesProvider.future);
      final remaining = daily.timeUntilNextPrayer;
      return service.formatCountdown(remaining);
    },
  );
});

// ════════════════════════════════════════════════════════════════
// Günlük Sıfırlama Notifier'ı
// ════════════════════════════════════════════════════════════════

/// Gece yarısında namaz vakitlerini otomatik yenileyen notifier.
///
/// Uygulama gece yarısını geçtiğinde yeni günün vakitlerini hesaplar.
class PrayerTimesNotifier extends AsyncNotifier<DailyPrayerTimes> {
  Timer? _midnightTimer;

  @override
  Future<DailyPrayerTimes> build() async {
    // Gece yarısına kadar olan süreyi hesapla
    _scheduleMidnightReset();

    // Dispose edildiğinde timer'ı temizle
    ref.onDispose(() => _midnightTimer?.cancel());

    final service = ref.watch(prayerTimeServiceProvider);
    final location = await ref.watch(locationProvider.future);
    return service.calculatePrayerTimes(location: location);
  }

  /// Gece yarısında vakitleri yeniden hesaplamak için timer kurar.
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final untilMidnight = midnight.difference(now);

    _midnightTimer = Timer(untilMidnight, () {
      // Gece yarısı geçince yeniden hesapla
      ref.invalidateSelf();
      _scheduleMidnightReset(); // Bir sonraki gece için tekrar kur
    });
  }

  /// Konumu yenileyerek vakitleri yeniden hesaplar.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(prayerTimeServiceProvider);
      final location = await service.getCurrentLocation();
      return service.calculatePrayerTimes(location: location);
    });
  }
}

/// Gece yarısı sıfırlamalı namaz vakitleri notifier provider'ı.
/// UI bileşenleri bu provider'ı tercih etmelidir.
final prayerTimesNotifierProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, DailyPrayerTimes>(
  PrayerTimesNotifier.new,
);
