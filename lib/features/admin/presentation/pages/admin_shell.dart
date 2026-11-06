import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/dashboard_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shops_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/users_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscriptions_list_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/plans_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/payments_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/statistics_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/revenue_report_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/daily_sales_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shop_type_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/units_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/deleted_users_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/upgrade_requests_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/app_releases_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/system_configuration_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/work_queue_provider.dart';

/// Global scaffold key for drawer access
final adminScaffoldKey = GlobalKey<ScaffoldState>();

/// Sections of the admin console. Order defines the sidebar order.
enum AdminSection {
  dashboard(
    'Dashboard',
    Icons.space_dashboard_outlined,
    Icons.space_dashboard_rounded,
    null,
  ),
  shops(
    'Shops',
    Icons.storefront_outlined,
    Icons.storefront_rounded,
    'Management',
  ),
  users('Users', Icons.people_outline_rounded, Icons.people_rounded, null),
  shopTypes(
    'Shop Types',
    Icons.category_outlined,
    Icons.category_rounded,
    null,
  ),
  units('Units', Icons.straighten_outlined, Icons.straighten_rounded, null),
  deletedUsers(
    'Deleted Users',
    Icons.person_remove_outlined,
    Icons.person_remove_rounded,
    null,
  ),
  subscriptions(
    'Subscriptions',
    Icons.card_membership_outlined,
    Icons.card_membership_rounded,
    'Subscriptions',
  ),
  plans('Plans', Icons.inventory_2_outlined, Icons.inventory_2_rounded, null),
  upgradeRequests(
    'Upgrade Requests',
    Icons.upgrade_outlined,
    Icons.upgrade_rounded,
    null,
  ),
  statistics(
    'Statistics',
    Icons.analytics_outlined,
    Icons.analytics_rounded,
    null,
  ),
  payments(
    'Payments',
    Icons.payments_outlined,
    Icons.payments_rounded,
    'Finance',
  ),
  revenue(
    'Revenue Report',
    Icons.bar_chart_outlined,
    Icons.bar_chart_rounded,
    null,
  ),
  dailySales(
    'Daily Sales',
    Icons.trending_up_outlined,
    Icons.trending_up_rounded,
    null,
  ),
  appReleases(
    'App Releases',
    Icons.system_update_outlined,
    Icons.system_update_rounded,
    'System',
  ),
  systemConfig(
    'System Config',
    Icons.settings_outlined,
    Icons.settings_rounded,
    null,
  );

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Group header shown above this item; `null` continues the previous group.
  final String? group;

  const AdminSection(this.label, this.icon, this.selectedIcon, this.group);

  Widget buildPage() => switch (this) {
    AdminSection.dashboard => const DashboardPage(),
    AdminSection.shops => const ShopsPage(),
    AdminSection.users => const UsersPage(),
    AdminSection.shopTypes => const ShopTypePage(),
    AdminSection.units => const UnitsPage(),
    AdminSection.deletedUsers => const DeletedUsersPage(),
    AdminSection.subscriptions => const SubscriptionsListPage(),
    AdminSection.plans => const PlansPage(),
    AdminSection.upgradeRequests => const UpgradeRequestsPage(),
    AdminSection.statistics => const StatisticsPage(),
    AdminSection.payments => const PaymentsPage(),
    AdminSection.revenue => const RevenueReportPage(),
    AdminSection.dailySales => const DailySalesPage(),
    AdminSection.appReleases => const AppReleasesPage(),
    AdminSection.systemConfig => const SystemConfigurationPage(),
  };
}

/// Currently selected admin section. Pages can write to it to cross-link
/// (e.g. dashboard tiles jumping to Shops).
final adminSectionProvider = StateProvider.autoDispose<AdminSection>(
  (ref) => AdminSection.dashboard,
);

/// Opens Subscriptions with these filters selected, from anywhere.
void openSubscriptionsWith(
  WidgetRef ref, {
  String? status,
  SubscriptionPlanFilter plan = SubscriptionPlanFilter.all,
}) {
  ref.read(subscriptionsListPresetProvider.notifier).state = (
    status: status,
    plan: plan,
  );
  ref.read(adminSectionProvider.notifier).state = AdminSection.subscriptions;
}

/// Opens Upgrade Requests on its Pending list, from anywhere.
void openPendingUpgradeRequests(WidgetRef ref) {
  ref.read(upgradeRequestsShowPendingProvider.notifier).state = true;
  ref.read(adminSectionProvider.notifier).state = AdminSection.upgradeRequests;
}

/// The count shown on a sidebar item, from the work queue; `null` for none.
({int count, bool urgent})? _navBadge(AdminSection section, WorkQueue? queue) {
  final count = switch (section) {
    AdminSection.upgradeRequests => queue?.pendingRequests,
    AdminSection.subscriptions => queue?.expiring?.length,
    _ => null,
  };
  if (count == null || count == 0) return null;
  // A request waits on the admin; an expiring plan is only a heads-up.
  return (count: count, urgent: section == AdminSection.upgradeRequests);
}

/// Main admin shell: persistent sidebar on wide screens, drawer on mobile.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  /// Pages are built on first visit and then kept alive so filters,
  /// scroll positions and loaded data survive switching sections.
  final Map<AdminSection, Widget> _visited = {};

  Future<void> _confirmLogout() async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to access the admin console.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (ok && mounted) {
      ref.read(authStateProvider.notifier).logout();
    }
  }

  void _select(AdminSection section, {bool closeDrawer = false}) {
    if (closeDrawer) adminScaffoldKey.currentState?.closeDrawer();
    ref.read(adminSectionProvider.notifier).state = section;
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(adminSectionProvider);
    // Each visit to a section is a chance the queue moved on; the notifier
    // skips this if it loaded in the last 30 seconds.
    ref.listen(
      adminSectionProvider,
      (_, _) => ref.read(workQueueProvider.notifier).refresh(),
    );
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSpacing.tabletBreakpoint;
    final isExtended = width >= AppSpacing.desktopBreakpoint;

    _visited.putIfAbsent(current, current.buildPage);
    final sections = _visited.keys.toList(growable: false);
    final body = IndexedStack(
      index: sections.indexOf(current),
      children: [
        for (final s in sections)
          // TickerMode pauses animations on hidden pages.
          TickerMode(enabled: s == current, child: _visited[s]!),
      ],
    );

    if (isWide) {
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: isExtended ? 264 : 76,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(right: BorderSide(color: scheme.outlineVariant)),
              ),
              child: _Sidebar(
                current: current,
                compact: !isExtended,
                onSelect: _select,
                onLogout: _confirmLogout,
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      key: adminScaffoldKey,
      drawer: Drawer(
        width: 288,
        child: _Sidebar(
          current: current,
          compact: false,
          onSelect: (s) => _select(s, closeDrawer: true),
          onLogout: () {
            adminScaffoldKey.currentState?.closeDrawer();
            _confirmLogout();
          },
        ),
      ),
      body: body,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final AdminSection current;
  final bool compact;
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.current,
    required this.compact,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final queue = ref.watch(workQueueProvider).queue;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = MediaQuery.paddingOf(context);

    final items = <Widget>[];
    for (final s in AdminSection.values) {
      if (s.group != null) {
        items.add(
          compact
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: Divider(),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
                  child: Text(
                    s.group!.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
        );
      }
      items.add(
        _NavTile(
          section: s,
          selected: s == current,
          compact: compact,
          badge: _navBadge(s, queue),
          onTap: () => onSelect(s),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand
        Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 0 : 20,
            padding.top + 18,
            compact ? 0 : 16,
            14,
          ),
          child: compact
              ? const Center(child: AppLogo(size: 36))
              : Row(
                  children: [
                    const AppLogo(size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UFin Admin',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Control center',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: items,
          ),
        ),
        const Divider(),
        // Account
        Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 0 : 12,
            10,
            compact ? 0 : 8,
            padding.bottom + 12,
          ),
          child: compact
              ? Column(
                  children: [
                    Tooltip(
                      message: auth.username ?? 'Admin',
                      child: InitialAvatar(name: auth.username),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      tooltip: 'Sign out',
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      onPressed: onLogout,
                    ),
                  ],
                )
              : Row(
                  children: [
                    InitialAvatar(name: auth.username),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.username ?? 'Admin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            humanize(auth.role ?? 'Administrator'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      onPressed: onLogout,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminSection section;
  final bool selected;
  final bool compact;
  final ({int count, bool urgent})? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.section,
    required this.selected,
    required this.compact,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = context.status;
    final badge = this.badge;
    final (Color badgeBg, Color badgeFg) = badge?.urgent ?? false
        ? (scheme.primary, scheme.onPrimary)
        : (status.warningContainer, status.onWarningContainer);
    final badgeText = badge == null
        ? ''
        : badge.count > 99
        ? '99+'
        : '${badge.count}';
    final icon = Icon(
      selected ? section.selectedIcon : section.icon,
      color: selected ? scheme.primary : scheme.onSurfaceVariant,
      size: compact ? 22 : 20,
    );
    final bg = selected
        ? scheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    final tile = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 12, vertical: 1),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          onTap: onTap,
          child: SizedBox(
            height: 42,
            child: compact
                ? Center(
                    child: badge == null
                        ? icon
                        : Badge(
                            label: Text(badgeText),
                            backgroundColor: badgeBg,
                            textColor: badgeFg,
                            child: icon,
                          ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 12),
                      icon,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          section.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? scheme.primary : scheme.onSurface,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          constraints: const BoxConstraints(minWidth: 22),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: badgeFg,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                    ],
                  ),
          ),
        ),
      ),
    );

    return Semantics(
      selected: selected,
      button: true,
      label: badge == null
          ? section.label
          : '${section.label}, ${badge.count} '
                '${badge.urgent ? 'waiting' : 'expiring soon'}',
      child: compact
          ? Tooltip(
              message: badge == null
                  ? section.label
                  : '${section.label} · ${badge.count} '
                        '${badge.urgent ? 'waiting' : 'expiring soon'}',
              preferBelow: false,
              child: tile,
            )
          : tile,
    );
  }
}

/// Helper widget to build AppBar leading menu button for mobile
Widget? buildAdminMenuButton(BuildContext context) {
  final isWideScreen =
      MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  if (isWideScreen) return null;

  return Consumer(
    builder: (context, ref, _) {
      // On a phone the badges are inside the closed drawer; a dot says so.
      final queue = ref.watch(workQueueProvider).queue;
      final waiting =
          (queue?.pendingRequests ?? 0) + (queue?.expiring?.length ?? 0);
      return IconButton(
        tooltip: waiting > 0 ? 'Menu · items need attention' : 'Menu',
        icon: Badge(
          isLabelVisible: waiting > 0,
          smallSize: 8,
          child: const Icon(Icons.menu_rounded),
        ),
        onPressed: () {
          adminScaffoldKey.currentState?.openDrawer();
        },
      );
    },
  );
}
