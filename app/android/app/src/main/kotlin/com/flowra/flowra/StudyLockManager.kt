package com.flowra.flowra

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Singleton state manager for Study Lock distraction blocking.
 * Keeps track of the active lock session, blocked package list,
 * remaining time, and blocked application attempts.
 */
object StudyLockManager {
    private const val TAG = "StudyLockManager"
    private const val PREFS_NAME = "flowra_study_lock_prefs"
    private const val KEY_IS_ACTIVE = "key_is_active"
    private const val KEY_TASK_ID = "key_task_id"
    private const val KEY_TASK_TITLE = "key_task_title"
    private const val KEY_START_TIME = "key_start_time"
    private const val KEY_END_TIME = "key_end_time"
    private const val KEY_DURATION_MINUTES = "key_duration_minutes"
    private const val KEY_BLOCKED_PACKAGES = "key_blocked_packages"
    private const val KEY_BLOCKED_ATTEMPTS = "key_blocked_attempts"

    var isLockActive: Boolean = false
        private set

    var currentTaskId: Int? = null
        private set

    var currentTaskTitle: String = "Study Session"
        private set

    var durationMinutes: Int = 25
        private set

    var startTimeMillis: Long = 0L
        private set

    var endTimeMillis: Long = 0L
        private set

    var blockedAttemptsCount: Int = 0
        private set

    var isPausedDueToPermission: Boolean = false

    private val blockedPackages = mutableSetOf<String>()
    private var lastAttemptPackage: String? = null
    private var lastAttemptTimestamp: Long = 0L

    // Listener for Flutter MethodChannel updates
    var onSessionStateChanged: ((Map<String, Any?>) -> Unit)? = null
    var onBlockedAttemptDetected: ((String, String, Long) -> Unit)? = null

    // Default package list if none provided
    val defaultBlockedList = listOf(
        "com.google.android.youtube",
        "com.instagram.android",
        "com.facebook.katana",
        "com.whatsapp",
        "com.snapchat.android",
        "org.telegram.messenger",
        "com.twitter.android",
        "com.reddit.frontpage",
        "com.netflix.mediaclient",
        "com.discord"
    )

    fun initialize(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        isLockActive = prefs.getBoolean(KEY_IS_ACTIVE, false)
        currentTaskId = if (prefs.contains(KEY_TASK_ID)) prefs.getInt(KEY_TASK_ID, -1) else null
        currentTaskTitle = prefs.getString(KEY_TASK_TITLE, "Study Session") ?: "Study Session"
        durationMinutes = prefs.getInt(KEY_DURATION_MINUTES, 25)
        startTimeMillis = prefs.getLong(KEY_START_TIME, 0L)
        endTimeMillis = prefs.getLong(KEY_END_TIME, 0L)
        blockedAttemptsCount = prefs.getInt(KEY_BLOCKED_ATTEMPTS, 0)

        val savedPackages = prefs.getStringSet(KEY_BLOCKED_PACKAGES, null)
        blockedPackages.clear()
        if (savedPackages != null && savedPackages.isNotEmpty()) {
            blockedPackages.addAll(savedPackages)
        } else {
            blockedPackages.addAll(defaultBlockedList)
        }

        // Verify if session has expired while app was dead
        if (isLockActive && System.currentTimeMillis() >= endTimeMillis) {
            Log.d(TAG, "Restored session has already expired. Stopping.")
            stopLock(context, endedEarly = false, completed = true)
        }
    }

    fun startLock(
        context: Context,
        taskId: Int?,
        taskTitle: String,
        durationMin: Int,
        packagesToBlock: List<String>? = null
    ) {
        isLockActive = true
        isPausedDueToPermission = false
        currentTaskId = taskId
        currentTaskTitle = if (taskTitle.isNotBlank()) taskTitle else "Study Session"
        durationMinutes = if (durationMin > 0) durationMin else 25
        startTimeMillis = System.currentTimeMillis()
        endTimeMillis = startTimeMillis + (durationMinutes * 60 * 1000L)
        blockedAttemptsCount = 0

        if (packagesToBlock != null && packagesToBlock.isNotEmpty()) {
            blockedPackages.clear()
            blockedPackages.addAll(packagesToBlock)
        } else if (blockedPackages.isEmpty()) {
            blockedPackages.addAll(defaultBlockedList)
        }

        saveState(context)

        // Start foreground service
        val serviceIntent = Intent(context, StudyLockService::class.java).apply {
            action = StudyLockService.ACTION_START_LOCK
        }
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting StudyLockService: ${e.message}")
        }

        notifyFlutterStateChanged()
    }

    fun stopLock(context: Context, endedEarly: Boolean = false, completed: Boolean = false) {
        if (!isLockActive) return

        isLockActive = false
        isPausedDueToPermission = false

        // Stop foreground service
        val serviceIntent = Intent(context, StudyLockService::class.java).apply {
            action = StudyLockService.ACTION_STOP_LOCK
        }
        try {
            context.stopService(serviceIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping service: ${e.message}")
        }

        clearState(context)
        notifyFlutterStateChanged()

        // Send local broadcast so Flutter or receivers can update session history
        val broadcast = Intent(context.packageName + ".STUDY_LOCK_STATE_CHANGED").apply {
            putExtra("status", if (completed) "completed" else if (endedEarly) "ended_early" else "stopped")
            putExtra("task_id", currentTaskId ?: -1)
            putExtra("duration_minutes", durationMinutes)
            putExtra("elapsed_seconds", getElapsedTimeSeconds())
            putExtra("blocked_attempts", blockedAttemptsCount)
            setPackage(context.packageName)
        }
        context.sendBroadcast(broadcast)
    }

    fun isPackageBlocked(packageName: String): Boolean {
        if (!isLockActive || isPausedDueToPermission) return false
        return blockedPackages.contains(packageName)
    }

    fun recordBlockedAttempt(context: Context, packageName: String) {
        val now = System.currentTimeMillis()
        // Debounce repeated hits for the same package within 1.5 seconds
        if (packageName == lastAttemptPackage && (now - lastAttemptTimestamp) < 1500) {
            return
        }

        lastAttemptPackage = packageName
        lastAttemptTimestamp = now
        blockedAttemptsCount++

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt(KEY_BLOCKED_ATTEMPTS, blockedAttemptsCount).apply()

        // Resolve app label
        val appLabel = try {
            val pm = context.packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(info).toString()
        } catch (_: Exception) {
            packageName
        }

        // Notify Flutter
        Handler(Looper.getMainLooper()).post {
            onBlockedAttemptDetected?.invoke(packageName, appLabel, now)
        }

        notifyFlutterStateChanged()
    }

    fun updateBlockedPackages(context: Context, packages: List<String>) {
        blockedPackages.clear()
        blockedPackages.addAll(packages)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putStringSet(KEY_BLOCKED_PACKAGES, blockedPackages.toSet()).apply()
    }

    fun getBlockedPackages(): List<String> = blockedPackages.toList()

    fun getRemainingSeconds(): Long {
        if (!isLockActive) return 0L
        val remaining = (endTimeMillis - System.currentTimeMillis()) / 1000L
        return if (remaining > 0) remaining else 0L
    }

    fun getElapsedTimeSeconds(): Long {
        if (startTimeMillis == 0L) return 0L
        val elapsed = (System.currentTimeMillis() - startTimeMillis) / 1000L
        return if (elapsed > 0) elapsed else 0L
    }

    fun getStatusMap(): Map<String, Any?> {
        return mapOf(
            "isActive" to isLockActive,
            "isPaused" to isPausedDueToPermission,
            "taskId" to currentTaskId,
            "taskTitle" to currentTaskTitle,
            "durationMinutes" to durationMinutes,
            "remainingSeconds" to getRemainingSeconds(),
            "elapsedSeconds" to getElapsedTimeSeconds(),
            "blockedAttempts" to blockedAttemptsCount,
            "blockedPackages" to blockedPackages.toList()
        )
    }

    private fun saveState(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY_IS_ACTIVE, isLockActive)
            .putInt(KEY_TASK_ID, currentTaskId ?: -1)
            .putString(KEY_TASK_TITLE, currentTaskTitle)
            .putInt(KEY_DURATION_MINUTES, durationMinutes)
            .putLong(KEY_START_TIME, startTimeMillis)
            .putLong(KEY_END_TIME, endTimeMillis)
            .putInt(KEY_BLOCKED_ATTEMPTS, blockedAttemptsCount)
            .putStringSet(KEY_BLOCKED_PACKAGES, blockedPackages.toSet())
            .apply()
    }

    private fun clearState(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY_IS_ACTIVE, false)
            .putInt(KEY_BLOCKED_ATTEMPTS, 0)
            .apply()
    }

    private fun notifyFlutterStateChanged() {
        val status = getStatusMap()
        Handler(Looper.getMainLooper()).post {
            onSessionStateChanged?.invoke(status)
        }
    }
}
