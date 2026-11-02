package com.flowra.flowra

import android.app.AlarmManager
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity connecting Flutter to native Study Lock services,
 * permissions, and app management.
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.flowra.flowra/study_lock"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        StudyLockManager.initialize(this)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    result.success(checkAllPermissions())
                }
                "requestUsageAccess" -> {
                    openUsageAccessSettings()
                    result.success(true)
                }
                "requestAccessibility" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                "requestOverlayPermission" -> {
                    openOverlaySettings()
                    result.success(true)
                }
                "requestExactAlarmPermission" -> {
                    openExactAlarmSettings()
                    result.success(true)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    openBatteryOptimizationSettings()
                    result.success(true)
                }
                "openAppInfoSettings" -> {
                    openAppInfoSettings()
                    result.success(true)
                }
                "isRestrictedSettingsLikely" -> {
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                }
                "getInstalledApps" -> {
                    result.success(queryInstalledApps())
                }
                "startStudyLock" -> {
                    val taskId = call.argument<Int>("taskId")
                    val taskTitle = call.argument<String>("taskTitle") ?: "Study Session"
                    val duration = call.argument<Int>("durationMinutes") ?: 25
                    val packages = call.argument<List<String>>("blockedPackages")

                    StudyLockManager.startLock(this, taskId, taskTitle, duration, packages)
                    result.success(StudyLockManager.getStatusMap())
                }
                "stopStudyLock" -> {
                    val endedEarly = call.argument<Boolean>("endedEarly") ?: true
                    StudyLockManager.stopLock(this, endedEarly = endedEarly)
                    result.success(true)
                }
                "getStudyLockStatus" -> {
                    result.success(StudyLockManager.getStatusMap())
                }
                "updateBlockedPackages" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    StudyLockManager.updateBlockedPackages(this, packages)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Bridge manager callbacks to Flutter
        StudyLockManager.onSessionStateChanged = { statusMap ->
            runOnUiThread {
                methodChannel?.invokeMethod("onSessionStateChanged", statusMap)
            }
        }

        StudyLockManager.onBlockedAttemptDetected = { pkg, label, time ->
            runOnUiThread {
                methodChannel?.invokeMethod(
                    "onBlockedAttempt",
                    mapOf(
                        "packageName" to pkg,
                        "appName" to label,
                        "timestamp" to time
                    )
                )
            }
        }
    }

    private fun checkAllPermissions(): Map<String, Boolean> {
        val hasNotifications = NotificationManagerCompat.from(this).areNotificationsEnabled()

        val hasExactAlarm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.canScheduleExactAlarms()
        } else {
            true
        }

        val hasUsageAccess = isUsageAccessGranted()
        val hasAccessibility = isAccessibilityServiceEnabled()

        val hasOverlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }

        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val isIgnoringBatteryOptimizations = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pm.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }

        return mapOf(
            "notification" to hasNotifications,
            "exactAlarm" to hasExactAlarm,
            "usageAccess" to hasUsageAccess,
            "accessibility" to hasAccessibility,
            "overlay" to hasOverlay,
            "batteryOptimization" to isIgnoringBatteryOptimizations
        )
    }

    private fun isUsageAccessGranted(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) {
            false
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedServiceName = "$packageName/${StudyLockAccessibilityService::class.java.canonicalName}"
        return try {
            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            enabledServices.split(":").any {
                it.equals(expectedServiceName, ignoreCase = true) ||
                        it.contains(StudyLockAccessibilityService::class.java.simpleName, ignoreCase = true)
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun openUsageAccessSettings() {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        } catch (_: Exception) {
            startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
        }
    }

    private fun openAccessibilitySettings() {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        } catch (_: Exception) {
            startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
        }
    }

    private fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                ).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            } catch (_: Exception) {
                startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            }
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val intent = Intent(
                    Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                    Uri.parse("package:$packageName")
                ).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            } catch (_: Exception) {
                startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            }
        }
    }

    private fun openBatteryOptimizationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            } catch (_: Exception) {
                try {
                    val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                } catch (_: Exception) {}
            }
        }
    }

    private fun openAppInfoSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        } catch (_: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            } catch (_: Exception) {}
        }
    }

    private fun queryInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfoList = pm.queryIntentActivities(intent, 0)
        val appList = mutableListOf<Map<String, Any>>()
        val seenPackages = mutableSetOf<String>()

        for (info in resolveInfoList) {
            val pkg = info.activityInfo.packageName
            if (pkg == packageName || seenPackages.contains(pkg)) continue
            seenPackages.add(pkg)

            val label = info.loadLabel(pm).toString()
            val isSystem = (info.activityInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            appList.add(
                mapOf(
                    "packageName" to pkg,
                    "appName" to label,
                    "isSystemApp" to isSystem
                )
            )
        }

        return appList.sortedBy { it["appName"] as String }
    }
}
