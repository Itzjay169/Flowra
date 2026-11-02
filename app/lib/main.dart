/// Flowra — Offline Planner & Expense Tracker
/// Entry point with Provider setup, routing, and bottom navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flowra/providers/task_provider.dart';
import 'package:flowra/providers/expense_provider.dart';
import 'package:flowra/providers/settings_provider.dart';
import 'package:flowra/providers/study_lock_provider.dart';
import 'package:flowra/services/app_version_service.dart';
import 'package:flowra/services/notification_service.dart';
import 'package:flowra/services/settings_service.dart';
import 'package:flowra/screens/onboarding_screen.dart';
import 'package:flowra/screens/home_screen.dart';
import 'package:flowra/screens/timetable_screen.dart';
import 'package:flowra/screens/study_lock_screen.dart';
import 'package:flowra/screens/expenses_screen.dart';
import 'package:flowra/screens/reports_screen.dart';
import 'package:flowra/screens/settings_screen.dart';
import 'package:flowra/screens/add_edit_task_screen.dart';
import 'package:flowra/screens/add_edit_expense_screen.dart';
import 'package:flowra/screens/study_focus_screen.dart';
import 'package:flowra/widgets/app_footer.dart';
import 'package:flowra/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await AppVersionService.initialize();

  final settingsService = SettingsService();
  await settingsService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => StudyLockProvider()),
      ],
      child: const FlowraApp(),
    ),
  );
}

class FlowraApp extends StatefulWidget {
  const FlowraApp({super.key});

  @override
  State<FlowraApp> createState() => _FlowraAppState();
}

class _FlowraAppState extends State<FlowraApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Load settings and reschedule notifications after app launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.loadSettings();

      // Reschedule all notifications (handles boot, timezone change, etc.)
      if (!mounted) return;
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.rescheduleAllNotifications();

      // Handle notification tap actions
      final notifService = NotificationService();
      notifService.onNotificationAction = (actionId, payload) {
        _handleNotificationAction(actionId, payload);
      };
      notifService.onNotificationTap = (payload) {
        _handleNotificationTap(payload);
      };
    });
  }

  void _handleNotificationAction(String actionId, String? payload) {
    if (payload == null) return;
    final parts = payload.split(':');
    if (parts.length < 2) return;
    final taskId = int.tryParse(parts[1]);
    if (taskId == null) return;

    final taskProvider = context.read<TaskProvider>();

    switch (actionId) {
      case 'start_now':
        taskProvider.startTask(taskId);
        break;
      case 'snooze_10':
        // Snooze needs the task object
        taskProvider.loadTodayTasks().then((_) {
          final task = taskProvider.todayTasks
              .where((t) => t.id == taskId)
              .firstOrNull;
          if (task != null) {
            taskProvider.snoozeTask(task, 10);
          }
        });
        break;
      case 'done':
        taskProvider.completeTask(taskId);
        break;
      case 'accept_study_lock':
        taskProvider.startTask(taskId);
        taskProvider.loadTodayTasks().then((_) {
          final task = taskProvider.todayTasks
              .where((t) => t.id == taskId)
              .firstOrNull;
          if (task != null && mounted) {
            context.read<StudyLockProvider>().startStudyLock(
                  taskId: task.id,
                  taskTitle: task.title,
                  durationMinutes: task.durationMinutes,
                );
          }
        });
        break;
      case 'reject_study_lock':
        taskProvider.loadTodayTasks().then((_) {
          final task = taskProvider.todayTasks
              .where((t) => t.id == taskId)
              .firstOrNull;
          if (task != null && mounted) {
            context.read<StudyLockProvider>().recordSkippedSession(
                  taskId: task.id,
                  taskTitle: task.title,
                  durationMinutes: task.durationMinutes,
                );
          }
        });
        break;
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    final parts = payload.split(':');
    if (parts.length < 2) return;
    final taskId = int.tryParse(parts[1]);

    if (parts[0] == 'studylock') {
      if (_navigatorKey.currentState != null) {
        _navigatorKey.currentState!.pushNamed('/study-lock');
      }
      return;
    }

    if (taskId == null) return;

    final taskProvider = context.read<TaskProvider>();
    taskProvider.loadTodayTasks().then((_) {
      final task = taskProvider.todayTasks
          .where((t) => t.id == taskId)
          .firstOrNull;
      if (task != null && _navigatorKey.currentState != null) {
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => StudyFocusScreen(initialTask: task),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final settingsService = SettingsService();

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flowra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: settings.themeMode,
      home: settingsService.isOnboardingComplete
          ? const MainShell()
          : const OnboardingScreen(),
      routes: {
        '/main': (_) => const MainShell(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/add-task': (_) => const AddEditTaskScreen(),
        '/add-expense': (_) => const AddEditExpenseScreen(),
        '/focus': (_) => const StudyFocusScreen(),
        '/study-lock': (_) => const StudyLockScreen(),
      },
    );
  }
}

/// Main app shell with bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    ).then((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadTodayTasks();
    });
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
    ).then((_) {
      if (!mounted) return;
      context.read<ExpenseProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onAddTask: _navigateToAddTask,
        onAddExpense: _navigateToAddExpense,
      ),
      const TimetableScreen(),
      const ExpensesScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // ======================================================================
      // 📱 FOOTER SECTION (Bottom Navigation Bar)
      // ----------------------------------------------------------------------
      // To manually customize footer items, icons, and labels, edit:
      // lib/widgets/app_footer.dart
      // ======================================================================
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTabSelected: _onTabChanged,
      ),
    );
  }
}
