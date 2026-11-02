package com.flowra.flowra

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Foreground Service running during an active Study Lock session.
 * Monitors top applications via UsageStatsManager loop,
 * enforces distraction-free focus, updates notification timer,
 * and handles completion/early termination.
 */
class StudyLockService : Service() {

    companion object {
        private const val TAG = "StudyLockService"
        const val NOTIFICATION_ID = 8881
        const val CHANNEL_ID = "study_lock_active_v1"
        const val ACTION_START_LOCK = "com.flowra.flowra.START_LOCK"
        const val ACTION_STOP_LOCK = "com.flowra.flowra.STOP_LOCK"
    }

    private val handler = Handler(Looper.getMainLooper())
    private var isLoopRunning = false
    private var usageStatsManager: UsageStatsManager? = null
    private var lastForegroundPackage: String? = null
    private var lastNotificationUpdateSeconds: Long = -1

    private val monitoringRunnable = object : Runnable {
        override fun run() {
            if (!StudyLockManager.isLockActive) {
                stopSelf()
                return
            }

            val remainingSeconds = StudyLockManager.getRemainingSeconds()
            if (remainingSeconds <= 0) {
                onSessionTimerCompleted()
                return
            }

            // Update persistent notification every 15 seconds or at minute boundaries
            if (lastNotificationUpdateSeconds - remainingSeconds >= 15 || lastNotificationUpdateSeconds < 0) {
                lastNotificationUpdateSeconds = remainingSeconds
                updateNotification(remainingSeconds)
            }

            // Foreground app detection via UsageStatsManager
            checkForegroundApp()

            // Loop every 500ms for responsive detection
            handler.postDelayed(this, 500)
        }
    }

    override fun onCreate() {
        super.onCreate()
        StudyLockManager.initialize(this)
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_LOCK) {
            StudyLockManager.stopLock(this, endedEarly = true)
            stopSelf()
            return START_NOT_STICKY
        }

        val remainingSeconds = StudyLockManager.getRemainingSeconds()
        val notification = buildNotification(remainingSeconds)
        startForeground(NOTIFICATION_ID, notification)

        if (!isLoopRunning) {
            isLoopRunning = true
            handler.post(monitoringRunnable)
        }

        return START_STICKY
    }

    private fun checkForegroundApp() {
        if (usageStatsManager == null) return

        try {
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 2500 // Last 2.5 seconds
            val usageEvents = usageStatsManager!!.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()
            var currentPackage: String? = null

            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                    event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
                ) {
                    currentPackage = event.packageName
                }
            }

            if (currentPackage != null && currentPackage != packageName) {
                lastForegroundPackage = currentPackage
                if (StudyLockManager.isPackageBlocked(currentPackage)) {
                    Log.d(TAG, "Blocked app detected in foreground: $currentPackage")
                    StudyLockManager.recordBlockedAttempt(this, currentPackage)

                    // Launch overlay to block view
                    launchOverlayActivity()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking foreground app: ${e.message}")
        }
    }

    private fun launchOverlayActivity() {
        val overlayIntent = Intent(this, StudyLockOverlayActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
        }
        startActivity(overlayIntent)
    }

    private fun onSessionTimerCompleted() {
        Log.d(TAG, "Study Lock session completed successfully!")
        StudyLockManager.stopLock(this, endedEarly = false, completed = true)

        // Show completion notification
        showCompletionNotification()
        stopSelf()
    }

    private fun showCompletionNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val tapIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🎉 Study Lock Completed!")
            .setContentText("Great job! You stayed focused for ${StudyLockManager.durationMinutes} minutes.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        nm.notify(NOTIFICATION_ID + 1, notification)
    }

    private fun buildNotification(remainingSeconds: Long): Notification {
        val minutes = remainingSeconds / 60
        val seconds = remainingSeconds % 60
        val timeFormatted = String.format("%02d:%02d", minutes, seconds)

        // Tap to open app
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val openPendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Action: End Session early
        val endIntent = Intent(this, StudyLockActionReceiver::class.java).apply {
            action = StudyLockActionReceiver.ACTION_END_LOCK
        }
        val endPendingIntent = PendingIntent.getBroadcast(
            this,
            1,
            endIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🔒 Study Lock Active")
            .setContentText("${StudyLockManager.currentTaskTitle} • Remaining: $timeFormatted")
            .setSubText("Distraction Blocker")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "End Session", endPendingIntent)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun updateNotification(remainingSeconds: Long) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification(remainingSeconds))
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Study Lock Active Session",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Persistent status and timer while Study Lock distraction blocker is active"
                setShowBadge(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isLoopRunning = false
        handler.removeCallbacks(monitoringRunnable)
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
