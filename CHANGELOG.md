# Changelog

All notable changes to the **Flowra** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - 2026-11-02

### Added
- **Study Lock Self-Discipline Fallback Mode**: When Android 13+ restricted settings prevent Usage Access or Accessibility permissions on sideloaded installs, Flowra now offers a Self-Discipline / Focus Timer mode instead of being non-functional.
- **Restricted Settings Guidance**: Step-by-step instructions for users to enable restricted permissions via App Info → Allow Restricted Settings, with an "Open Flowra App Info" button.
- **Auto-Recheck Permissions on Resume**: Study Lock screen now uses `WidgetsBindingObserver` to automatically recheck permissions when users return from system settings.
- **Enforcement Mode Banner**: Clear visual indicator showing whether the app is in "Full Distraction Blocker" or "Self-Discipline" mode.
- **Website Mobile Responsive Design**: Full responsive support for 320px, 375px, 768px, 1024px, and 1440px breakpoints with no horizontal overflow.
- **Reduced Motion Support**: `prefers-reduced-motion` CSS media query for accessibility.
- **Website `.env.example`**: Template for contact form configuration.

### Changed
- **Branding**: All references updated to "Vexora Technology" with "Lead Developer: Jay" preserved only in About Flowra descriptions. Copyright standardized to "© 2026 Vexora Technology. All rights reserved."
- **Version Display**: Clean version name only (e.g., "Version 1.2.0") — build numbers no longer shown to users.
- **Contact Form Email**: Suggestion submissions now routed to `magicianbusiness30@gmail.com`.
- **Folder Structure**: Flutter app moved to `app/` subdirectory; website remains in `website/`. CI/CD workflows updated accordingly.
- **CI/CD**: Updated `actions/setup-java` to v5, added `working-directory: app` to CI jobs, removed failing `java-kotlin` and `swift` CodeQL matrix entries, deploy-pages uses `peaceiris/actions-gh-pages@v4`.
- **Onboarding**: Changed placeholder name from "Jay" to "Alex" in onboarding hint text.

### Fixed
- **Study Lock Permission Cards**: All permission descriptions now explain Android 13+ restricted settings behavior honestly.
- **Website Horizontal Overflow**: Fixed CSS grid `minmax` causing overflow on small screens (320px).
- **Website Mobile Menu**: Hamburger menu now works correctly at all breakpoints.
- **CI Pipeline**: Fixed `flutter analyze` failure caused by unrecognized `unnecessary_import` lint rule.
- **CodeQL Workflow**: Removed `java-kotlin` and `swift` autobuild entries that cannot build Flutter projects.

---

### Added
- **Exclusive Home Page Study Lock Dashboard**: Moved Study Lock exclusively to Home page with a live interactive status shield card, remaining countdown, and quick action launcher.
- **Timetable Scrolling Button Labels**: Added `ScrollingButtonLabel` with auto-marquee animation and smooth horizontal scrolling so button and subject menu names are fully readable without truncation.
- **Vexora Technology Company Profile & Branding**: Added Vexora Technology official logo, mission statement ("Made by Vexora Technology to help students"), company overview, and developer Jay attribution.
- **Updated Copyright Claim**: Updated copyright claims across app, website, and license to Vexora Technology & Jay.

### Changed
- Bottom navigation menu streamlined to 5 core items (Home, Timetable, Expenses, Reports, Settings), removing Study Lock from menu per user request.
- GitHub repository remotes, badges, and documentation updated to `https://github.com/Itzjay169/Flowra`.
- Live website published at `https://itzjay169.github.io/Flowra/`.

---

## [1.0.2] - 2026-10-14

### Added
- **Study Lock — Distraction Blocker**:
  - Optional "Enable Study Lock when task starts" toggle on study/focus tasks.
  - High-priority full-screen start notification with "Accept & Start Study Lock" and "Reject / Skip Lock" actions.
  - Real-time foreground app blocker utilizing `UsageStatsManager` and `AccessibilityService` fallback.
  - Immersive full-screen "Study Mode Active" overlay displaying live remaining countdown, motivational quotes, blocked attempts counter, and quick exit options.
  - Customizable blocked apps list with search and installed apps picker.
  - Dedicated "Study Lock" navigation section with master toggle, permission status check cards, and detailed session history.
- **Modernized UI & Animations**:
  - `AnimatedStatusBadge` with fluid color and icon transitions.
  - Particle confetti celebration dialog on focus session completion.
  - Dynamic Material 3 dark/light elevation and styling.

### Changed
- SQLite database upgraded to version 3 with schema migration adding `enable_study_lock` to tasks and creating `blocked_apps`, `study_lock_sessions`, and `study_lock_attempts` tables.
- Bottom navigation footer (`AppFooter`) expanded to 6 fixed navigation items.
- Upgraded project release version to `1.1.0+2`.

### Fixed
- Exact alarm permission handling across Android 12–16 with graceful inexact fallback.
- Session timer resilience across device reboot, app backgrounding, and timezone updates.

---

## [1.0.0] - 2026-09-28

### Added
- **Study Timetable & Routine Planner**: Daily and weekly interactive timeline, subject filter chips, date navigation, and time collision detection.
- **Strong & Exact Reminders**: High-priority offline notifications with Android exact alarm scheduling (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`) and reboot recovery via `RECEIVE_BOOT_COMPLETED`.
- **Study Focus & Pomodoro Mode**: Distraction-free countdown timer with preset study durations (25m, 45m, 60m) and optional break intervals.
- **Daily Expense & Monthly Budget Tracker**: Quick expense logging with categories, payment method tagging, and automatic 80% / 100% budget threshold alerts.
- **Reports & Analytics**: Study completion rate analytics, 30-day spending trends, and category breakdown charts.
- **Data Privacy & Export**: 100% offline SQLite storage with CSV export for expenses and safe data wipe controls.
- **Developer Support**: Optional donation screen with preset amounts and direct UPI deep-linking (`upi://pay`).
- **Automated CI/CD**: GitHub Actions pipeline for lint validation, test suite execution, and automated release artifact generation.
- **Comprehensive Test Suite**: Unit and widget tests covering data models, provider logic, services, and core UI screens.

### Changed
- Complete deep rebrand to **Flowra** (package `com.flowra.flowra`, custom branding, logos, app icons, and links).
- Modularized bottom navigation app footer and updated copyright notices.
- Release signing configuration via `key.properties`.

### Fixed
- Notification alarm scheduling and permission handling for Android 13/14+.
- Viewport overflow in `StudyFocusScreen` using responsive scroll view and adaptive spacing.
- AndroidX and Jetifier build properties in `gradle.properties`.
- Lint cleanups across all providers and screens.
