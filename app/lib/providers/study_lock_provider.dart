import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowra/models/study_lock.dart';
import 'package:flowra/services/database_service.dart';
import 'package:flowra/services/study_lock_native_service.dart';
import 'package:flowra/utils/constants.dart';

/// Modes of distraction enforcement based on granted Android permissions
enum StudyLockEnforcementMode {
  /// Full distraction blocker: usage stats / accessibility / overlay actively
  /// redirects away from blocked applications.
  fullBlocker,

  /// Self-discipline / focus timer mode: tracks time, records history, and fires
  /// notifications, but does not forcibly intercept foreground apps because
  /// restricted permissions are not granted.
  selfDiscipline,
}

/// Provider for managing Study Lock state, permissions, blocked apps list,
/// active session countdown, and historical records.
class StudyLockProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final StudyLockNativeService _native = StudyLockNativeService();

  bool _masterEnabled = true;
  bool _isLoading = false;
  bool _isRestrictedSettingsLikely = false;
  List<BlockedApp> _blockedApps = [];
  List<Map<String, dynamic>> _installedApps = [];
  List<StudyLockSession> _sessionHistory = [];

  // Active session state
  bool _isLockActive = false;
  bool _isPaused = false;
  int? _currentTaskId;
  String _currentTaskTitle = 'Study Session';
  int _durationMinutes = 25;
  int _remainingSeconds = 0;
  int _elapsedSeconds = 0;
  int _blockedAttemptsCount = 0;
  int? _activeSessionDbId;

  Timer? _localTicker;

  // Permission statuses
  Map<String, bool> _permissions = {
    'notification': false,
    'exactAlarm': false,
    'usageAccess': false,
    'accessibility': false,
    'overlay': false,
    'batteryOptimization': false,
  };

  // Getters
  bool get masterEnabled => _masterEnabled;
  bool get isLoading => _isLoading;
  bool get isRestrictedSettingsLikely => _isRestrictedSettingsLikely;
  List<BlockedApp> get blockedApps => _blockedApps;
  List<BlockedApp> get activeBlockedApps =>
      _blockedApps.where((a) => a.isBlocked).toList();
  List<Map<String, dynamic>> get installedApps => _installedApps;
  List<StudyLockSession> get sessionHistory => _sessionHistory;

  bool get isLockActive => _isLockActive;
  bool get isPaused => _isPaused;
  int? get currentTaskId => _currentTaskId;
  String get currentTaskTitle => _currentTaskTitle;
  int get durationMinutes => _durationMinutes;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _elapsedSeconds;
  int get blockedAttemptsCount => _blockedAttemptsCount;
  Map<String, bool> get permissions => _permissions;

  StudyLockEnforcementMode get enforcementMode {
    final hasUsage = _permissions['usageAccess'] == true;
    final hasOverlay = _permissions['overlay'] == true;
    final hasAccessibility = _permissions['accessibility'] == true;

    if ((hasUsage && hasOverlay) || hasAccessibility) {
      return StudyLockEnforcementMode.fullBlocker;
    }
    return StudyLockEnforcementMode.selfDiscipline;
  }

  bool get isFullBlockerReady =>
      enforcementMode == StudyLockEnforcementMode.fullBlocker;

  bool get hasAllCorePermissions => isFullBlockerReady;

  StudyLockProvider() {
    _init();
  }

  Future<void> _init() async {
    _native.initialize();
    _native.onSessionStateChanged = _handleNativeStateChange;
    _native.onBlockedAttempt = _handleNativeAttempt;

    await loadSettings();
    await loadBlockedApps();
    await checkPermissions();
    await loadSessionHistory();
    await syncNativeStatus();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _masterEnabled = prefs.getBool(AppConstants.keyStudyLockMasterEnabled) ?? true;
    notifyListeners();
  }

  Future<void> setMasterEnabled(bool enabled) async {
    _masterEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyStudyLockMasterEnabled, enabled);
    if (!enabled && _isLockActive) {
      await stopStudyLock(endedEarly: true);
    }
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _permissions = await _native.checkPermissions();
    _isRestrictedSettingsLikely = await _native.isRestrictedSettingsLikely();
    notifyListeners();
  }

  Future<void> openAppInfoSettings() async {
    await _native.openAppInfoSettings();
  }

  Future<void> requestPermission(String type) async {
    switch (type) {
      case 'usageAccess':
        await _native.requestUsageAccess();
        break;
      case 'accessibility':
        await _native.requestAccessibility();
        break;
      case 'overlay':
        await _native.requestOverlayPermission();
        break;
      case 'exactAlarm':
        await _native.requestExactAlarmPermission();
        break;
      case 'batteryOptimization':
        await _native.requestIgnoreBatteryOptimizations();
        break;
    }
    // Re-check after returning from settings
    await Future.delayed(const Duration(milliseconds: 600));
    await checkPermissions();
  }

  Future<void> loadBlockedApps() async {
    try {
      _blockedApps = await _db.getBlockedApps();
      await _syncBlockedAppsToNative();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading blocked apps: $e');
    }
  }

  Future<void> _syncBlockedAppsToNative() async {
    final activePackages =
        _blockedApps.where((a) => a.isBlocked).map((a) => a.packageName).toList();
    await _native.updateBlockedPackages(activePackages);
  }

  Future<void> toggleAppBlocked(int id, bool isBlocked) async {
    await _db.toggleBlockedApp(id, isBlocked);
    final idx = _blockedApps.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _blockedApps[idx] = _blockedApps[idx].copyWith(isBlocked: isBlocked);
      await _syncBlockedAppsToNative();
      notifyListeners();
    }
  }

  Future<void> addBlockedApp(String packageName, String appName,
      {String? category}) async {
    final now = DateTime.now().toIso8601String();
    final app = BlockedApp(
      packageName: packageName,
      appName: appName,
      isBlocked: true,
      category: category,
      createdAt: now,
    );
    final id = await _db.insertBlockedApp(app);
    _blockedApps.add(app.copyWith(id: id));
    await _syncBlockedAppsToNative();
    notifyListeners();
  }

  Future<void> removeBlockedApp(int id) async {
    await _db.deleteBlockedApp(id);
    _blockedApps.removeWhere((a) => a.id == id);
    await _syncBlockedAppsToNative();
    notifyListeners();
  }

  Future<void> loadInstalledApps() async {
    if (_installedApps.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _installedApps = await _native.getInstalledApps();
    } catch (e) {
      debugPrint('Error fetching installed apps: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionHistory() async {
    try {
      _sessionHistory = await _db.getStudyLockSessions(limit: 50);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading session history: $e');
    }
  }

  Future<void> syncNativeStatus() async {
    final status = await _native.getStudyLockStatus();
    _handleNativeStateChange(status);
  }

  void _handleNativeStateChange(Map<String, dynamic> status) {
    final wasActive = _isLockActive;
    _isLockActive = status['isActive'] == true;
    _isPaused = status['isPaused'] == true;
    _currentTaskId = status['taskId'] as int?;
    _currentTaskTitle = status['taskTitle'] as String? ?? 'Study Session';
    _durationMinutes = status['durationMinutes'] as int? ?? 25;
    _remainingSeconds = (status['remainingSeconds'] as num? ?? 0).toInt();
    _elapsedSeconds = (status['elapsedSeconds'] as num? ?? 0).toInt();
    _blockedAttemptsCount = (status['blockedAttempts'] as int? ?? 0);

    if (_isLockActive) {
      _startLocalTicker();
    } else {
      _stopLocalTicker();
      if (wasActive) {
        // Session recently finished
        loadSessionHistory();
      }
    }
    notifyListeners();
  }

  void _handleNativeAttempt(String packageName, String appName, int timestamp) {
    _blockedAttemptsCount++;
    if (_activeSessionDbId != null) {
      _db.recordStudyLockAttempt(StudyLockAttempt(
        sessionId: _activeSessionDbId,
        packageName: packageName,
        appName: appName,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp)
            .toIso8601String(),
      ));
    }
    notifyListeners();
  }

  void _startLocalTicker() {
    _localTicker?.cancel();
    _localTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _elapsedSeconds++;
        notifyListeners();
      } else if (_isLockActive) {
        stopStudyLock(endedEarly: false);
      }
    });
  }

  void _stopLocalTicker() {
    _localTicker?.cancel();
    _localTicker = null;
  }

  /// Start a Study Lock session from the UI
  Future<bool> startStudyLock({
    int? taskId,
    required String taskTitle,
    required int durationMinutes,
  }) async {
    if (!_masterEnabled) return false;

    final activePkgs =
        _blockedApps.where((a) => a.isBlocked).map((a) => a.packageName).toList();

    // 1. Insert DB session record
    final now = DateTime.now().toIso8601String();
    final session = StudyLockSession(
      taskId: taskId,
      taskTitle: taskTitle,
      startTime: now,
      plannedDurationMinutes: durationMinutes,
      status: 'active',
      createdAt: now,
    );
    _activeSessionDbId = await _db.insertStudyLockSession(session);

    // 2. Start native service
    final res = await _native.startStudyLock(
      taskId: taskId,
      taskTitle: taskTitle,
      durationMinutes: durationMinutes,
      blockedPackages: activePkgs,
    );

    _isLockActive = res['isActive'] == true;
    _currentTaskId = taskId;
    _currentTaskTitle = taskTitle;
    _durationMinutes = durationMinutes;
    _remainingSeconds = durationMinutes * 60;
    _elapsedSeconds = 0;
    _blockedAttemptsCount = 0;

    _startLocalTicker();
    notifyListeners();
    return _isLockActive;
  }

  /// Stop the active Study Lock session
  Future<void> stopStudyLock({bool endedEarly = true}) async {
    _stopLocalTicker();
    await _native.stopStudyLock(endedEarly: endedEarly);

    if (_activeSessionDbId != null) {
      final now = DateTime.now().toIso8601String();
      final actualMinutes = (_elapsedSeconds / 60).round();
      final session = StudyLockSession(
        id: _activeSessionDbId,
        taskId: _currentTaskId,
        taskTitle: _currentTaskTitle,
        startTime: now,
        endTime: now,
        plannedDurationMinutes: _durationMinutes,
        actualDurationMinutes: actualMinutes,
        status: endedEarly ? 'ended_early' : 'completed',
        blockedAttemptsCount: _blockedAttemptsCount,
        createdAt: now,
      );
      await _db.updateStudyLockSession(session);
      _activeSessionDbId = null;
    }

    _isLockActive = false;
    _remainingSeconds = 0;
    await loadSessionHistory();
    notifyListeners();
  }

  /// Record an accepted session triggered from notification
  Future<void> recordAcceptedSession({
    int? taskId,
    required String taskTitle,
    required int durationMinutes,
  }) async {
    final now = DateTime.now().toIso8601String();
    final session = StudyLockSession(
      taskId: taskId,
      taskTitle: taskTitle,
      startTime: now,
      plannedDurationMinutes: durationMinutes,
      status: 'active',
      createdAt: now,
    );
    _activeSessionDbId = await _db.insertStudyLockSession(session);
    await syncNativeStatus();
  }

  /// Record a skipped session triggered from notification
  Future<void> recordSkippedSession({
    int? taskId,
    required String taskTitle,
    required int durationMinutes,
  }) async {
    final now = DateTime.now().toIso8601String();
    final session = StudyLockSession(
      taskId: taskId,
      taskTitle: taskTitle,
      startTime: now,
      endTime: now,
      plannedDurationMinutes: durationMinutes,
      actualDurationMinutes: 0,
      status: 'skipped',
      blockedAttemptsCount: 0,
      createdAt: now,
    );
    await _db.insertStudyLockSession(session);
    await loadSessionHistory();
  }

  /// Record a missed/expired session
  Future<void> recordMissedSession({
    int? taskId,
    required String taskTitle,
    required int durationMinutes,
  }) async {
    final now = DateTime.now().toIso8601String();
    final session = StudyLockSession(
      taskId: taskId,
      taskTitle: taskTitle,
      startTime: now,
      endTime: now,
      plannedDurationMinutes: durationMinutes,
      actualDurationMinutes: 0,
      status: 'missed',
      blockedAttemptsCount: 0,
      createdAt: now,
    );
    await _db.insertStudyLockSession(session);
    await loadSessionHistory();
  }

  @override
  void dispose() {
    _localTicker?.cancel();
    super.dispose();
  }
}
