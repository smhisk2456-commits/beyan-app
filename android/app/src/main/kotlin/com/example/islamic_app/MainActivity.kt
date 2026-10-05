package com.example.islamic_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Ana Android Activity.
 *
 * Flutter embedding v2 kullanır.
 * WorkManager periyodik görevini uygulama ilk açılışta planlar.
 * MethodChannel aracılığıyla Flutter'dan widget güncelleme talebi alır.
 */
class MainActivity : FlutterActivity() {

    // Flutter → Android iletişim kanalı
    private val CHANNEL = "com.example.islamic_app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── WorkManager periyodik görevini planla ────────────────
        // Uygulama her açıldığında çağrılır; KEEP policy çift planlamayı önler
        WidgetUpdateWorker.schedule(applicationContext)

        // ── Flutter MethodChannel ────────────────────────────────
        // Flutter tarafından `updateWidget()` çağrıldığında
        // Android widget'ını yeniler
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    // home_widget'ın triggerWidgetUpdate metoduyla hallediliyor
                    // Bu kanal ek Android-özel güncellemeler için rezerve
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
