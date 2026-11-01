/// Models for Study Lock — Distraction Blocker feature.
library;

/// Represents an application that can be blocked during Study Lock sessions.
class BlockedApp {
  final int? id;
  final String packageName;
  final String appName;
  final bool isBlocked;
  final String? category;
  final String createdAt;

  const BlockedApp({
    this.id,
    required this.packageName,
    required this.appName,
    this.isBlocked = true,
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'package_name': packageName,
      'app_name': appName,
      'is_blocked': isBlocked ? 1 : 0,
      'category': category,
      'created_at': createdAt,
    };
  }

  factory BlockedApp.fromMap(Map<String, dynamic> map) {
    return BlockedApp(
      id: map['id'] as int?,
      packageName: map['package_name'] as String,
      appName: map['app_name'] as String,
      isBlocked: (map['is_blocked'] as int? ?? 1) == 1,
      category: map['category'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  BlockedApp copyWith({
    int? id,
    String? packageName,
    String? appName,
    bool? isBlocked,
    String? category,
    String? createdAt,
  }) {
    return BlockedApp(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isBlocked: isBlocked ?? this.isBlocked,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'BlockedApp(id: $id, name: $appName, package: $packageName, isBlocked: $isBlocked)';
}

/// Represents an execution record of a Study Lock distraction blocking session.
class StudyLockSession {
  final int? id;
  final int? taskId;
  final String taskTitle;
  final String startTime;
  final String? endTime;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final String status; // 'active', 'completed', 'ended_early', 'skipped', 'missed'
  final int blockedAttemptsCount;
  final String createdAt;

  const StudyLockSession({
    this.id,
    this.taskId,
    required this.taskTitle,
    required this.startTime,
    this.endTime,
    required this.plannedDurationMinutes,
    this.actualDurationMinutes = 0,
    required this.status,
    this.blockedAttemptsCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'task_title': taskTitle,
      'start_time': startTime,
      'end_time': endTime,
      'planned_duration_minutes': plannedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'status': status,
      'blocked_attempts_count': blockedAttemptsCount,
      'created_at': createdAt,
    };
  }

  factory StudyLockSession.fromMap(Map<String, dynamic> map) {
    return StudyLockSession(
      id: map['id'] as int?,
      taskId: map['task_id'] as int?,
      taskTitle: map['task_title'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String?,
      plannedDurationMinutes: map['planned_duration_minutes'] as int? ?? 0,
      actualDurationMinutes: map['actual_duration_minutes'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
      blockedAttemptsCount: map['blocked_attempts_count'] as int? ?? 0,
      createdAt: map['created_at'] as String,
    );
  }

  StudyLockSession copyWith({
    int? id,
    int? taskId,
    String? taskTitle,
    String? startTime,
    String? endTime,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    String? status,
    int? blockedAttemptsCount,
    String? createdAt,
  }) {
    return StudyLockSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      status: status ?? this.status,
      blockedAttemptsCount:
          blockedAttemptsCount ?? this.blockedAttemptsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isMissed => status == 'missed';
  bool get isEndedEarly => status == 'ended_early';
  bool get isActive => status == 'active';
}

/// Represents an attempted access to a blocked app during a session.
class StudyLockAttempt {
  final int? id;
  final int? sessionId;
  final String packageName;
  final String? appName;
  final String timestamp;

  const StudyLockAttempt({
    this.id,
    this.sessionId,
    required this.packageName,
    this.appName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'package_name': packageName,
      'app_name': appName,
      'timestamp': timestamp,
    };
  }

  factory StudyLockAttempt.fromMap(Map<String, dynamic> map) {
    return StudyLockAttempt(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int?,
      packageName: map['package_name'] as String,
      appName: map['app_name'] as String?,
      timestamp: map['timestamp'] as String,
    );
  }
}
