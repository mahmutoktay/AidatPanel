package com.aidatpanel.app

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

/**
 * FCM tray bildirimleri için kanal — Flutter başlamadan önce oluşturulur.
 * (Android 8+ kanal yoksa kapalı uygulama bildirimi gösterilmez.)
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            "Bildirimler",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "AidatPanel bildirimleri"
            enableVibration(true)
        }
        getSystemService(NotificationManager::class.java)
            ?.createNotificationChannel(channel)
    }

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "aidatpanel_high"
    }
}
