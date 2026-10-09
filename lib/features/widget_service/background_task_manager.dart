import 'package:flutter/material.dart';
import 'widget_service.dart';

/// Arka plan widget güncelleme yöneticisi.
///
/// iOS ve Android tarafında WidgetKit / AppWidget güncellemelerini
/// güvenli ve platformdan bağımsız olarak tetikler.
class BackgroundTaskManager {
  static const String widgetUpdateTask = 'islamicAppWidgetUpdate';

  // ── Singleton ────────────────────────────────────────────
  static final BackgroundTaskManager _instance =
      BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  // ── Başlatma ─────────────────────────────────────────────
  Future<void> initialize() async {
    debugPrint('[BackgroundTaskManager] Başlatıldı.');
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

  /// Planlanmış görevleri temizler.
  Future<void> cancelAll() async {}
}
