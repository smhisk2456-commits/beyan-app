import 'dart:async';
import 'package:flutter/foundation.dart';
import '../prayer_times/services/prayer_time_service.dart';
import '../widget_service/widget_service.dart';

/// iOS 16.1+ Canlı Etkinlikler (Live Activities & Dynamic Island) Yönetim Servisi.
/// Ezan vaktine son 30 dakika kaldığında devreye girer.
class LiveActivityService {
  static final LiveActivityService instance = LiveActivityService._internal();
  factory LiveActivityService() => instance;
  LiveActivityService._internal();

  Timer? _timer;
  final PrayerTimeService _prayerService = PrayerTimeService();

  /// Periyodik canlı etkinlik kontrolcüsünü başlatır (Her 60 saniyede bir kontrol).
  void startMonitoring() {
    _timer?.cancel();
    _checkAndSyncLiveActivity();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndSyncLiveActivity();
    });
  }

  /// Namaz vaktine kalan süreyi inceler ve 30 dk altındaysa widget/canlı etkinlikleri tetikler.
  Future<void> _checkAndSyncLiveActivity() async {
    try {
      final location = await _prayerService.getCurrentLocation();
      final daily = await _prayerService.calculatePrayerTimes(location: location);
      final remaining = daily.timeUntilNextPrayer;

      // Son 30 dakika kala
      if (remaining.inMinutes <= 30 && remaining.inSeconds > 0) {
        debugPrint('[LiveActivityService] Vakte ${remaining.inMinutes} dk kaldı. Canlı etkinlik güncelleniyor.');
        await WidgetService().updateAllWidgets();
      }
    } catch (e) {
      debugPrint('[LiveActivityService] Kontrol hatası: $e');
    }
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }
}
