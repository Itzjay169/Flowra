package com.flowra.flowra

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Full-screen overlay activity displayed when a user attempts to launch
 * a blocked application during an active Study Lock session.
 * Displays current task title, live remaining countdown, motivational quote,
 * attempt count, and controls to return to Flowra or end early.
 */
class StudyLockOverlayActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var timerTextView: TextView
    private lateinit var attemptTextView: TextView
    private lateinit var quoteTextView: TextView

    private val quotes = listOf(
        "\"Focus is a muscle. Every time you resist a distraction, you get stronger.\"",
        "\"Discipline is choosing between what you want now and what you want most.\"",
        "\"Your future is created by what you do today, not tomorrow.\"",
        "\"Small daily improvements over time lead to stunning results.\"",
        "\"Distractions are costly. Keep your eyes on the goal!\""
    )

    private val timerRunnable = object : Runnable {
        override fun run() {
            if (!StudyLockManager.isLockActive) {
                finish()
                return
            }

            val remainingSeconds = StudyLockManager.getRemainingSeconds()
            if (remainingSeconds <= 0) {
                finish()
                return
            }

            val minutes = remainingSeconds / 60
            val seconds = remainingSeconds % 60
            timerTextView.text = String.format("%02d:%02d", minutes, seconds)
            attemptTextView.text = "🛡️ Blocked Distraction Attempts: ${StudyLockManager.blockedAttemptsCount}"

            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Configure window for full-screen lock presentation
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        setContentView(createOverlayView())
    }

    override fun onResume() {
        super.onResume()
        if (!StudyLockManager.isLockActive) {
            finish()
            return
        }
        handler.post(timerRunnable)
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacks(timerRunnable)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Redirect to Home instead of back to blocked app
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    private fun createOverlayView(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0A0E1A"))
            setPadding(48, 64, 48, 64)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }

        // Lock Icon / Badge
        val iconText = TextView(this).apply {
            text = "🔒"
            textSize = 54f
            gravity = Gravity.CENTER
        }
        root.addView(iconText)

        // Header Title
        val headerTitle = TextView(this).apply {
            text = "Study Mode Active"
            textSize = 28f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 16, 0, 8)
        }
        root.addView(headerTitle)

        // Task Name
        val taskNameView = TextView(this).apply {
            text = StudyLockManager.currentTaskTitle
            textSize = 18f
            setTextColor(Color.parseColor("#A5B4FC")) // Light indigo
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 24)
        }
        root.addView(taskNameView)

        // Circular Timer Card Container
        val timerCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(32, 28, 32, 28)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1E1B4B")) // Deep indigo
                cornerRadius = 32f
                setStroke(3, Color.parseColor("#4F46E5"))
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(24, 0, 24, 24)
            }
        }

        val timerLabel = TextView(this).apply {
            text = "TIME REMAINING"
            textSize = 12f
            setTextColor(Color.parseColor("#94A3B8"))
            letterSpacing = 0.15f
            gravity = Gravity.CENTER
        }
        timerCard.addView(timerLabel)

        timerTextView = TextView(this).apply {
            val remaining = StudyLockManager.getRemainingSeconds()
            text = String.format("%02d:%02d", remaining / 60, remaining % 60)
            textSize = 48f
            setTextColor(Color.WHITE)
            typeface = Typeface.MONOSPACE
            gravity = Gravity.CENTER
            setPadding(0, 8, 0, 8)
        }
        timerCard.addView(timerTextView)

        attemptTextView = TextView(this).apply {
            text = "🛡️ Blocked Distraction Attempts: ${StudyLockManager.blockedAttemptsCount}"
            textSize = 13f
            setTextColor(Color.parseColor("#F59E0B")) // Amber
            gravity = Gravity.CENTER
        }
        timerCard.addView(attemptTextView)
        root.addView(timerCard)

        // Motivational Quote
        quoteTextView = TextView(this).apply {
            val quote = quotes[(System.currentTimeMillis() % quotes.size).toInt()]
            text = quote
            textSize = 14f
            setTextColor(Color.parseColor("#94A3B8"))
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.ITALIC)
            gravity = Gravity.CENTER
            setPadding(16, 0, 16, 36)
        }
        root.addView(quoteTextView)

        // Primary Button: Back to Flowra / Focus
        val backToAppBtn = Button(this).apply {
            text = "Return to Flowra"
            setTextColor(Color.WHITE)
            textSize = 15f
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#4F46E5"))
                cornerRadius = 24f
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                130
            ).apply {
                setMargins(16, 0, 16, 16)
            }
            setOnClickListener {
                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                if (launchIntent != null) {
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    startActivity(launchIntent)
                }
                finish()
            }
        }
        root.addView(backToAppBtn)

        // Secondary Button: Exit to Home Screen
        val homeBtn = Button(this).apply {
            text = "Go to Home Screen"
            setTextColor(Color.parseColor("#E2E8F0"))
            textSize = 14f
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1E293B"))
                cornerRadius = 24f
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                120
            ).apply {
                setMargins(16, 0, 16, 16)
            }
            setOnClickListener {
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(homeIntent)
                finish()
            }
        }
        root.addView(homeBtn)

        // Danger Button: End Study Session Early
        val endSessionBtn = Button(this).apply {
            text = "End Study Session Early"
            setTextColor(Color.parseColor("#FCA5A5"))
            textSize = 13f
            background = GradientDrawable().apply {
                setColor(Color.TRANSPARENT)
                cornerRadius = 24f
                setStroke(2, Color.parseColor("#EF4444"))
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                110
            ).apply {
                setMargins(16, 8, 16, 0)
            }
            setOnClickListener {
                showEndEarlyConfirmation()
            }
        }
        root.addView(endSessionBtn)

        return root
    }

    private fun showEndEarlyConfirmation() {
        AlertDialog.Builder(this)
            .setTitle("End Study Session?")
            .setMessage("Are you sure you want to stop Study Lock early? Unlocking now will end distraction blocking.")
            .setPositiveButton("End Session") { _, _ ->
                StudyLockManager.stopLock(this, endedEarly = true)
                finish()
            }
            .setNegativeButton("Keep Focusing", null)
            .show()
    }
}
