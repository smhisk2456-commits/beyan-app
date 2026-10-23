package com.example.islamic_app

import android.view.WindowManager
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

    // Flutter → Android iletişim kanalları
    private val WIDGET_CHANNEL = "com.example.islamic_app/widget"
    private val SCREEN_CHANNEL = "com.example.islamic_app/screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── WorkManager periyodik görevini planla ────────────────
        // Uygulama her açıldığında çağrılır; KEEP policy çift planlamayı önler
        WidgetUpdateWorker.schedule(applicationContext)

        // ── Flutter Widget MethodChannel ────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Flutter Screen Awake MethodChannel ──────────────────
        listOf(SCREEN_CHANNEL, "com.smhisk60.beyan/screen").forEach { channelName ->
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                channelName
            ).setMethodCallHandler { call, result ->
                when (call.method) {
                    "setKeepScreenOn" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        runOnUiThread {
                            if (enabled) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
