package com.flowra.flowra

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Handles Study Lock notification actions:
 * - Accept & Start Study Lock
 * - Reject / Skip Study Lock
 * - End Active Study Lock
 */
class StudyLockActionReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "StudyLockReceiver"
        const val ACTION_ACCEPT_LOCK = "com.flowra.flowra.ACTION_ACCEPT_STUDY_LOCK"
        const val ACTION_REJECT_LOCK = "com.flowra.flowra.ACTION_REJECT_STUDY_LOCK"
        const val ACTION_END_LOCK = "com.flowra.flowra.ACTION_END_STUDY_LOCK"

        const val EXTRA_TASK_ID = "task_id"
        const val EXTRA_TASK_TITLE = "task_title"
        const val EXTRA_DURATION_MINUTES = "duration_minutes"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        Log.d(TAG, "Received action: $action")

        val notifId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        if (notifId != -1) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.cancel(notifId)
        }

        when (action) {
            ACTION_ACCEPT_LOCK -> {
                val taskId = intent.getIntExtra(EXTRA_TASK_ID, -1).takeIf { it != -1 }
                val taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: "Study Session"
                val duration = intent.getIntExtra(EXTRA_DURATION_MINUTES, 25)

                Log.d(TAG, "Accepted Study Lock for task: $taskTitle ($duration min)")
                StudyLockManager.startLock(context, taskId, taskTitle, duration)

                // Notify Flutter app of accepted lock session
                val broadcast = Intent(context.packageName + ".STUDY_LOCK_STATE_CHANGED").apply {
                    putExtra("status", "accepted")
                    putExtra("task_id", taskId ?: -1)
                    putExtra("task_title", taskTitle)
                    putExtra("duration_minutes", duration)
                    setPackage(context.packageName)
                }
                context.sendBroadcast(broadcast)
            }

            ACTION_REJECT_LOCK -> {
                val taskId = intent.getIntExtra(EXTRA_TASK_ID, -1).takeIf { it != -1 }
                val taskTitle = intent.getStringExtra(EXTRA_TASK_TITLE) ?: "Study Session"
                val duration = intent.getIntExtra(EXTRA_DURATION_MINUTES, 25)

                Log.d(TAG, "Rejected Study Lock for task: $taskTitle")

                // Notify Flutter app of skipped lock session
                val broadcast = Intent(context.packageName + ".STUDY_LOCK_STATE_CHANGED").apply {
                    putExtra("status", "skipped")
                    putExtra("task_id", taskId ?: -1)
                    putExtra("task_title", taskTitle)
                    putExtra("duration_minutes", duration)
                    setPackage(context.packageName)
                }
                context.sendBroadcast(broadcast)
            }

            ACTION_END_LOCK -> {
                Log.d(TAG, "Ending active Study Lock via notification action")
                StudyLockManager.stopLock(context, endedEarly = true)
            }
        }
    }
}
