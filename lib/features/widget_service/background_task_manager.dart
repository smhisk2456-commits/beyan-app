import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'widget_service.dart';

/// WorkManager arka plan görevi için Dart tarafındaki callback.
///
/// Bu fonksiyon, WorkManager tarafından ayrı bir Isolate'te çağrılır.
/// [WidgetsFlutterBinding.ensureInitialized] zorunludur.
///
/// Android: Kotlin WorkerFactory bu callback'i tetikler.
/// iOS: BackgroundTasks framework bu callback'i tetikler.
@pragma('vm:entry-point')
void backgroundTaskCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    // Isolate'te Flutter binding'i başlat
    WidgetsFlutterBinding.ensureInitialized();

    // DartPluginRegistrant.ensureInitialized();  ← Flutter 3.3+ gereksinim

    switch (taskName) {
      case BackgroundTaskManager.widgetUpdateTask:
        // Widget verilerini güncelle
        await WidgetService.initialize();
        await WidgetService().updateAllWidgets();
        return true;

      default:
        return false;
    }
  });
}

/// Arka plan görevlerini yöneten sınıf.
///
/// WorkManager aracılığıyla:
/// - Günde bir kez widget'ı otomatik günceller
/// - Uygulama açıldığında anlık güncelleme yapar
class BackgroundTaskManager {
  static const String widgetUpdateTask = 'islamicAppWidgetUpdate';

  // ── Singleton ────────────────────────────────────────────
  static final BackgroundTaskManager _instance =
      BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  // ── Başlatma ─────────────────────────────────────────────

  /// WorkManager'ı başlatır ve callback'i kayıt eder.
  /// [main()] içinde [WidgetService.initialize()]'dan sonra çağrılmalıdır.
  Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundTaskCallback,
    );
  }

  // ── Görev Kayıt ───────────────────────────────────────────

  /// Günlük periyodik widget güncelleme görevini kaydeder.
  ///
  /// WorkManager garantisi:
  /// - Android: Yaklaşık 24 saatte bir, batarya/ağ kısıtlamalarına uyarak
  /// - iOS: BGTaskScheduler ile günde 1-2 kez (iOS'un takdirine bağlı)
  Future<void> scheduleWidgetUpdate() async {
    // Mevcut görevi iptal et (çift kayıt önlemek için)
    await Workmanager().cancelByUniqueName(widgetUpdateTask);

    await Workmanager().registerPeriodicTask(
      widgetUpdateTask,             // Unique name
      widgetUpdateTask,             // Task name
      // WorkManager minimum 15 dakika; uzun süre bekleme ve donma hatalarını önlemek için
      frequency: const Duration(minutes: 15),
      // ── Kısıtlamalar ──────────────────────────────────────
      constraints: Constraints(
        requiresBatteryNotLow: false,
        // Ağ bağlantısı gerekmez (offline çalışıyor)
        networkType: NetworkType.notRequired,
      ),
      // Güncel periyodu hemen uygulamak için update
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      // Görev başarısız olursa yeniden dene
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  /// Anlık (bir kerelik) widget güncelleme görevi çalıştırır.
  /// Uygulama arka plana geçtiğinde tetiklenir.
  Future<void> triggerImmediateUpdate() async {
    await Workmanager().registerOneOffTask(
      '${widgetUpdateTask}_immediate',
      widgetUpdateTask,
      // Mümkün olan en kısa sürede çalışsın
      initialDelay: Duration.zero,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      // Aynı isimde görev varsa değiştir
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Tüm planlanmış görevleri iptal eder.
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}

