import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service interfacing with native Android Study Lock capabilities:
/// App blocking, UsageStats, Accessibility, Overlay, and Session State.
class StudyLockNativeService {
  static final StudyLockNativeService _instance =
      StudyLockNativeService._internal();
  factory StudyLockNativeService() => _instance;
  StudyLockNativeService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.flowra.flowra/study_lock');

  ValueChanged<Map<String, dynamic>>? onSessionStateChanged;
  Function(String packageName, String appName, int timestamp)?
      onBlockedAttempt;

  bool _handlersRegistered = false;

  void initialize() {
    if (_handlersRegistered) return;
    _handlersRegistered = true;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSessionStateChanged':
          if (call.arguments is Map) {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            onSessionStateChanged?.call(args);
          }
          break;
        case 'onBlockedAttempt':
          if (call.arguments is Map) {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            final pkg = args['packageName'] as String? ?? '';
            final label = args['appName'] as String? ?? '';
            final time = args['timestamp'] as int? ??
                DateTime.now().millisecondsSinceEpoch;
            onBlockedAttempt?.call(pkg, label, time);
          }
          break;
      }
    });
  }

  /// Check permission statuses
  Future<Map<String, bool>> checkPermissions() async {
    if (!Platform.isAndroid) {
      return {
        'notification': true,
        'exactAlarm': true,
        'usageAccess': true,
        'accessibility': true,
        'overlay': true,
        'batteryOptimization': true,
      };
    }

    try {
      final res = await _channel.invokeMethod<Map>('checkPermissions');
      if (res != null) {
        return res.map((k, v) => MapEntry(k.toString(), v == true));
      }
    } catch (e) {
      debugPrint('Error checking Study Lock permissions: $e');
    }

    return {
      'notification': false,
      'exactAlarm': false,
      'usageAccess': false,
      'accessibility': false,
      'overlay': false,
      'batteryOptimization': false,
    };
  }

  /// Request Usage Access permission
  Future<void> requestUsageAccess() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestUsageAccess');
    } catch (e) {
      debugPrint('Error requesting usage access: $e');
    }
  }

  /// Request Accessibility service permission
  Future<void> requestAccessibility() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestAccessibility');
    } catch (e) {
      debugPrint('Error requesting accessibility: $e');
    }
  }

  /// Request Draw Over Other Apps overlay permission
  Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      debugPrint('Error requesting overlay permission: $e');
    }
  }

  /// Request Exact Alarm permission (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }
  }

  /// Request Ignore Battery Optimizations
  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Error requesting battery optimizations exemption: $e');
    }
  }

  /// Query installed launchable applications
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    if (!Platform.isAndroid) return [];
    try {
      final res = await _channel.invokeMethod<List>('getInstalledApps');
      if (res != null) {
        return res
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('Error querying installed apps: $e');
    }
    return [];
  }

  /// Start a Study Lock session
  Future<Map<String, dynamic>> startStudyLock({
    int? taskId,
    required String taskTitle,
    required int durationMinutes,
    required List<String> blockedPackages,
  }) async {
    if (!Platform.isAndroid) return {'isActive': false};
    try {
      final res = await _channel.invokeMethod<Map>('startStudyLock', {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'durationMinutes': durationMinutes,
        'blockedPackages': blockedPackages,
      });
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (e) {
      debugPrint('Error starting study lock: $e');
    }
    return {'isActive': false};
  }

  /// Stop the active Study Lock session
  Future<bool> stopStudyLock({bool endedEarly = true}) async {
    if (!Platform.isAndroid) return true;
    try {
      final res = await _channel.invokeMethod<bool>('stopStudyLock', {
        'endedEarly': endedEarly,
      });
      return res == true;
    } catch (e) {
      debugPrint('Error stopping study lock: $e');
      return false;
    }
  }

  /// Get status of active session
  Future<Map<String, dynamic>> getStudyLockStatus() async {
    if (!Platform.isAndroid) return {'isActive': false};
    try {
      final res = await _channel.invokeMethod<Map>('getStudyLockStatus');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (e) {
      debugPrint('Error getting study lock status: $e');
    }
    return {'isActive': false};
  }

  /// Update blocked packages list on the native side
  Future<void> updateBlockedPackages(List<String> packages) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateBlockedPackages', {
        'packages': packages,
      });
    } catch (e) {
      debugPrint('Error updating blocked packages: $e');
    }
  }
}
