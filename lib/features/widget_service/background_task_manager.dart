import 'dart:async';
import 'package:flutter/foundation.dart';
import 'widget_service.dart';

/// Arka plan widget güncelleme yöneticisi.
///
/// Mimari:
/// 1. Süreç Canlıyken: 15 dakikalık periyodik zamanlayıcı [Timer.periodic] ile
///    widget ve namaz vakitlerini sürekli taze tutar.
/// 2. Süreç Askıdayken / Kapalıyken: iOS WidgetKit native Timeline sağlayıcısı
///    ve Android AppWidgetProvider periyodik yayınları (updatePeriodMillis)
///    SharedPreferences / App Group'a yazılmış verileri bağımsız olarak sunar.
class BackgroundTaskManager {
  static const String widgetUpdateTask = 'islamicAppWidgetUpdate';

  // ── Singleton ────────────────────────────────────────────
  static final BackgroundTaskManager _instance =
      BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  Timer? _periodicTimer;

  // ── Başlatma ─────────────────────────────────────────────
  Future<void> initialize() async {
    debugPrint('[BackgroundTaskManager] Başlatıldı.');
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      scheduleWidgetUpdate();
    });
  }

  // ── Görev Kayıt & Tetikleme ──────────────────────────────
  Future<void> scheduleWidgetUpdate() async {
    try {
      await WidgetService().updateAllWidgets();
      debugPrint('[BackgroundTaskManager] Widget verileri güncellendi.');
    } catch (e) {
      debugPrint('[BackgroundTaskManager] Widget güncelleme hatası: $e');
    }
  }

  /// Anlık widget güncelleme görevi çalıştırır.
  Future<void> triggerImmediateUpdate() async {
    try {
      await WidgetService().updateAllWidgets();
    } catch (e) {
      debugPrint('[BackgroundTaskManager] Anlık güncelleme hatası: $e');
    }
  }

  /// Planlanmış görevleri temizler ve zamanlayıcıyı durdurur.
  Future<void> cancelAll() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    debugPrint('[BackgroundTaskManager] Planlanmış periyodik widget görevleri durduruldu.');
  }
}
