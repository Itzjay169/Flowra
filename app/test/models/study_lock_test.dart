import 'package:flutter_test/flutter_test.dart';
import 'package:flowra/models/study_lock.dart';

void main() {
  group('StudyLock Model Tests', () {
    const nowIso = '2026-10-14T10:00:00';

    test('BlockedApp should serialize to and from Map correctly', () {
      const app = BlockedApp(
        id: 1,
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        category: 'Social',
        isBlocked: true,
        createdAt: nowIso,
      );

      final map = app.toMap();
      expect(map['id'], 1);
      expect(map['package_name'], 'com.instagram.android');
      expect(map['app_name'], 'Instagram');
      expect(map['category'], 'Social');
      expect(map['is_blocked'], 1);
      expect(map['created_at'], nowIso);

      final fromMap = BlockedApp.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.packageName, 'com.instagram.android');
      expect(fromMap.appName, 'Instagram');
      expect(fromMap.category, 'Social');
      expect(fromMap.isBlocked, isTrue);
      expect(fromMap.createdAt, nowIso);
    });

    test('BlockedApp copyWith should update specified fields', () {
      const app = BlockedApp(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        category: 'Social',
        isBlocked: true,
        createdAt: nowIso,
      );

      final toggled = app.copyWith(isBlocked: false);
      expect(toggled.packageName, 'com.zhiliaoapp.musically');
      expect(toggled.appName, 'TikTok');
      expect(toggled.isBlocked, isFalse);
    });

    test('StudyLockSession should serialize to and from Map correctly', () {
      const session = StudyLockSession(
        id: 42,
        taskId: 10,
        taskTitle: 'Discrete Math Revision',
        startTime: '2026-10-14T14:00:00',
        endTime: '2026-10-14T15:00:00',
        plannedDurationMinutes: 60,
        actualDurationMinutes: 55,
        blockedAttemptsCount: 3,
        status: 'completed',
        createdAt: nowIso,
      );

      final map = session.toMap();
      expect(map['id'], 42);
      expect(map['task_id'], 10);
      expect(map['task_title'], 'Discrete Math Revision');
      expect(map['planned_duration_minutes'], 60);
      expect(map['actual_duration_minutes'], 55);
      expect(map['blocked_attempts_count'], 3);
      expect(map['status'], 'completed');

      final fromMap = StudyLockSession.fromMap(map);
      expect(fromMap.id, 42);
      expect(fromMap.taskId, 10);
      expect(fromMap.taskTitle, 'Discrete Math Revision');
      expect(fromMap.plannedDurationMinutes, 60);
      expect(fromMap.actualDurationMinutes, 55);
      expect(fromMap.blockedAttemptsCount, 3);
      expect(fromMap.status, 'completed');
      expect(fromMap.isCompleted, isTrue);
      expect(fromMap.isActive, isFalse);
    });

    test('StudyLockAttempt should serialize to and from Map correctly', () {
      const attempt = StudyLockAttempt(
        id: 7,
        sessionId: 42,
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        timestamp: '2026-10-14T14:15:00',
      );

      final map = attempt.toMap();
      expect(map['id'], 7);
      expect(map['session_id'], 42);
      expect(map['package_name'], 'com.google.android.youtube');
      expect(map['app_name'], 'YouTube');
      expect(map['timestamp'], '2026-10-14T14:15:00');

      final fromMap = StudyLockAttempt.fromMap(map);
      expect(fromMap.id, 7);
      expect(fromMap.sessionId, 42);
      expect(fromMap.packageName, 'com.google.android.youtube');
      expect(fromMap.appName, 'YouTube');
      expect(fromMap.timestamp, '2026-10-14T14:15:00');
    });
  });
}
