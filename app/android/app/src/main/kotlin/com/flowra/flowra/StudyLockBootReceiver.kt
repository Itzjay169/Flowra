package com.flowra.flowra

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot receiver to restore Study Lock state upon device reboot or package update.
 */
class StudyLockBootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "StudyLockBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            Log.d(TAG, "Device rebooted or package replaced ($action). Restoring Study Lock state...")
            StudyLockManager.initialize(context)

            if (StudyLockManager.isLockActive) {
                val remaining = StudyLockManager.getRemainingSeconds()
                if (remaining > 0) {
                    Log.d(TAG, "Active Study Lock restored with $remaining seconds remaining.")
                    val serviceIntent = Intent(context, StudyLockService::class.java).apply {
                        this.action = StudyLockService.ACTION_START_LOCK
                    }
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                } else {
                    StudyLockManager.stopLock(context, completed = true)
                }
            }
        }
    }
}
