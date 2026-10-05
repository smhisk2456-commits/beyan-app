package com.example.islamic_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

/**
 * Android Widget Provider
 * Hem namaz vakitlerini gösterir, hem de kullanıcının belirlediği dakika
 * aralıklarıyla (örn: 10dk) ayetleri döngüsel olarak ekrana yansıtır.
 */
class IslamicAppWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_CYCLE_VERSE = "com.example.islamic_app.CYCLE_VERSE"
        
        // Flutter tarafından home_widget alanına yazılan key'ler
        private const val KEY_NEXT_PRAYER      = "widget_next_prayer"
        private const val KEY_NEXT_PRAYER_TIME = "widget_next_prayer_time"
        private const val KEY_COUNTDOWN        = "widget_countdown"
        private const val KEY_VERSES_JSON      = "widget_verses_json"
        private const val KEY_UPDATE_INTERVAL  = "widget_update_interval" // Dakika cinsinden

        // Android'in kendi hafızasında tuttuğu mevcut ayet indeksi
        private const val PREFS_NAME = "WidgetPrefs"
        private const val PREF_CURRENT_INDEX = "current_verse_index"

        fun scheduleNextUpdate(context: Context) {
            // Güvenli ve kısa güncelleme aralığı (3 ile 15 dakika arası, donma ve hata önleme)
            val widgetData = HomeWidgetPlugin.getData(context)
            val intervalMinutes = widgetData.getInt(KEY_UPDATE_INTERVAL, 5).coerceIn(3, 15)
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, IslamicAppWidget::class.java).apply {
                action = ACTION_CYCLE_VERSE
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Doze modundayken bile yaklaşık sürede tetiklemek için Inexact alarm
            val triggerTime = SystemClock.elapsedRealtime() + (intervalMinutes * 60 * 1000)
            alarmManager.setWindow(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerTime,
                1000 * 60, // 1 dk esneklik penceresi
                pendingIntent
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_CYCLE_VERSE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, IslamicAppWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            // İndeksi artır ve güncelle
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val currentIndex = prefs.getInt(PREF_CURRENT_INDEX, 0)
            prefs.edit().putInt(PREF_CURRENT_INDEX, currentIndex + 1).apply()
            
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val widgetData = HomeWidgetPlugin.getData(context)
        
        val nextPrayer = widgetData.getString(KEY_NEXT_PRAYER, "Namaz") ?: "Namaz"
        val nextTime   = widgetData.getString(KEY_NEXT_PRAYER_TIME, "--:--") ?: "--:--"
        val countdown  = widgetData.getString(KEY_COUNTDOWN, "Hesaplanıyor...") ?: "Hesaplanıyor..."
        
        // JSON'dan ayeti çek
        var ayahRef = "Fatiha 1"
        var ayahText = "Bismillahirrahmanirrahim"
        val versesJsonStr = widgetData.getString(KEY_VERSES_JSON, "[]")
        
        try {
            val versesArray = JSONArray(versesJsonStr)
            if (versesArray.length() > 0) {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val currentIndex = prefs.getInt(PREF_CURRENT_INDEX, 0)
                // Modulo işlemi ile indeks listeyi aşmasın
                val safeIndex = currentIndex % versesArray.length()
                
                val verseObj = versesArray.getJSONObject(safeIndex)
                ayahRef = verseObj.getString("ref")
                ayahText = verseObj.getString("text")
            }
        } catch (e: Exception) {
            // JSON Parse hatası, varsayılan değerleri kullan
        }

        // Görünümü güncelle
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.islamic_app_widget)
            
            // Eğer yeni tasarıma (resimdeki gibi) uygun layout varsa:
            // Sizin attığınız resimde üstte "An-Nahl 114" ve yanda hilal ikonu, altta metin var.
            // Biz varsayılan islamic_app_widget.xml'deki id'leri kullanıyoruz.
            views.setTextViewText(R.id.widget_title, ayahRef)
            views.setTextViewText(R.id.widget_ayah, ayahText)
            views.setTextViewText(R.id.widget_prayer_name, "$nextPrayer $nextTime")
            views.setTextViewText(R.id.widget_countdown, "• $countdown")
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Bir sonraki güncellemeyi planla
        scheduleNextUpdate(context)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt(PREF_CURRENT_INDEX, 0).apply()
        scheduleNextUpdate(context)
    }
}
