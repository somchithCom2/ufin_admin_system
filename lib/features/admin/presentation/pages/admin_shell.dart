import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/dashboard_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shops_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/users_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscriptions_list_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/plans_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/payments_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/statistics_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/revenue_report_page.dart';

/// Global scaffold key for drawer access
final adminScaffoldKey = GlobalKey<ScaffoldState>();

/// Navigation item model
class _NavItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? section;

  const _NavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.section,
  });
}

/// Main admin shell with drawer navigation
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ShopsPage(),
    UsersPage(),
    SubscriptionsListPage(),
    PlansPage(),
    PaymentsPage(),
    StatisticsPage(),
    RevenueReportPage(),
  ];

  final List<_NavItem> _navItems = const [
    // Main
    _NavItem(
      index: 0,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    // Management
    _NavItem(
      index: 1,
      label: 'Shops',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      section: 'Management',
    ),
    _NavItem(
      index: 2,
      label: 'Users',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    // Subscriptions
    _NavItem(
      index: 3,
      label: 'Subscriptions',
      icon: Icons.card_membership_outlined,
      selectedIcon: Icons.card_membership,
      section: 'Subscriptions',
    ),
    _NavItem(
      index: 4,
      label: 'Plans',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
    ),
    _NavItem(
      index: 6,
      label: 'Statistics',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
    ),
    // Finance
    _NavItem(
      index: 5,
      label: 'Payments',
      icon: Icons.payment_outlined,
      selectedIcon: Icons.payment,
      section: 'Finance',
    ),
    _NavItem(
      index: 7,
      label: 'Revenue Report',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 800;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildDrawerContent() {
      return Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    authState.username?.substring(0, 1).toUpperCase() ?? 'A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.username ?? 'Admin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrator',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavItems(colorScheme),
            ),
          ),
          // Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      );
    }

    if (isWideScreen) {
      // Desktop/Tablet: Persistent side drawer
      final isExtended = MediaQuery.of(context).size.width >= 1100;

      return Scaffold(
        body: Row(
          children: [
            // Side drawer
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isExtended ? 260 : 72,
              child: Material(
                color: colorScheme.surface,
                elevation: 1,
                child: isExtended
                    ? buildDrawerContent()
                    : _buildCompactRail(colorScheme, authState),
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: colorScheme.surfaceContainerLowest,
                child: _pages[_currentIndex],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: Use drawer with global key
    return Scaffold(
      key: adminScaffoldKey,
      drawer: Drawer(child: buildDrawerContent()),
      body: _pages[_currentIndex],
    );
  }

  Widget _buildCompactRail(ColorScheme colorScheme, AuthState authState) {
    return Column(
      children: [
        // Avatar
        Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            MediaQuery.of(context).padding.top + 16,
            0,
            16,
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary,
            child: Text(
              authState.username?.substring(0, 1).toUpperCase() ?? 'A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Nav items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: _navItems.map((item) {
              final isSelected = _currentIndex == item.index;
              return Tooltip(
                message: item.label,
                preferBelow: false,
                waitDuration: const Duration(milliseconds: 500),
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = item.index),
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Logout
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            top: 8,
          ),
          child: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNavItems(ColorScheme colorScheme) {
    final List<Widget> widgets = [];
    String? currentSection;

    for (final item in _navItems) {
      // Add section header if new section
      if (item.section != null && item.section != currentSection) {
        currentSection = item.section;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              item.section!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      }

      final isSelected = _currentIndex == item.index;
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            selected: isSelected,
            selectedTileColor: colorScheme.primaryContainer,
            leading: Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              size: 22,
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            onTap: () {
              setState(() => _currentIndex = item.index);
              // Close drawer on mobile
              if (MediaQuery.of(context).size.width < 800) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
    }

    return widgets;
  }
}

/// Helper widget to build AppBar leading menu button for mobile
Widget? buildAdminMenuButton(BuildContext context) {
  final isWideScreen = MediaQuery.of(context).size.width >= 800;
  if (isWideScreen) return null;

  return IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {
      adminScaffoldKey.currentState?.openDrawer();
    },
  );
}
