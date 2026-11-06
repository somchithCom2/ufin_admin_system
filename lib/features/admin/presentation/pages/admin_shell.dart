import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/settings/app_settings.dart';
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
import 'package:ufin_admin_system/features/admin/presentation/widgets/command_palette.dart';

/// Key of the phone-layout scaffold.
final adminScaffoldKey = GlobalKey<ScaffoldState>();

/// Sections of the admin console. Order defines the sidebar order.
enum AdminSection {
  dashboard(
    NavText.dashboard,
    Icons.space_dashboard_outlined,
    Icons.space_dashboard_rounded,
    null,
  ),
  shops(
    NavText.shops,
    Icons.storefront_outlined,
    Icons.storefront_rounded,
    NavText.groupManagement,
  ),
  users(
    NavText.users,
    Icons.people_outline_rounded,
    Icons.people_rounded,
    null,
  ),
  shopTypes(
    NavText.shopTypes,
    Icons.category_outlined,
    Icons.category_rounded,
    null,
  ),
  units(
    NavText.units,
    Icons.straighten_outlined,
    Icons.straighten_rounded,
    null,
  ),
  deletedUsers(
    NavText.deletedUsers,
    Icons.person_remove_outlined,
    Icons.person_remove_rounded,
    null,
  ),
  subscriptions(
    NavText.subscriptions,
    Icons.card_membership_outlined,
    Icons.card_membership_rounded,
    NavText.groupSubscriptions,
  ),
  plans(
    NavText.plans,
    Icons.inventory_2_outlined,
    Icons.inventory_2_rounded,
    null,
  ),
  upgradeRequests(
    NavText.upgradeRequests,
    Icons.upgrade_outlined,
    Icons.upgrade_rounded,
    null,
  ),
  statistics(
    NavText.statistics,
    Icons.analytics_outlined,
    Icons.analytics_rounded,
    null,
  ),
  payments(
    NavText.payments,
    Icons.payments_outlined,
    Icons.payments_rounded,
    NavText.groupFinance,
  ),
  revenue(
    NavText.revenue,
    Icons.bar_chart_outlined,
    Icons.bar_chart_rounded,
    null,
  ),
  dailySales(
    NavText.dailySales,
    Icons.trending_up_outlined,
    Icons.trending_up_rounded,
    null,
  ),
  appReleases(
    NavText.appReleases,
    Icons.system_update_outlined,
    Icons.system_update_rounded,
    NavText.groupSystem,
  ),
  systemConfig(
    NavText.systemConfig,
    Icons.settings_outlined,
    Icons.settings_rounded,
    null,
  );

  final Tr title;
  final IconData icon;
  final IconData selectedIcon;

  /// Group header shown above this item; `null` continues the previous group.
  final Tr? group;

  const AdminSection(this.title, this.icon, this.selectedIcon, this.group);

  /// Sections pinned to the phone's bottom bar; the rest live under "More".
  static const primary = [dashboard, shops, subscriptions, payments];

  /// The group this section sits in (walks back to the last header).
  Tr? get groupTitle {
    for (var i = index; i >= 0; i--) {
      final g = AdminSection.values[i].group;
      if (g != null) return g;
    }
    return null;
  }

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

typedef _Badge = ({int count, bool urgent});

/// The count shown on a nav item, from the work queue; `null` for none.
_Badge? _navBadge(AdminSection section, WorkQueue? queue) {
  final count = switch (section) {
    AdminSection.upgradeRequests => queue?.pendingRequests,
    AdminSection.subscriptions => queue?.expiring?.length,
    _ => null,
  };
  if (count == null || count == 0) return null;
  // A request waits on the admin; an expiring plan is only a heads-up.
  return (count: count, urgent: section == AdminSection.upgradeRequests);
}

String _badgeText(int count) => count > 99 ? '99+' : '$count';

Tr _badgeMeaning(_Badge b) =>
    b.urgent ? NavText.waiting(b.count) : NavText.expiringSoon(b.count);

bool get _isApple =>
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Main admin shell.
///
/// * Phone (< 800): bottom navigation with the four busiest sections and a
///   "More" sheet holding everything else, settings and the account.
/// * Tablet (800–1100): icon rail.
/// * Desktop (≥ 1100): full sidebar, collapsible to the rail.
///
/// Ctrl/⌘ + K opens a quick-jump palette at every size.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  /// Pages are built on first visit and then kept alive so filters,
  /// scroll positions and loaded data survive switching sections.
  final Map<AdminSection, Widget> _visited = {};

  bool _paletteOpen = false;

  Future<void> _confirmLogout() async {
    final ok = await AppDialogs.confirm(
      context,
      title: context.tr(NavText.signOutTitle),
      message: context.tr(NavText.signOutMessage),
      confirmLabel: context.tr(NavText.signOut),
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (ok && mounted) {
      ref.read(authStateProvider.notifier).logout();
    }
  }

  void _select(AdminSection section) {
    ref.read(adminSectionProvider.notifier).state = section;
  }

  Future<void> _openPalette() async {
    if (_paletteOpen) return;
    _paletteOpen = true;
    try {
      await showCommandPalette(
        context,
        items: [
          for (final s in AdminSection.values)
            PaletteItem(
              title: s.title,
              subtitle: s.groupTitle,
              icon: s.icon,
              onSelect: () => _select(s),
            ),
          PaletteItem(
            title: SettingsText.toggleTheme,
            icon: Icons.contrast_rounded,
            isAction: true,
            onSelect: () {
              if (mounted) toggleBrightness(context, ref);
            },
          ),
          PaletteItem(
            title: SettingsText.switchLanguage,
            icon: Icons.translate_rounded,
            isAction: true,
            onSelect: () => toggleLanguage(ref),
          ),
          PaletteItem(
            title: SettingsText.settings,
            icon: Icons.tune_rounded,
            isAction: true,
            onSelect: () {
              if (mounted) showAppSettings(context);
            },
          ),
          PaletteItem(
            title: NavText.signOut,
            icon: Icons.logout_rounded,
            isAction: true,
            onSelect: _confirmLogout,
          ),
        ],
      );
    } finally {
      _paletteOpen = false;
    }
  }

  Future<void> _openMoreSheet() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MoreSheet(
        onSelect: (s) {
          Navigator.of(sheetContext).pop();
          _select(s);
        },
        onSearch: () {
          Navigator.of(sheetContext).pop();
          _openPalette();
        },
        onLogout: () {
          Navigator.of(sheetContext).pop();
          _confirmLogout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(adminSectionProvider);
    final collapsedPref = ref.watch(
      appSettingsProvider.select((s) => s.sidebarCollapsed),
    );
    // Each visit to a section is a chance the queue moved on; the notifier
    // skips this if it loaded in the last 30 seconds.
    ref.listen(
      adminSectionProvider,
      (_, _) => ref.read(workQueueProvider.notifier).refresh(),
    );
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < AppSpacing.tabletBreakpoint;
    final canExpand = width >= AppSpacing.desktopBreakpoint;
    final compact = !canExpand || collapsedPref;

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

    final Widget layout;
    if (isPhone) {
      layout = Scaffold(
        key: adminScaffoldKey,
        body: body,
        bottomNavigationBar: _BottomNav(
          current: current,
          onSelect: _select,
          onMore: _openMoreSheet,
        ),
      );
    } else {
      final scheme = context.colors;
      layout = Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: compact ? AppSpacing.railWidth : AppSpacing.sidebarWidth,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(right: BorderSide(color: scheme.outlineVariant)),
              ),
              // Lays out at the final width so labels never wrap mid-animation.
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: compact
                      ? AppSpacing.railWidth
                      : AppSpacing.sidebarWidth,
                  maxWidth: compact
                      ? AppSpacing.railWidth
                      : AppSpacing.sidebarWidth,
                  child: _Sidebar(
                    current: current,
                    compact: compact,
                    canToggle: canExpand,
                    onSelect: _select,
                    onSearch: _openPalette,
                    onLogout: _confirmLogout,
                  ),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _openPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openPalette,
      },
      child: Focus(autofocus: true, child: layout),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar (tablet & desktop)
// ---------------------------------------------------------------------------

class _Sidebar extends ConsumerWidget {
  final AdminSection current;
  final bool compact;
  final bool canToggle;
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onSearch;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.current,
    required this.compact,
    required this.canToggle,
    required this.onSelect,
    required this.onSearch,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(workQueueProvider).queue;
    final scheme = context.colors;
    final text = context.text;
    final padding = MediaQuery.paddingOf(context);

    final items = <Widget>[];
    for (final s in AdminSection.values) {
      if (s.group != null) {
        items.add(
          compact
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  child: Divider(),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 12, 6),
                  child: Text(
                    context.tr(s.group!).toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
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
        // Brand + collapse toggle
        SizedBox(
          height: 64 + padding.top,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 0 : 16,
              padding.top,
              compact ? 0 : 8,
              0,
            ),
            child: compact
                ? const Center(child: AppLogo(size: 34))
                : Row(
                    children: [
                      const AppLogo(size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(NavText.appName),
                              maxLines: 1,
                              style: text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              context.tr(NavText.tagline),
                              maxLines: 1,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canToggle)
                        IconButton(
                          tooltip: context.tr(NavText.collapseSidebar),
                          icon: const Icon(
                            Icons.keyboard_double_arrow_left_rounded,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(appSettingsProvider.notifier)
                              .toggleSidebar(),
                        ),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _SearchButton(compact: compact, onTap: onSearch),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: items,
          ),
        ),
        const Divider(),
        _SidebarFooter(
          compact: compact,
          canToggle: canToggle,
          onLogout: onLogout,
        ),
        SizedBox(height: padding.bottom),
      ],
    );
  }
}

class _SearchButton extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;
  const _SearchButton({required this.compact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final shortcut = _isApple ? '⌘K' : 'Ctrl K';
    if (compact) {
      return Tooltip(
        message: '${context.tr(NavText.jumpTo)}  $shortcut',
        child: IconButton(
          icon: const Icon(Icons.search_rounded, size: 21),
          onPressed: onTap,
        ),
      );
    }
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: SizedBox(
          height: 38,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                Icons.search_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr(NavText.jumpTo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  shortcut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  final bool compact;
  final bool canToggle;
  final VoidCallback onLogout;

  const _SidebarFooter({
    required this.compact,
    required this.canToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final scheme = context.colors;
    final text = context.text;
    final name = auth.username ?? context.tr(NavText.admin);
    final role = auth.role == null
        ? context.tr(NavText.administrator)
        : humanize(auth.role!);

    final menu = PopupMenuButton<VoidCallback>(
      tooltip: context.tr(NavText.account),
      position: PopupMenuPosition.over,
      offset: const Offset(0, -8),
      onSelected: (action) => action(),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                role,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: () => showAppSettings(context),
          child: _MenuRow(Icons.tune_rounded, ctx.tr(SettingsText.settings)),
        ),
        PopupMenuItem(
          value: onLogout,
          child: _MenuRow(
            Icons.logout_rounded,
            ctx.tr(NavText.signOut),
            color: scheme.error,
          ),
        ),
      ],
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: InitialAvatar(name: auth.username, radius: 16),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  InitialAvatar(name: auth.username, radius: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            if (canToggle)
              IconButton(
                tooltip: context.tr(NavText.expandSidebar),
                icon: const Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  size: 20,
                ),
                onPressed: () =>
                    ref.read(appSettingsProvider.notifier).toggleSidebar(),
              ),
            const ThemeModeButton(),
            const SizedBox(height: 4),
            menu,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const LanguageToggle(),
                const Spacer(),
                const ThemeModeButton(),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            clipBehavior: Clip.antiAlias,
            child: menu,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuRow(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? context.colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminSection section;
  final bool selected;
  final bool compact;
  final _Badge? badge;
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
    final scheme = context.colors;
    final status = context.status;
    final badge = this.badge;
    final label = context.tr(section.title);
    final (Color badgeBg, Color badgeFg) = badge?.urgent ?? false
        ? (scheme.primary, scheme.onPrimary)
        : (status.warningContainer, status.onWarningContainer);
    final icon = Icon(
      selected ? section.selectedIcon : section.icon,
      color: selected ? scheme.primary : scheme.onSurfaceVariant,
      size: 20,
    );
    final radius = BorderRadius.circular(AppSpacing.radiusSm);

    final tile = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 10, vertical: 1),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.09)
            : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 38,
            child: compact
                ? Center(
                    child: badge == null
                        ? icon
                        : Badge(
                            label: Text(_badgeText(badge.count)),
                            backgroundColor: badgeBg,
                            textColor: badgeFg,
                            child: icon,
                          ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 10),
                      icon,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? scheme.onSurface
                                : scheme.onSurface.withValues(alpha: 0.82),
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _badgeText(badge.count),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: badgeFg,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
          ),
        ),
      ),
    );

    final semantic = badge == null
        ? label
        : '$label, ${context.tr(_badgeMeaning(badge))}';
    return Semantics(
      selected: selected,
      button: true,
      label: semantic,
      excludeSemantics: true,
      child: compact
          ? Tooltip(
              message: badge == null
                  ? label
                  : '$label · ${context.tr(_badgeMeaning(badge))}',
              preferBelow: false,
              child: tile,
            )
          : tile,
    );
  }
}

// ---------------------------------------------------------------------------
// Phone: bottom navigation + "More" sheet
// ---------------------------------------------------------------------------

class _BottomNav extends ConsumerWidget {
  final AdminSection current;
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onMore;

  const _BottomNav({
    required this.current,
    required this.onSelect,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(workQueueProvider).queue;
    final scheme = context.colors;
    final primary = AdminSection.primary;
    final index = primary.indexOf(current);
    // Badges for sections behind "More" roll up onto the More tab.
    final hiddenWaiting = AdminSection.values
        .where((s) => !primary.contains(s))
        .map((s) => _navBadge(s, queue)?.count ?? 0)
        .fold<int>(0, (a, b) => a + b);

    Widget withBadge(Widget icon, _Badge? b) =>
        b == null ? icon : Badge(label: Text(_badgeText(b.count)), child: icon);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: NavigationBar(
        selectedIndex: index < 0 ? primary.length : index,
        onDestinationSelected: (i) =>
            i == primary.length ? onMore() : onSelect(primary[i]),
        destinations: [
          for (final s in primary)
            NavigationDestination(
              icon: withBadge(Icon(s.icon), _navBadge(s, queue)),
              selectedIcon: withBadge(
                Icon(s.selectedIcon),
                _navBadge(s, queue),
              ),
              label: context.tr(s.title),
            ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: hiddenWaiting > 0,
              label: Text(_badgeText(hiddenWaiting)),
              child: Icon(
                index < 0 ? current.selectedIcon : Icons.grid_view_outlined,
              ),
            ),
            label: index < 0
                ? context.tr(current.title)
                : context.tr(NavText.more),
            tooltip: context.tr(NavText.allSections),
          ),
        ],
      ),
    );
  }
}

class _MoreSheet extends ConsumerWidget {
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onSearch;
  final VoidCallback onLogout;

  const _MoreSheet({
    required this.onSelect,
    required this.onSearch,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final queue = ref.watch(workQueueProvider).queue;
    final current = ref.watch(adminSectionProvider);
    final scheme = context.colors;
    final text = context.text;

    // Sections grouped under their headers, in sidebar order.
    final groups = <(Tr?, List<AdminSection>)>[];
    for (final s in AdminSection.values) {
      if (s.group != null || groups.isEmpty) groups.add((s.group, []));
      groups.last.$2.add(s);
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // Account
          Row(
            children: [
              InitialAvatar(name: auth.username, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.username ?? context.tr(NavText.admin),
                      style: text.titleMedium,
                    ),
                    Text(
                      auth.role == null
                          ? context.tr(NavText.administrator)
                          : humanize(auth.role!),
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr(NavText.jumpTo),
                icon: const Icon(Icons.search_rounded),
                onPressed: onSearch,
              ),
            ],
          ),
          for (final (group, sections) in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text(
                context.tr(group ?? NavText.allSections).toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            _SectionGrid(
              sections: sections,
              current: current,
              queue: queue,
              onSelect: onSelect,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
            child: Text(
              context.tr(SettingsText.settings).toUpperCase(),
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const AppSettingsPanel(),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
            ),
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(context.tr(NavText.signOut)),
          ),
        ],
      ),
    );
  }
}

class _SectionGrid extends StatelessWidget {
  final List<AdminSection> sections;
  final AdminSection current;
  final WorkQueue? queue;
  final ValueChanged<AdminSection> onSelect;

  const _SectionGrid({
    required this.sections,
    required this.current,
    required this.queue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 8.0;
        final columns = c.maxWidth >= 520 ? 4 : 3;
        final tileWidth = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in sections)
              SizedBox(
                width: tileWidth,
                child: _SectionTile(
                  section: s,
                  selected: s == current,
                  badge: _navBadge(s, queue),
                  onTap: () => onSelect(s),
                  scheme: scheme,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionTile extends StatelessWidget {
  final AdminSection section;
  final bool selected;
  final _Badge? badge;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _SectionTile({
    required this.section,
    required this.selected,
    required this.badge,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? section.selectedIcon : section.icon,
      size: 22,
      color: selected ? scheme.primary : scheme.onSurfaceVariant,
    );
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: selected
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            children: [
              badge == null
                  ? icon
                  : Badge(label: Text(_badgeText(badge!.count)), child: icon),
              const SizedBox(height: 8),
              Text(
                context.tr(section.title),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
