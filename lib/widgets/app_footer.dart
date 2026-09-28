/// ============================================================================
/// APP FOOTER SECTION (Bottom Navigation Bar)
/// ============================================================================
/// You can manually change, reorder, or customize the footer items, icons,
/// and labels in this file.
/// ============================================================================
library;

import 'package:flutter/material.dart';

/// Item model representing a single tab item in the app footer.
class FooterNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? tooltip;

  const FooterNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.tooltip,
  });
}

/// The customizable Footer widget shown at the bottom of the main application shell.
class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // ✏️ MANUAL EDIT SECTION: Change footer items, labels, and icons below:
  // ──────────────────────────────────────────────────────────────────────────
  static const List<FooterNavItem> items = [
    FooterNavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      tooltip: 'Home Dashboard',
    ),
    FooterNavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Timetable',
      tooltip: 'Timetable & Tasks',
    ),
    FooterNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Expenses',
      tooltip: 'Expenses & Budget',
    ),
    FooterNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Reports',
      tooltip: 'Reports & Analytics',
    ),
    FooterNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      tooltip: 'Settings & Notifications',
    ),
  ];
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
              tooltip: item.tooltip ?? item.label,
            ),
          )
          .toList(),
    );
  }
}
