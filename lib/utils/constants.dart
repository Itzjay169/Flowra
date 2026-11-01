/// Flowra - Offline Planner & Expense Tracker
/// App-wide constants and configuration.
library;

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Flowra';
  static const String appDescription =
      'Offline planner & expense tracker for everyone — students, working professionals, and anyone managing their time and money.';
  static const String githubRepoUrl = 'https://github.com/Itzjay169/Flowra';
  static const String githubProfileUrl = 'https://github.com/Itzjay169';
  static const String instagramUrl =
      'https://www.instagram.com/jay_dev._._';
  static const String developerName = 'Jay';
  static const String companyName = 'Vexora Technology';
  static const String companyTagline = 'Innovating Today. Building Tomorrow.';
  static const String companyAbout =
      'Vexora Technology is a software development company dedicated to creating innovative digital products and smart technology solutions. We focus on web development, mobile applications, artificial intelligence, and custom software development.\n\nOur goal is to transform ideas into powerful, reliable, and user-friendly solutions that simplify everyday challenges and create meaningful digital experiences.\n\nDriven by innovation and creativity, we aim to build technology that makes a difference.';
  static const String companyMission =
      'This project was proudly made by Vexora Technology to help students succeed, developed by Jay.';
  static const String copyrightClaim =
      '© 2026 Vexora Technology. Developed by Jay. All rights reserved.';
  static const String vexoraLogoPath = 'assets/images/vexora_logo.png';

  // Donation configuration
  static const String donationUpiId = 'jaykishandas30@oksbi';
  static const String donationUpiName = 'Flowra Developer';
  static const String donationPaymentLink = '';
  // Set to true when you configure a valid UPI ID or payment link
  static const bool isDonationEnabled = true;

  // Notification channels
  static const String studyAlertChannelId = 'study_alerts_v2';
  static const String studyAlertChannelName = 'Task Alerts & Reminders';
  static const String studyAlertChannelDesc =
      'High-priority notifications and sound reminders for your tasks';

  static const String alarmAlertChannelId = 'task_alarm_alerts_v2';
  static const String alarmAlertChannelName = 'Task Alarms (High Priority)';
  static const String alarmAlertChannelDesc =
      'Alarm sound and vibration alerts for critical schedule tasks';

  static const String studyLockPromptChannelId = 'study_lock_prompt_v1';
  static const String studyLockPromptChannelName = 'Study Lock Start Prompt';
  static const String studyLockPromptChannelDesc =
      'High-priority prompt to accept or skip distraction blocking when task starts';

  static const String studyLockActiveChannelId = 'study_lock_active_v1';
  static const String studyLockActiveChannelName = 'Study Lock Active Session';
  static const String studyLockActiveChannelDesc =
      'Persistent timer and status notification while distraction blocking is active';

  // Default settings
  static const String defaultCurrency = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const double defaultMonthlyBudget = 0.0;
  static const int defaultPreAlertMinutes = 5;

  // Shared preferences keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyCurrencyCode = 'currency_code';
  static const String keyMonthlyBudget = 'monthly_budget';
  static const String keyThemeMode = 'theme_mode';
  static const String keyPreAlertEnabled = 'pre_alert_enabled';
  static const String keyPreAlertMinutes = 'pre_alert_minutes';
  static const String keyShowNextTaskNotification = 'show_next_task_notif';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyStudyLockMasterEnabled = 'study_lock_master_enabled';

  // User roles
  static const String roleStudent = 'Student';
  static const String roleProfessional = 'Working Professional';
  static const String roleOther = 'Other';
  static const List<String> userRoles = [
    roleStudent,
    roleProfessional,
    roleOther,
  ];

  // Task categories/subjects covering both work and study contexts
  static const List<String> taskSubjects = [
    'Work',
    'Study',
    'Meeting',
    'Class',
    'Assignment',
    'Revision',
    'Exam Prep',
    'Errand',
    'Exercise',
    'Health',
    'Family',
    'Personal',
    'Other',
  ];

  // Subjects that trigger Study Lock option by default
  static const List<String> studyLockSubjects = [
    'Study',
    'Class',
    'Assignment',
    'Revision',
    'Exam Prep',
  ];

  // Default subject lists lightly personalized by role
  static const List<String> studentSubjects = [
    'Study',
    'Class',
    'Assignment',
    'Revision',
    'Exam Prep',
    'Exercise',
    'Personal',
  ];

  static const List<String> professionalSubjects = [
    'Work',
    'Meeting',
    'Errand',
    'Exercise',
    'Health',
    'Personal',
    'Other',
  ];

  static List<String> getTaskSubjectsForRole(String? role) {
    if (role == roleStudent) {
      final set = studentSubjects.toSet();
      final others = taskSubjects.where((s) => !set.contains(s)).toList();
      return [...studentSubjects, ...others];
    } else if (role == roleProfessional) {
      final set = professionalSubjects.toSet();
      final others = taskSubjects.where((s) => !set.contains(s)).toList();
      return [...professionalSubjects, ...others];
    }
    return taskSubjects;
  }

  // Task priorities
  static const List<String> taskPriorities = ['Normal', 'Important', 'Critical'];

  // Task repeat types
  static const List<String> repeatTypes = [
    'Once',
    'Daily',
    'Weekdays',
    'Weekly',
    'Custom',
  ];

  // Notification types
  static const List<String> notificationTypes = [
    'Silent popup',
    'Sound + vibration',
    'Alarm-style reminder',
  ];

  // Task statuses
  static const String statusUpcoming = 'Upcoming';
  static const String statusRunning = 'Running';
  static const String statusCompleted = 'Completed';
  static const String statusMissed = 'Missed';
  static const String statusSkipped = 'Skipped';

  // Expense categories
  static const List<String> expenseCategories = [
    'Food',
    'Travel',
    'College',
    'Recharge / Internet',
    'Shopping',
    'Entertainment',
    'Health',
    'Other',
  ];

  // Payment methods
  static const List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Card',
    'Other',
  ];

  // Currency options
  static const Map<String, String> currencies = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
  };

  // Donation preset amounts
  static const List<int> donationPresets = [10, 20, 50, 100];
}
