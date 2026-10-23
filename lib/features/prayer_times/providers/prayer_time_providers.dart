import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../notifications/services/notification_service.dart';
import '../../widget_service/widget_service.dart';
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
/// Tek gerçek doğruluk kaynağı olan [prayerTimesNotifierProvider]'a delege eder.
final dailyPrayerTimesProvider = FutureProvider<DailyPrayerTimes>((ref) async {
  return ref.watch(prayerTimesNotifierProvider.future);
});

/// Belirli bir tarih için namaz vakitlerini hesaplar.
/// Ana ekranda haftalık görünüm için kullanılabilir.
final prayerTimesForDateProvider = FutureProvider.autoDispose.family<
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
final nextPrayerProvider = FutureProvider.autoDispose<PrayerEntry?>((ref) async {
  final daily = await ref.watch(prayerTimesNotifierProvider.future);
  return daily.nextPrayerEntry;
});

/// Namaz vakitleri ilerleme oranı (0.0 → 1.0).
/// Mevcut vakitten sonraki vakite kadar geçen sürenin oranı.
/// [StreamProvider] ile saniyede bir dinamik olarak güncellenir.
final prayerProgressProvider = StreamProvider.autoDispose<double>((ref) async* {
  final daily = await ref.watch(prayerTimesNotifierProvider.future);
  final service = ref.watch(prayerTimeServiceProvider);

  yield service.getProgressToNextPrayer(daily);

  final timer = Stream.periodic(const Duration(seconds: 1));
  await for (final _ in timer) {
    yield service.getProgressToNextPrayer(daily);
  }
});

// ════════════════════════════════════════════════════════════════
// Countdown Timer (Gerçek Zamanlı Geri Sayım)
// ════════════════════════════════════════════════════════════════

/// Sıradaki namaz vaktine kalan süreyi saniyede bir güncelleyen provider.
final prayerCountdownProvider = StreamProvider.autoDispose<Duration>((ref) async* {
  final daily = await ref.watch(prayerTimesNotifierProvider.future);

  yield daily.timeUntilNextPrayer;

  final timer = Stream.periodic(const Duration(seconds: 1));
  await for (final _ in timer) {
    yield daily.timeUntilNextPrayer;
  }
});

/// Countdown'ı formatlanmış string olarak döner (ör: "02:45" veya "1s 30dk").
final countdownStringProvider = StreamProvider.autoDispose<String>((ref) async* {
  final daily = await ref.watch(prayerTimesNotifierProvider.future);
  final service = ref.watch(prayerTimeServiceProvider);
  final lang = ref.watch(appLanguageProvider);

  yield service.formatCountdown(daily.timeUntilNextPrayer, lang: lang);

  final timer = Stream.periodic(const Duration(seconds: 1));
  await for (final _ in timer) {
    yield service.formatCountdown(daily.timeUntilNextPrayer, lang: lang);
  }
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
      NotificationService.instance.scheduleUpcomingPrayers();
      WidgetService().updateAllWidgets();
      _scheduleMidnightReset(); // Bir sonraki gece için tekrar kur
    });
  }

  /// Konumu yenileyerek vakitleri yeniden hesaplar.
  /// Önceki durumu koruyarak arayüzün iskelete düşüp titremesini önler.
  Future<void> refresh() async {
    state = const AsyncLoading<DailyPrayerTimes>().copyWithPrevious(state);
    ref.invalidate(locationProvider); // build() yeni konumla zaten yeniden çalışacak
    try {
      await future; // Notifier'ın kendi yeniden kurulumunu bekle
      NotificationService.instance.scheduleUpcomingPrayers();
      WidgetService().updateAllWidgets();
    } catch (_) {}
  }
}

/// Gece yarısı sıfırlamalı namaz vakitleri notifier provider'ı.
/// UI bileşenleri bu provider'ı tercih etmelidir.
final prayerTimesNotifierProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, DailyPrayerTimes>(
  PrayerTimesNotifier.new,
);
