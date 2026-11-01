/// Study Lock — Distraction Blocker screen.
/// Manages master toggle, active lock status, permission cards,
/// blocked apps list with search, installed apps picker, and session history.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flowra/providers/study_lock_provider.dart';
import 'package:flowra/utils/theme.dart';

class StudyLockScreen extends StatefulWidget {
  const StudyLockScreen({super.key});

  @override
  State<StudyLockScreen> createState() => _StudyLockScreenState();
}

class _StudyLockScreenState extends State<StudyLockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<StudyLockProvider>();
      p.checkPermissions();
      p.loadBlockedApps();
      p.loadSessionHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lock = context.watch<StudyLockProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, size: 24),
            SizedBox(width: 8),
            Text('Study Lock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () {
              lock.checkPermissions();
              lock.syncNativeStatus();
              lock.loadBlockedApps();
              lock.loadSessionHistory();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryIndigo,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Status'),
            Tab(icon: Icon(Icons.block_rounded), text: 'Blocked Apps'),
            Tab(icon: Icon(Icons.history_rounded), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(context, lock),
          _buildBlockedAppsTab(context, lock),
          _buildHistoryTab(context, lock),
        ],
      ),
      floatingActionButton: !lock.isLockActive && lock.masterEnabled
          ? FloatingActionButton.extended(
              onPressed: () => _showStartLockDialog(context, lock),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Study Lock'),
              backgroundColor: AppTheme.primaryIndigo,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  // ─── Status & Active Session Tab ──────────────────────────────────────

  Widget _buildStatusTab(BuildContext context, StudyLockProvider lock) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Master Toggle Card
        _buildMasterToggleCard(context, lock),
        const SizedBox(height: 16),

        // 2. Active Session Card (if running)
        if (lock.isLockActive) ...[
          _buildActiveLockCard(context, lock),
          const SizedBox(height: 16),
        ],

        // 3. Privacy Guarantee Banner
        _buildPrivacyBanner(context),
        const SizedBox(height: 16),

        // 4. Permissions Status Cards
        _buildPermissionsSection(context, lock),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMasterToggleCard(
      BuildContext context, StudyLockProvider lock) {
    return Card(
      elevation: 0,
      color: lock.masterEnabled
          ? AppTheme.primaryIndigo.withAlpha(20)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: lock.masterEnabled
              ? AppTheme.primaryIndigo.withAlpha(100)
              : Theme.of(context).dividerColor.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lock.masterEnabled
                    ? AppTheme.primaryIndigo
                    : Colors.grey.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                lock.masterEnabled
                    ? Icons.shield_rounded
                    : Icons.shield_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Study Lock Shield',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lock.masterEnabled
                        ? 'Active — Distraction blocker ready'
                        : 'Disabled — Tasks will not block apps',
                    style: TextStyle(
                      fontSize: 12,
                      color: lock.masterEnabled
                          ? AppTheme.primaryIndigo
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: lock.masterEnabled,
              onChanged: (val) => lock.setMasterEnabled(val),
              activeThumbColor: AppTheme.primaryIndigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLockCard(
      BuildContext context, StudyLockProvider lock) {
    final minutes = lock.remainingSeconds ~/ 60;
    final seconds = lock.remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress = lock.durationMinutes > 0
        ? (1.0 - (lock.remainingSeconds / (lock.durationMinutes * 60)))
            .clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      shadowColor: AppTheme.primaryIndigo.withAlpha(80),
      color: const Color(0xFF1E1B4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'STUDY LOCK ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA5B4FC),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF312E81),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${lock.durationMinutes}m Session',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              lock.currentTaskTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Circular Countdown Timer
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFF312E81),
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF818CF8)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'REMAINING',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Attempts badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF451A03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withAlpha(120)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text(
                    'Blocked App Attempts: ${lock.blockedAttemptsCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFCD34D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // End Session Early Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmEndSessionEarly(context, lock),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('End Study Session Early'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFCA5A5),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBanner(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.teal.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.withAlpha(70)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.privacy_tip_rounded, color: Colors.teal, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '100% Offline & Private',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Study Lock works completely on your device. It never reads your messages, browsing history, passwords, or personal app data.',
                    style: TextStyle(fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(
      BuildContext context, StudyLockProvider lock) {
    final perms = lock.permissions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permission Health Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ensure the following permissions are granted for reliable blocker performance:',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),

        // Notifications
        _PermissionCard(
          title: 'Notifications',
          subtitle: 'Receive start-time prompt & active countdown',
          isGranted: perms['notification'] == true,
          onTap: () => lock.requestPermission('notification'),
          icon: Icons.notifications_active_rounded,
        ),

        // Exact Alarm
        _PermissionCard(
          title: 'Exact Alarms',
          subtitle: 'Precise start-time triggering at scheduled minute',
          isGranted: perms['exactAlarm'] == true,
          onTap: () => lock.requestPermission('exactAlarm'),
          icon: Icons.alarm_rounded,
        ),

        // Usage Access
        _PermissionCard(
          title: 'Usage Access (Primary Detector)',
          subtitle: 'Detects foreground app launches without reading content',
          isGranted: perms['usageAccess'] == true,
          onTap: () => lock.requestPermission('usageAccess'),
          icon: Icons.data_usage_rounded,
        ),

        // Accessibility Service
        _PermissionCard(
          title: 'Accessibility Service (Real-time Fallback)',
          subtitle: 'Instant (<50ms) redirection away from blocked apps',
          isGranted: perms['accessibility'] == true,
          onTap: () => lock.requestPermission('accessibility'),
          icon: Icons.accessibility_new_rounded,
        ),

        // Overlay Permission
        _PermissionCard(
          title: 'Display Over Other Apps',
          subtitle: 'Presents full-screen "Study Mode Active" overlay',
          isGranted: perms['overlay'] == true,
          onTap: () => lock.requestPermission('overlay'),
          icon: Icons.layers_rounded,
        ),

        // Battery Optimization
        _PermissionCard(
          title: 'Battery Optimization Exemption',
          subtitle: 'Prevents system battery saver from terminating monitor',
          isGranted: perms['batteryOptimization'] == true,
          onTap: () => lock.requestPermission('batteryOptimization'),
          icon: Icons.battery_charging_full_rounded,
        ),
      ],
    );
  }

  // ─── Blocked Apps Tab ─────────────────────────────────────────────────

  Widget _buildBlockedAppsTab(BuildContext context, StudyLockProvider lock) {
    final filtered = lock.blockedApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search blocked apps...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddAppModal(context, lock),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lock.activeBlockedApps.length} of ${lock.blockedApps.length} Apps Blocked',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                'Auto-blocking during sessions',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.apps_rounded,
                          size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No blocked apps configured'
                            : 'No apps match "$_searchQuery"',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final app = filtered[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: app.isBlocked
                              ? AppTheme.primaryIndigo.withAlpha(50)
                              : Theme.of(context).dividerColor.withAlpha(40),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: app.isBlocked
                              ? AppTheme.primaryIndigo.withAlpha(30)
                              : Colors.grey.withAlpha(30),
                          child: Icon(
                            Icons.android_rounded,
                            color: app.isBlocked
                                ? AppTheme.primaryIndigo
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          app.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: app.isBlocked ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch.adaptive(
                              value: app.isBlocked,
                              activeThumbColor: AppTheme.primaryIndigo,
                              onChanged: (val) {
                                if (app.id != null) {
                                  lock.toggleAppBlocked(app.id!, val);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 20),
                              color: AppTheme.dangerRed,
                              onPressed: () {
                                if (app.id != null) {
                                  lock.removeBlockedApp(app.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── History Tab ──────────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context, StudyLockProvider lock) {
    final history = lock.sessionHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 54, color: Colors.grey[600]),
            const SizedBox(height: 12),
            const Text(
              'No Study Lock Sessions Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Sessions started via schedule or manually will appear here.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final s = history[idx];
        final dt = DateTime.tryParse(s.startTime) ?? DateTime.now();
        final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(dt);

        final (statusLabel, statusColor, statusIcon) = switch (s.status) {
          'completed' => (
              'Completed',
              AppTheme.successGreen,
              Icons.check_circle_rounded
            ),
          'skipped' => (
              'Skipped',
              AppTheme.warningOrange,
              Icons.skip_next_rounded
            ),
          'missed' => (
              'Missed',
              AppTheme.dangerRed,
              Icons.cancel_rounded
            ),
          'ended_early' => (
              'Ended Early',
              Colors.amber,
              Icons.stop_circle_rounded
            ),
          _ => ('Active', AppTheme.primaryIndigo, Icons.play_arrow_rounded),
        };

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.taskTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetricChip(
                      label: 'Planned',
                      value: '${s.plannedDurationMinutes}m',
                      icon: Icons.timer_outlined,
                    ),
                    const SizedBox(width: 8),
                    _MetricChip(
                      label: 'Focused',
                      value: '${s.actualDurationMinutes}m',
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                    const SizedBox(width: 8),
                    _MetricChip(
                      label: 'Blocked Attempts',
                      value: '${s.blockedAttemptsCount}',
                      icon: Icons.shield_outlined,
                      highlightColor: s.blockedAttemptsCount > 0
                          ? AppTheme.warningOrange
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Dialogs & Modals ─────────────────────────────────────────────────

  void _showStartLockDialog(BuildContext context, StudyLockProvider lock) {
    int duration = 25;
    final titleController = TextEditingController(text: 'Deep Focus Session');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_clock_rounded,
                      color: AppTheme.primaryIndigo),
                  SizedBox(width: 8),
                  Text(
                    'Start Study Lock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Focus Title',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Duration',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [15, 25, 45, 60, 90].map((d) {
                  final isSelected = duration == d;
                  return ChoiceChip(
                    label: Text('${d}m'),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryIndigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (sel) {
                      if (sel) setModalState(() => duration = d);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await lock.startStudyLock(
                      taskTitle: titleController.text.trim().isEmpty
                          ? 'Study Session'
                          : titleController.text.trim(),
                      durationMinutes: duration,
                    );
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Distraction Blocker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmEndSessionEarly(
      BuildContext context, StudyLockProvider lock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Study Session Early?'),
        content: const Text(
          'Are you sure you want to stop Study Lock now? Distraction blocking will be deactivated immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Focusing'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await lock.stopStudyLock(endedEarly: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showAddAppModal(BuildContext context, StudyLockProvider lock) {
    lock.loadInstalledApps();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final installed = lock.installedApps;
          final blockedPkgs =
              lock.blockedApps.map((b) => b.packageName).toSet();

          final available = installed.where((app) {
            final pkg = app['packageName'] as String? ?? '';
            final name = app['appName'] as String? ?? '';
            final matchesQuery = query.isEmpty ||
                name.toLowerCase().contains(query.toLowerCase()) ||
                pkg.toLowerCase().contains(query.toLowerCase());
            return matchesQuery && !blockedPkgs.contains(pkg);
          }).toList();

          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select App to Block',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search installed apps...',
                      prefixIcon: Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                    onChanged: (val) => setModalState(() => query = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: lock.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : available.isEmpty
                            ? Center(
                                child: Text(
                                  installed.isEmpty
                                      ? 'No launchable apps found'
                                      : 'No additional apps match query',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              )
                            : ListView.separated(
                                itemCount: available.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final app = available[i];
                                  final pkg =
                                      app['packageName'] as String? ?? '';
                                  final name =
                                      app['appName'] as String? ?? '';

                                  return ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.android_rounded),
                                    ),
                                    title: Text(name),
                                    subtitle: Text(
                                      pkg,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: AppTheme.primaryIndigo,
                                      ),
                                      onPressed: () {
                                        lock.addBlockedApp(pkg, name);
                                        setModalState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onTap;
  final IconData icon;

  const _PermissionCard({
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isGranted
              ? AppTheme.successGreen.withAlpha(60)
              : AppTheme.warningOrange.withAlpha(80),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isGranted ? AppTheme.successGreen : AppTheme.warningOrange,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        trailing: isGranted
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppTheme.successGreen, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Allowed',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Enable', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? highlightColor;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlightColor ?? Theme.of(context).dividerColor.withAlpha(40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: highlightColor ?? Colors.grey),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlightColor,
            ),
          ),
        ],
      ),
    );
  }
}
