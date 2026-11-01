/// Notification service for scheduling study reminders.
/// Handles Android notification channels, permissions, exact alarms,
/// sound, vibration, and boot-completed rescheduling.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flowra/models/task.dart';
import 'package:flowra/utils/constants.dart';

/// Background notification response handler (must be top-level)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  // Handled by the app when it opens
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _hasNotificationPermission = false;
  bool _hasExactAlarmPermission = false;

  bool get hasNotificationPermission => _hasNotificationPermission;
  bool get hasExactAlarmPermission => _hasExactAlarmPermission;

  // Distinct vibration patterns
  static final Int64List _reminderVibrationPattern =
      Int64List.fromList([0, 500, 200, 500]);
  static final Int64List _alarmVibrationPattern =
      Int64List.fromList([0, 1000, 500, 1000, 500, 1000]);

  // Callback for when a notification action is tapped
  Function(String? payload)? onNotificationTap;
  Function(String actionId, String? payload)? onNotificationAction;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint('Timezone detection error: $e');
      try {
        final currentOffset = DateTime.now().timeZoneOffset.inMilliseconds;
        final matched = tz.timeZoneDatabase.locations.values.firstWhere(
          (loc) => loc.currentTimeZone.offset == currentOffset,
          orElse: () => tz.getLocation('Asia/Kolkata'),
        );
        tz.setLocalLocation(matched);
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        } catch (_) {}
      }
    }

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;
    await checkPermissions();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 1. Regular task reminders channel with sound and vibration
      final reminderChannel = AndroidNotificationChannel(
        AppConstants.studyAlertChannelId,
        AppConstants.studyAlertChannelName,
        description: AppConstants.studyAlertChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _reminderVibrationPattern,
        enableLights: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(reminderChannel);

      // 2. High priority alarm reminders channel with alarm audio stream & vibration
      final alarmChannel = AndroidNotificationChannel(
        AppConstants.alarmAlertChannelId,
        AppConstants.alarmAlertChannelName,
        description: AppConstants.alarmAlertChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _alarmVibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableLights: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(alarmChannel);

      // 3. High priority Study Lock start prompt channel
      final studyLockPromptChannel = AndroidNotificationChannel(
        AppConstants.studyLockPromptChannelId,
        AppConstants.studyLockPromptChannelName,
        description: AppConstants.studyLockPromptChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _alarmVibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableLights: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(studyLockPromptChannel);

      // 4. Persistent Study Lock active session channel
      final studyLockActiveChannel = AndroidNotificationChannel(
        AppConstants.studyLockActiveChannelId,
        AppConstants.studyLockActiveChannelName,
        description: AppConstants.studyLockActiveChannelDesc,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );
      await androidPlugin.createNotificationChannel(studyLockActiveChannel);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      onNotificationAction?.call(response.actionId!, response.payload);
    } else {
      onNotificationTap?.call(response.payload);
    }
  }

  // ─── Permission Management ────────────────────────────────────────────

  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        _hasNotificationPermission =
            await androidPlugin.areNotificationsEnabled() ?? false;

        // Check exact alarm permission (Android 12+)
        try {
          _hasExactAlarmPermission =
              await androidPlugin.canScheduleExactNotifications() ?? false;
        } catch (_) {
          _hasExactAlarmPermission = true; // Assume true on older Android
        }
      }
    } else {
      _hasNotificationPermission = true;
      _hasExactAlarmPermission = true;
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
        _hasNotificationPermission = (granted == true) || enabled;
        return _hasNotificationPermission;
      }
    }
    return false;
  }

  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        try {
          final granted = await androidPlugin.requestExactAlarmsPermission();
          _hasExactAlarmPermission = granted ?? false;
          return _hasExactAlarmPermission;
        } catch (e) {
          debugPrint('Exact alarm request error: $e');
        }
      }
    }
    return false;
  }

  // ─── Helper for accurate TZ conversion ────────────────────────────────

  tz.TZDateTime? _getScheduledTZDateTime(Task task) {
    try {
      final dateParts = task.date.split('-');
      final timeParts = task.startTime.split(':');
      if (dateParts.length < 3 || timeParts.length < 2) return null;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minute,
      );
    } catch (e) {
      debugPrint('Error parsing scheduled date for task ${task.id}: $e');
      return null;
    }
  }

  // ─── Schedule Notifications ───────────────────────────────────────────

  /// Schedule a notification for a task
  Future<void> scheduleTaskNotification(Task task) async {
    if (!_initialized) {
      await initialize();
    }
    if (task.id == null) return;

    // Refresh OS permissions
    await checkPermissions();

    final tzScheduled = _getScheduledTZDateTime(task);
    if (tzScheduled == null) return;

    final nowTz = tz.TZDateTime.now(tz.local);
    // If the scheduled time is already in the past, do not schedule
    if (tzScheduled.isBefore(nowTz)) {
      debugPrint(
          'Task ${task.id} scheduled time ($tzScheduled) is in the past ($nowTz). Skipping.');
      return;
    }

    final androidDetails = _buildAndroidDetails(task);
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final notifId = task.id!;
    final String notifTitle =
        task.enableStudyLock ? '🔒 Study Lock Ready' : '📚 Study Time';
    final String notifBody = task.enableStudyLock
        ? '${task.title}\nStarts now (${task.startTime} – ${task.endTime}). Tap Accept to start distraction blocking for ${task.durationMinutes}m.'
        : '${task.title}\n${task.startTime} – ${task.endTime}';
    final String notifPayload =
        task.enableStudyLock ? 'studylock:${task.id}' : 'task:${task.id}';

    // Try exact alarm mode first for punctual reminders
    try {
      await _plugin.zonedSchedule(
        notifId,
        notifTitle,
        notifBody,
        tzScheduled,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: notifPayload,
      );
      debugPrint('Scheduled exact notification for task $notifId at $tzScheduled');
    } catch (exactError) {
      debugPrint('Exact alarm failed for task $notifId ($exactError). Falling back to inexact...');
      try {
        await _plugin.zonedSchedule(
          notifId,
          notifTitle,
          notifBody,
          tzScheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: notifPayload,
        );
        debugPrint('Scheduled inexact notification for task $notifId at $tzScheduled');
      } catch (fallbackError) {
        debugPrint('Failed to schedule notification completely for task $notifId: $fallbackError');
      }
    }
  }

  /// Schedule a pre-alert notification (X minutes before task)
  Future<void> schedulePreAlert(Task task, int minutesBefore) async {
    if (!_initialized) {
      await initialize();
    }
    if (task.id == null) return;

    final tzScheduled = _getScheduledTZDateTime(task);
    if (tzScheduled == null) return;

    final tzPreAlert = tzScheduled.subtract(Duration(minutes: minutesBefore));
    final nowTz = tz.TZDateTime.now(tz.local);
    if (tzPreAlert.isBefore(nowTz)) return;

    final androidDetails = AndroidNotificationDetails(
      AppConstants.studyAlertChannelId,
      AppConstants.studyAlertChannelName,
      channelDescription: AppConstants.studyAlertChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _reminderVibrationPattern,
      category: AndroidNotificationCategory.reminder,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    final preAlertId = task.id! + 100000;

    try {
      await _plugin.zonedSchedule(
        preAlertId,
        '⏰ Coming Up',
        '${task.title} starts in $minutesBefore minutes',
        tzPreAlert,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'prealert:${task.id}',
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          preAlertId,
          '⏰ Coming Up',
          '${task.title} starts in $minutesBefore minutes',
          tzPreAlert,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'prealert:${task.id}',
        );
      } catch (e) {
        debugPrint('Failed to schedule pre-alert: $e');
      }
    }
  }

  /// Build Android notification details based on task priority/type
  AndroidNotificationDetails _buildAndroidDetails(Task task) {
    if (task.enableStudyLock) {
      return AndroidNotificationDetails(
        AppConstants.studyLockPromptChannelId,
        AppConstants.studyLockPromptChannelName,
        channelDescription: AppConstants.studyLockPromptChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _alarmVibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: false,
        actions: const [
          AndroidNotificationAction(
            'accept_study_lock',
            '🔒 Accept & Start Study Lock',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'reject_study_lock',
            '✕ Reject / Skip Lock',
            showsUserInterface: false,
          ),
        ],
      );
    }

    final isAlarmStyle = task.notificationType == 'Alarm-style reminder';
    final isSilent = task.notificationType == 'Silent popup';

    if (isAlarmStyle) {
      return AndroidNotificationDetails(
        AppConstants.alarmAlertChannelId,
        AppConstants.alarmAlertChannelName,
        channelDescription: AppConstants.alarmAlertChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _alarmVibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: false,
        actions: const [
          AndroidNotificationAction(
            'start_now',
            '▶ Start Now',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_10',
            '⏰ Snooze 10m',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'done',
            '✓ Done',
            showsUserInterface: true,
          ),
        ],
      );
    }

    if (isSilent) {
      return AndroidNotificationDetails(
        AppConstants.studyAlertChannelId,
        AppConstants.studyAlertChannelName,
        channelDescription: AppConstants.studyAlertChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        visibility: NotificationVisibility.private,
      );
    }

    // Default: 'Sound + vibration'
    return AndroidNotificationDetails(
      AppConstants.studyAlertChannelId,
      AppConstants.studyAlertChannelName,
      channelDescription: AppConstants.studyAlertChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _reminderVibrationPattern,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: false,
      actions: const [
        AndroidNotificationAction(
          'start_now',
          '▶ Start Now',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_10',
          '⏰ Snooze 10m',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'done',
          '✓ Done',
          showsUserInterface: true,
        ),
      ],
    );
  }

  /// Snooze a task notification by rescheduling it
  Future<void> snoozeNotification(Task task, int minutes) async {
    if (!_initialized) {
      await initialize();
    }
    if (task.id == null) return;

    await cancelTaskNotification(task.id!);

    final nowTz = tz.TZDateTime.now(tz.local);
    final tzSnooze = nowTz.add(Duration(minutes: minutes));

    final androidDetails = AndroidNotificationDetails(
      AppConstants.studyAlertChannelId,
      AppConstants.studyAlertChannelName,
      channelDescription: AppConstants.studyAlertChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _reminderVibrationPattern,
      category: AndroidNotificationCategory.reminder,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin.zonedSchedule(
        task.id!,
        '📚 Snoozed Reminder',
        '${task.title}\nTime to study!',
        tzSnooze,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task:${task.id}',
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          task.id!,
          '📚 Snoozed Reminder',
          '${task.title}\nTime to study!',
          tzSnooze,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'task:${task.id}',
        );
      } catch (e) {
        debugPrint('Failed to snooze notification: $e');
      }
    }
  }

  /// Send a budget warning notification
  Future<void> showBudgetWarning(
      String category, double spent, double limit, String symbol) async {
    if (!_initialized) {
      await initialize();
    }
    await checkPermissions();
    if (!_hasNotificationPermission) return;

    final percentage = ((spent / limit) * 100).round();
    final isOver = spent >= limit;

    await _plugin.show(
      category.hashCode + 200000,
      isOver ? '🚨 Budget Exceeded!' : '⚠️ Budget Warning',
      isOver
          ? '$category: $symbol${spent.toStringAsFixed(0)} / $symbol${limit.toStringAsFixed(0)} ($percentage%)'
          : '$category budget at $percentage% — $symbol${(limit - spent).toStringAsFixed(0)} remaining',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.studyAlertChannelId,
          AppConstants.studyAlertChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ─── Cancel Notifications ─────────────────────────────────────────────

  Future<void> cancelTaskNotification(int taskId) async {
    await _plugin.cancel(taskId);
    await _plugin.cancel(taskId + 100000); // Pre-alert
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ─── Reschedule All Notifications ─────────────────────────────────────

  /// Reschedule all future task notifications.
  /// Called after boot, timezone change, app update, or permission grant.
  Future<void> rescheduleAllNotifications(List<Task> futureTasks,
      {bool preAlertEnabled = false, int preAlertMinutes = 5}) async {
    if (!_initialized) {
      await initialize();
    }

    await cancelAllNotifications();
    await checkPermissions();

    for (final task in futureTasks) {
      if (task.isUpcoming || task.isRunning) {
        await scheduleTaskNotification(task);
        if (preAlertEnabled) {
          await schedulePreAlert(task, preAlertMinutes);
        }
      }
    }
  }
}
