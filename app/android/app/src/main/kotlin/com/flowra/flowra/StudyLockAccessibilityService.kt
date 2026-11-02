package com.flowra.flowra

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent

/**
 * AccessibilityService fallback for real-time, low-latency detection of blocked apps.
 * Triggers instantly when a user launches or switches to a blocked application,
 * immediately redirecting to device Home and displaying the Study Mode Active overlay.
 */
class StudyLockAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "StudyLockA11yService"
    }

    private val handler = Handler(Looper.getMainLooper())
    private var lastBlockedPkg: String? = null
    private var lastBlockedTime: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "StudyLockAccessibilityService connected.")
        StudyLockManager.initialize(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val pkgName = event.packageName?.toString() ?: return

        // Skip our own app
        if (pkgName == packageName) return

        if (StudyLockManager.isLockActive && StudyLockManager.isPackageBlocked(pkgName)) {
            val now = System.currentTimeMillis()
            // Throttle duplicate events within 800ms
            if (pkgName == lastBlockedPkg && (now - lastBlockedTime) < 800) {
                return
            }

            lastBlockedPkg = pkgName
            lastBlockedTime = now
            Log.d(TAG, "Intercepted blocked application via Accessibility: $pkgName")

            // 1. Immediately return to Home screen
            performGlobalAction(GLOBAL_ACTION_HOME)

            // 2. Record the blocked attempt in manager
            StudyLockManager.recordBlockedAttempt(this, pkgName)

            // 3. Show Study Lock overlay after brief 150ms delay to let Home settle
            handler.postDelayed({
                val overlayIntent = Intent(this, StudyLockOverlayActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                }
                startActivity(overlayIntent)
            }, 150)
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "StudyLockAccessibilityService interrupted.")
    }
}
