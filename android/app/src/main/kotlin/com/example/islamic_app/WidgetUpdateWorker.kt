package com.example.islamic_app

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.Constraints
import androidx.work.NetworkType
import java.util.concurrent.TimeUnit

/**
 * WorkManager Worker – Android arka plan widget güncelleme görevi.
 *
 * Flutter WorkManager paketi Dart callback'ini çalıştırmadan önce
 * bu Worker tetiklenebilir. Buradaki görev sadece Android sistemine
 * "widget'ı yenile" sinyali gönderir; asıl hesaplama Dart tarafında yapılır.
 */
class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {

    companion object {
        private const val WORK_NAME = "islamicAppWidgetUpdate"

        /**
         * Günlük periyodik widget güncelleme görevini planlar.
         * WorkManager en az 15 dakika kabul eder; biz 24 saat istiyoruz.
         */
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiresBatteryNotLow(true)
                .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                .build()

            val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                24, TimeUnit.HOURS,  // Her 24 saatte bir
                15, TimeUnit.MINUTES // Esneklik penceresi
            )
                .setConstraints(constraints)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                // Varolan görevi tut; güç yönetimi için önemli
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
        }

        /**
         * Planlı görevleri iptal eder.
         */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        }
    }

    override fun doWork(): Result {
        return try {
            // Widget'ı yenile
            refreshWidget()
            Result.success()
        } catch (e: Exception) {
            // Hata olursa tekrar dene (en fazla 3 kez)
            Result.retry()
        }
    }

    /**
     * Android AppWidget sistemine güncelleme sinyali gönderir.
     * home_widget ortak deposundaki veriler zaten Flutter tarafından yazılmış olmalıdır.
     */
    private fun refreshWidget() {
        val intent = android.content.Intent(
            applicationContext,
            IslamicAppWidget::class.java
        ).apply {
            action = android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = android.appwidget.AppWidgetManager
                .getInstance(applicationContext)
                .getAppWidgetIds(
                    android.content.ComponentName(
                        applicationContext,
                        IslamicAppWidget::class.java
                    )
                )
            putExtra(android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        applicationContext.sendBroadcast(intent)
    }
}
