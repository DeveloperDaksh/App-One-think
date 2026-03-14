package com.justonething.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AppInterceptorService : Service() {

    private val CHANNEL_ID = "AppInterceptorChannel"
    private val NOTIFICATION_ID = 1

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    private var lastPackage: String? = null
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())
    private val runnable = object : Runnable {
        override fun run() {
            checkForegroundApp()
            handler.postDelayed(this, 1000)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        handler.post(runnable)
        return START_STICKY
    }

    private fun checkForegroundApp() {
        val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as android.app.usage.UsageStatsManager
        val time = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(android.app.usage.UsageStatsManager.INTERVAL_DAILY, time - 10000, time)
        
        if (stats != null) {
            val topActivity = stats.sortedByDescending { it.lastTimeUsed }.firstOrNull()
            val packageName = topActivity?.packageName
            
            if (packageName != lastPackage) {
                lastPackage = packageName
                if (isAppBlocked(packageName)) {
                    triggerOverlay(packageName)
                }
            }
        }
    }

    private fun isAppBlocked(packageName: String?): Boolean {
        // Logic to check Room DB for blocked packages
        return false // Placeholder
    }

    private fun triggerOverlay(packageName: String?) {
        val intent = Intent(this, OverlayActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("PACKAGE_NAME", packageName)
        }
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(runnable)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Just One Thing is Active")
            .setContentText("Helping you stay mindful.")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "App Interceptor Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
