# Flowra ⏳💰

[![CI/CD Pipeline](https://github.com/Itzjay169/Flowra/actions/workflows/ci.yml/badge.svg)](https://github.com/Itzjay169/Flowra/actions/workflows/ci.yml)
[![Website](https://img.shields.io/badge/Website-Live-4F46E5?logo=google-chrome&logoColor=white)](https://itzjay169.github.io/Flowra/)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.5%2B-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**Flowra** is a fast, 100% offline-first Flutter mobile application crafted by **Vexora Technology** to help students and professionals succeed, developed by **Jay**. It unites an intelligent routine & timetable planner with exact alarm reminders, distraction-free Study Lock focus shielding, and an intuitive daily expense tracker.

> **Zero Cloud. Zero Ads. Complete Privacy.**  
> All schedules, routines, tasks, expenses, and budget records remain 100% on your device. The app operates completely without an internet connection and performs reliably across airplane mode, battery saver, app restarts, and system reboots.
>
> 🌐 **Live Website**: [https://itzjay169.github.io/Flowra/](https://itzjay169.github.io/Flowra/)

---

<!-- VERSION_SECTION_START -->
## 📦 Latest Version & Releases

> **Latest Release**: `v1.2.0` (Build 3) • **Date**: 2026-11-02  
> 📥 **Direct Download**: [Flowra-v1.2.0.apk](https://itzjay169.github.io/Flowra/Flowra-v1.2.0.apk)  

### Version History

| Version | Build | Date | Download |
|---|---|---|---|
| `v1.2.0` | 3 | 2026-11-02 | [Flowra-v1.2.0.apk](https://itzjay169.github.io/Flowra/Flowra-v1.2.0.apk) |
| `v1.1.0` | 2 | 2026-10-14 | [Flowra-v1.1.0.apk](https://github.com/Itzjay169/Flowra/releases/download/v1.1.0/Flowra-v1.1.0.apk) |
| `v1.0.0` | 1 | 2026-09-28 | [Flowra-v1.0.0.apk](https://github.com/Itzjay169/Flowra/releases/download/v1.0.0/Flowra-v1.0.0.apk) |

*See [CHANGELOG.md](CHANGELOG.md) and [releases.json](releases/releases.json) for full history.*
<!-- VERSION_SECTION_END -->

---

## ✨ Features

### 📅 1. Routine & Timetable Planner
- **Daily & Weekly Views**: Interactive horizontal date timeline with week selector and organized daily task cards.
- **Role-Adaptive Subject & Category Filtering**: Personalized category sets for **Students**, **Working Professionals**, and general users (Work, Study, Meeting, Class, Assignment, Revision, Exam Prep, Errand, Exercise, Health, Family, Personal, Other).
- **Date Picker Navigation**: Jump directly to any past or upcoming date with one tap.
- **Task Management**: Subject tags, priority levels (*Normal*, *Important*, *Critical*), scheduled start/end times, and notes.
- **Flexible Recurrence**: Set tasks to repeat *Once*, *Daily*, *Weekdays*, *Weekly*, or *Custom* days.
- **Time Collision Detection**: Automatic schedule conflict checks that alert you before overlapping tasks are saved.
- **Live Session Progress**: Real-time status badges (*Upcoming*, *Running* with live countdown, *Completed*, *Missed*, and *Skipped*).
- **Instant Focus Mode**: Launch the Pomodoro focus timer directly from any task in Home or Timetable.

### 🔔 2. Strong & Exact Reminders (100% Offline)
- **High-Priority Channel**: Configured with Android `Importance.max` and `Priority.max` to break through quiet modes.
- **Alarm-Style Reminders**: Utilizes Android exact alarm APIs (`exactAllowWhileIdle`) and `fullScreenIntent` for critical tasks.
- **Pre-Alert Warnings**: Optional advance alerts 5, 10, or 15 minutes before scheduled start time.
- **Interactive Notification Actions**:
  - `▶ Start Now` — Transitions task status to *Running*.
  - `⏰ Snooze 10m` — Reschedules alarm notification for 10 minutes later.
  - `✓ Done` — Marks task completed directly from notification tray without opening app.
- **Survives Device Reboot**: Android `BOOT_COMPLETED` receiver automatically reschedules all future alarms upon reboot or timezone shift.
- **Do Not Disturb (DND) Guidance**: Built-in instructions and permission checkers to configure DND exceptions.

### ⏱️ 3. Focus & Pomodoro Mode
- **Distraction-Free Focus Timer**: Full-screen minimalist interface with animated circular progress indicator.
- **Pomodoro Presets**: 25m Standard Focus, 45m Deep Work, 60m Intensive, plus 5m & 15m Break intervals, and Custom minute input.
- **Task Linking**: Connect any scheduled task to the timer; automatically marks the task completed upon session finish.
- **Early Completion**: Mark sessions completed early with tactile haptic feedback.
- **Motivational Focus Quotes**: Encouraging, rotating quotes throughout your focus sessions.

### 💳 4. Daily Expense & Budget Tracker
- **Fast Logging**: Quick-add dialog with categorized tagging (Food, Travel, College, Recharge / Internet, Shopping, Entertainment, Health, Other).
- **Search & Filter Chips**: Instant search by note keyword or filter by category chips.
- **Flexible Grouping**: View expenses grouped by **Day**, **Week**, or **Month**.
- **Payment Method Tagging**: Record Cash, UPI, Card, or Other.
- **Monthly Spending Limits**: Set your overall monthly budget with dynamic progress indicators.
- **Proactive Budget Alerts**: Visual notifications when spending crosses 80% or exceeds 100% of your budget.
- **Rich Spending Analytics**:
  - Category breakdown with interactive pie charts.
  - 30-day spending trends with line charts.
  - Month-over-month spending comparisons.
  - Top spending categories and highest expenditure day highlights.

### 📊 5. Reports & Analytics
- **Routine & Schedule Analytics**: Planned vs. completed tasks, completion rate %, streak counter, total focused hours, and weekly completion bar chart.
- **Financial Analytics**: Daily average spending, remaining monthly budget, category expense bars, and automated financial insights.

### 💾 6. Complete Data Privacy & Control
- **100% Offline SQLite Storage**: Relational schema indexed for fast queries without cloud overhead or external dependencies.
- **CSV Data Export**: One-tap export of expenses into clean CSV files saved directly to device storage.
- **Safe Data Wipe**: Complete data purge option in Settings for complete user autonomy.
- **No Background Telemetry**: Zero analytics SDKs, zero ad networks, zero cloud trackers.

### 💖 7. Developer Support & Connection
- **Support the Developer**: Transparent donation screen with preset amounts (₹10, ₹20, ₹50, ₹100) and custom amount.
- **Direct UPI Deep-Linking**: Native Android UPI app selector (`upi://pay` compatible with Google Pay, PhonePe, Paytm, BHIM, Cred, etc.).
- **Social Profiles**: Connect directly with Jay via GitHub and Instagram.

### 🛡️ 8. Study Lock — Distraction Blocker (Offline)
- **Automatic Distraction Shield**: When a study, class, or focus task begins, Flowra presents an interactive notification: `▶ Start Study Lock` or `✕ Not Now`.
- **Dual-Engine Offline Enforcement**:
  - **Foreground Service**: Lightweight `UsageStatsManager` polling loop (500ms) with persistent notification countdown.
  - **Accessibility Service Fallback**: Ultra-fast event-driven interceptor (<150ms) using `TYPE_WINDOW_STATE_CHANGED` that immediately sends the device to the Home screen and launches the barrier.
- **Full-Screen Focus Barrier (`StudyLockOverlayActivity`)**:
  - Immersive distraction barrier displaying *"Study Mode Active"*, the current task title, and live countdown timer `mm:ss`.
  - Inspiring motivational focus quotes that rotate dynamically.
  - Live blocked attempt counter tracking distraction resistance.
  - Safe exit options: **Return to Flowra**, **Go to Home Screen**, and **End Study Session Early** (with confirmation dialog).
- **Customizable Blocked Apps Manager**:
  - Pre-seeded with popular distraction apps (Instagram, YouTube, TikTok, Snapchat, Facebook, Reddit, Twitter/X, Netflix, Hotstar, Prime Video, Free Fire, BGMI).
  - Searchable installed app picker with live system package detection.
  - One-tap toggle to block or unblock any app on the device.
  - Custom app deletion and reset defaults options.
- **Permission Health Check Diagnostic**:
  - Live status cards for Usage Access, Overlay / Display Over Other Apps, Accessibility Service, and Battery Optimization Exemption.
  - Direct deep-links to Android system settings for one-tap permission granting.
- **Historical Session & Distraction Analytics**:
  - Comprehensive history log of completed and early-ended sessions with timestamps.
  - Timestamped attempt logs recording blocked package names and app titles.
- **Delightful Celebration Effects**:
  - Full-screen multi-color particle confetti celebration dialog with haptic feedback upon successfully finishing study sessions.
  - Fluid animated status badges reflecting live session states.

---

## 🏗 Architecture & Tech Stack

```
Flowra/
├── .github/workflows/                 # CI/CD pipeline configurations
│   ├── ci.yml                         # Lint, test, build, release
│   ├── codeql.yml                     # CodeQL security scanning
│   └── deploy-pages.yml               # GitHub Pages deployment
├── app/                               # Flutter mobile application
│   ├── android/                       # Native Android platform code
│   │   └── app/src/main/
│   │       ├── AndroidManifest.xml    # Permissions & service declarations
│   │       ├── kotlin/.../MainActivity.kt         # MethodChannel bridge
│   │       ├── kotlin/.../StudyLockService.kt      # Foreground blocker service
│   │       ├── kotlin/.../StudyLockAccessibilityService.kt # Event interceptor
│   │       ├── kotlin/.../StudyLockOverlayActivity.kt # Focus barrier UI
│   │       └── res/                               # Resources & themes
│   ├── assets/                        # App icons & images
│   ├── ios/                           # iOS platform (future)
│   ├── lib/                           # Dart source code
│   │   ├── main.dart                  # App entry point & Provider tree
│   │   ├── models/                    # Data models (Task, Expense, Budget, StudyLock)
│   │   ├── services/                  # Core services (DB, notifications, native bridge)
│   │   ├── providers/                 # State management (Provider pattern)
│   │   ├── screens/                   # UI screens (Home, Timetable, Expenses, etc.)
│   │   ├── utils/                     # Constants, helpers, theme
│   │   └── widgets/                   # Shared widgets (footer, celebrations, cards)
│   ├── test/                          # Unit & widget tests (52 tests)
│   ├── pubspec.yaml                   # Flutter dependencies & version
│   └── analysis_options.yaml           # Lint rules
├── website/                           # Static landing page & release tracker
│   ├── index.html                     # Responsive landing page
│   ├── css/style.css                  # Dark-mode styling & animations
│   ├── js/main.js                     # Dynamic releases & contact form
│   ├── privacy.html / terms.html      # Legal pages
│   └── Flowra-v1.2.0.apk             # Direct APK download
├── releases/                          # Release metadata
│   └── releases.json                  # Version catalog & checksums
├── tools/                             # Release automation scripts
│   ├── release.dart                   # Automated version bumper & builder
│   ├── release.ps1                    # PowerShell helper
│   └── release.sh                     # Bash helper
├── CHANGELOG.md                       # Version history
└── README.md                          # This file
```

---

## 🔒 Android Permissions Rationale

| Permission | Purpose |
|------------|---------|
| `POST_NOTIFICATIONS` | Send task reminders & study lock notifications on Android 13+ (API 33+). |
| `SCHEDULE_EXACT_ALARM` | Fire routine & task reminders at the exact scheduled minute. |
| `USE_EXACT_ALARM` | Exact alarms on Android 14+ for alarm/reminder apps. |
| `RECEIVE_BOOT_COMPLETED` | Reschedule pending alarms and restore study sessions after device reboot. |
| `USE_FULL_SCREEN_INTENT` | Display full-screen heads-up reminder for critical tasks. |
| `PACKAGE_USAGE_STATS` | Detect running foreground apps to trigger the Study Lock distraction barrier. |
| `SYSTEM_ALERT_WINDOW` | Display full-screen distraction barrier overlay on top of blocked apps. |
| `FOREGROUND_SERVICE` | Maintain persistent study lock countdown and background monitor. |
| `FOREGROUND_SERVICE_SPECIAL_USE` | Compliant foreground service declaration for Android 14+ lock monitoring. |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Prevent OS battery managers from killing the blocker during active study sessions. |
| `BIND_ACCESSIBILITY_SERVICE` | Ultra-low-latency (<150ms) window state event interceptor fallback. |
| `VIBRATE` & `WAKE_LOCK` | Ensure device vibrates and wakes screen at alarm time and session completion. |
| `WRITE_EXTERNAL_STORAGE` | Export CSV expense report to storage (Android 9 and below). |
| `READ_EXTERNAL_STORAGE` | Read storage files for compatibility (Android 12 and below). |
| `INTERNET` | Open optional external UPI app intent or developer links. |

---

## 🚀 Building & Running

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.5.0 or newer)
- [Android SDK](https://developer.android.com/) (minSdk 26, compileSdk 34+)
- Java JDK 11 or 17

### 1. Install Dependencies
```bash
cd app
flutter pub get
```

### 2. Run Tests
```bash
cd app
flutter test
```

### 3. Run on Connected Device / Emulator
```bash
cd app
flutter run
```

### 4. Build Release APK
To generate a standalone APK:
```bash
cd app
flutter build apk --release
```
The output APK file will be located at:
`app/build/app/outputs/flutter-apk/app-release.apk`

### 5. Build Android App Bundle (for Google Play Store)
```bash
cd app
flutter build appbundle --release
```
The output AAB file will be located at:
`app/build/app/outputs/bundle/release/app-release.aab`

---

## 💡 Tips for Best Reminder Reliability

1. **Battery Optimization**: On devices running aggressive battery managers (Xiaomi/MIUI, OnePlus/OxygenOS, Samsung/OneUI), set Flowra battery usage to **"Unrestricted"**.
2. **Do Not Disturb**: Allow Flowra under **Settings → Sound & vibration → Do Not Disturb → Apps** so alarms can sound during focus hours.
3. **Exact Alarms**: Grant the "Alarms & Reminders" permission when prompted on Android 12+.

---

## 🚀 How to Release a New Version

Flowra includes a single automated release command that bumps the version, builds the release APK, calculates the SHA-256 checksum, updates the changelog, syncs the website, and tags git automatically.

### 4 Simple Steps to Release:

1. **Run the release script**:
   ```bash
   # On Windows (PowerShell):
   .\tools\release.ps1 -bump patch -notes "Added dark mode; Fixed notification alarm"

   # Or using Dart directly (any OS):
   dart run tools/release.dart --bump patch --notes "Added dark mode; Fixed notification alarm"
   ```
   *Options for `-bump`: `patch` (e.g. 1.0.0 -> 1.0.1), `minor` (1.0.0 -> 1.1.0), or `major` (1.0.0 -> 2.0.0).*

2. **Push the commit and tag to GitHub**:
   ```bash
   git push origin main --tags
   ```

3. **GitHub Actions builds & publishes automatically**:
   The CI pipeline detects the `v*` tag, verifies tests, builds signed binaries, and attaches `Flowra-v<version>.apk` to a new GitHub Release.

4. **Website updates automatically**:
   The website reads directly from `releases.json`. Once deployed to GitHub Pages, visitors instantly see the new version and download button.

---

## 🌐 Deploying the Flowra Website

The `website/` directory contains a fast, static, mobile-first website that loads version and download information directly from `releases.json`.

- **GitHub Pages (Free & Automatic)**: A GitHub Actions workflow (`.github/workflows/deploy-pages.yml`) is included. Enable GitHub Pages in your repository under **Settings → Pages → Source: GitHub Actions**. Every push to `main` deploys the site live.
  > *Note: For download links to work for visitors, make sure your GitHub repository is public.*
- **Netlify**: Drag and drop the `website/` folder onto [Netlify Drop](https://app.netlify.com/drop), or connect your GitHub repo with publish directory set to `website`.
- **Firebase Hosting**: Run `firebase init hosting` (choose `website` as public directory) and deploy with `firebase deploy --only hosting`.

---

## 🧪 Code Quality & Automated Verification

Flowra adheres to strict static analysis and testing standards to maintain zero dead code and high runtime stability:

```bash
# Verify static analysis across all files (zero warnings allowed)
cd app
flutter analyze

# Run the complete test suite (52/52 tests passing)
flutter test
```

- **Static Analysis**: Configured with strict linting (`flutter_lints`), passing with 0 warnings and 0 errors.
- **Test Coverage**: 52 comprehensive tests covering data models, providers, services, screens, widgets, and celebration animations.
- **Offline Reliability**: Validated across device reboots and low-power states without network dependencies.

---

## 📋 Comprehensive Testing & Verification Checklist

Use this checklist to perform end-to-end quality assurance on any Android device or emulator:

### 1. Routine & Timetable Planner
- [ ] **Task Creation**: Add tasks with title, category/subject, start/end time, and priority (*Normal*, *Important*, *Critical*).
- [ ] **Collision Detection**: Attempt to save a task that overlaps an existing task's time slot; verify the conflict warning dialog appears.
- [ ] **Recurrence Engines**: Verify recurring tasks (*Daily*, *Weekdays*, *Weekly*, *Custom days*) appear accurately across future dates on the timeline.
- [ ] **Live Status Transitions**: Verify task card status dynamically changes from *Upcoming* to *Running* (with live countdown badge) and *Completed* / *Missed* / *Skipped*.

### 2. Strong & Exact Reminders
- [ ] **Exact Minute Precision**: Schedule an alarm reminder for 2 minutes ahead; lock device and verify alarm sounds and displays heads-up notification at the exact minute.
- [ ] **Notification Actions**:
  - Tap `▶ Start Now`: transitions task to *Running*.
  - Tap `⏰ Snooze 10m`: reschedules notification for 10 minutes later.
  - Tap `✓ Done`: marks task completed directly from notification shade without launching app.
- [ ] **Reboot Survival**: Schedule future tasks, reboot device (`adb reboot`), and verify alarms are cleanly rescheduled by `StudyLockBootReceiver` without user intervention.

### 3. Study Lock — Distraction Blocker
- [ ] **Start-Time Prompt**: Schedule a task with *"Enable Study Lock when task starts"* enabled. At the start time, verify high-priority prompt appears with `[Start Study Lock]` and `[Not Now]`.
- [ ] **Notification Start**: Tap `[Start Study Lock]` from notification shade; verify foreground service starts with persistent notification displaying remaining time.
- [ ] **Manual Start**: Navigate to Study Lock tab in Flowra, select duration, and tap *"Start Study Lock"*.
- [ ] **Barrier Enforcement (<150ms)**: With Study Lock running, attempt to open any blocked app (e.g. YouTube, Instagram, Reddit); verify `StudyLockOverlayActivity` appears almost instantaneously and returns to Home screen.
- [ ] **Barrier Actions**:
  - Tap *"Return to Flowra"*: brings Flowra to foreground.
  - Tap *"Go to Home Screen"*: minimizes barrier and returns to launcher.
  - Tap *"End Study Session Early"*: prompts confirmation dialog; ending early updates session status to `ended_early` and logs blocked attempts.
- [ ] **Session Completion & Celebration**: Allow the session timer to reach 00:00; verify vibrant confetti particle animation, heavy haptic vibration, and completion dialog showing focused minutes and total blocked distractions.
- [ ] **App Customization**: Open *"Blocked Apps"* tab; search installed device apps, toggle apps on/off, add custom installed package, and verify changes persist after app restart.
- [ ] **Permission Health Checks**: Verify diagnostic cards show green checkmarks for Usage Access, Overlay, Accessibility, and Battery Optimization, and provide deep-links if disabled.

### 4. Focus & Pomodoro Mode
- [ ] **Preset Timers**: Run standard 25m Pomodoro, 45m Deep Work, and 60m Intensive sessions.
- [ ] **Task Binding**: Start Focus Mode from a timetable task card; verify completing timer marks task completed in timetable.
- [ ] **Early Finish**: Tap finish early; verify tactile haptic feedback and celebration dialog.

### 5. Daily Expense & Budget Tracker
- [ ] **Fast Logging**: Record expenses with category chips (Food, Travel, Recharge, etc.), payment method (Cash, UPI, Card), and notes.
- [ ] **Dynamic Budget Alerts**: Set monthly budget; log expenses past 80% to verify orange alert banner, and past 100% to verify red exceeded warning.
- [ ] **Timeline Grouping**: Switch between Day, Week, and Month views to verify accurate summation totals.
- [ ] **Search & Filter**: Search expense notes by keyword and filter by category chips.

### 6. Reports & Analytics
- [ ] **Routine Analytics**: Verify completion rate %, streak counter, and weekly completion bar chart reflect logged timetable tasks.
- [ ] **Expense Analytics**: Verify interactive category pie chart and daily average spending match actual expenses.

### 7. 100% Offline & System Integrity
- [ ] **Airplane Mode**: Enable Airplane Mode (Wi-Fi and Cellular off); verify all planner, timer, study blocker, and expense features function 100% without errors.
- [ ] **CSV Data Export**: Go to Settings → Export Data; tap Export Expenses CSV and verify CSV file is saved to local storage with proper headers.
- [ ] **Dark / Light Theme**: Toggle themes in Settings; verify all screens, cards, dialogs, and overlays render with high-contrast Material 3 tokens.

---

## 👨‍💻 Developer & Credits

Crafted with ❤️ by **Jay** ([@Itzjay169](https://github.com/Itzjay169)) for **Vexora Technology** to help students.
- **GitHub**: [github.com/Itzjay169](https://github.com/Itzjay169)
- **Instagram**: [@jay_dev._._](https://www.instagram.com/jay_dev._._)
- **Repository**: [github.com/Itzjay169/Flowra](https://github.com/Itzjay169/Flowra)
- **Live Website**: [https://itzjay169.github.io/Flowra/](https://itzjay169.github.io/Flowra/)

---

## 🏢 About Vexora Technology

Vexora Technology is a software development company dedicated to creating innovative digital products and smart technology solutions. We focus on web development, mobile applications, artificial intelligence, and custom software development.

Our goal is to transform ideas into powerful, reliable, and user-friendly solutions that simplify everyday challenges and create meaningful digital experiences.

Driven by innovation and creativity, we aim to build technology that makes a difference.

**Vexora Technology — Innovating Today. Building Tomorrow.**

---

## 📄 License & Copyright Claim
© 2026 Vexora Technology. All rights reserved.  
This project is open-source under the [MIT License](LICENSE).
