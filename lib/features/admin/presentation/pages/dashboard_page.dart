import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static final _currency = NumberFormat.currency(
    symbol: '₭ ',
    decimalDigits: 0,
  );
  static final _number = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  void _goTo(AdminSection section) =>
      ref.read(adminSectionProvider.notifier).state = section;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final auth = ref.watch(authStateProvider);
    final stats = state.stats;

    // Refresh failures with data already on screen surface as a snackbar.
    ref.listen(dashboardProvider, (prev, next) {
      if (next.error != null &&
          next.stats != null &&
          prev?.error != next.error) {
        AppFeedback.error(context, next.error);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading
                ? null
                : () => ref.read(dashboardProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: state.isLoading && stats != null
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: switch ((state.isLoading && stats == null, state.error, stats)) {
        (true, _, _) => const AppLoadingView(message: 'Loading dashboard…'),
        (_, final String error, null) => AppErrorView(
          error: error,
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        (_, _, null) => const AppEmptyView(
          icon: Icons.space_dashboard_outlined,
          title: 'No data yet',
          message: 'Dashboard metrics will appear once shops start using UFin.',
        ),
        (_, _, final AdminDashboardStats s) => _buildDashboard(
          s,
          auth.username,
        ),
      },
    );
  }

  Widget _buildDashboard(AdminDashboardStats stats, String? username) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = context.status;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                '${_greeting()}${username == null ? '' : ', $username'}',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                "Here's what's happening across UFin today · "
                '${DateFormat('EEEE, d MMM y').format(DateTime.now())}',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (stats.expiringSoon > 0) ...[
                const SizedBox(height: AppSpacing.lg),
                _AttentionBanner(
                  message:
                      '${stats.expiringSoon} subscription${stats.expiringSoon == 1 ? '' : 's'} '
                      'will expire within 7 days.',
                  actionLabel: 'Review',
                  onAction: () => _goTo(AdminSection.subscriptions),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              // KPIs
              ResponsiveGrid(
                children: [
                  StatCard(
                    label: 'Total shops',
                    value: _number.format(stats.totalShops),
                    caption: '${_number.format(stats.activeShops)} active',
                    icon: Icons.storefront_rounded,
                    color: scheme.primary,
                    onTap: () => _goTo(AdminSection.shops),
                  ),
                  StatCard(
                    label: 'Total users',
                    value: _number.format(stats.totalUsers),
                    caption: '${_number.format(stats.activeUsers)} active',
                    icon: Icons.people_rounded,
                    color: status.success,
                    onTap: () => _goTo(AdminSection.users),
                  ),
                  StatCard(
                    label: 'Subscriptions',
                    value: _number.format(stats.totalSubscriptions),
                    caption:
                        '${_number.format(stats.activeSubscriptions)} active',
                    icon: Icons.card_membership_rounded,
                    color: Colors.indigo,
                    onTap: () => _goTo(AdminSection.subscriptions),
                  ),
                  StatCard(
                    label: 'Monthly revenue',
                    value: _currency.format(stats.totalRevenueThisMonth),
                    caption:
                        '${_number.format(stats.totalPaymentsThisMonth)} payments',
                    icon: Icons.payments_rounded,
                    color: status.warning,
                    onTap: () => _goTo(AdminSection.revenue),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Detail panels
              LayoutBuilder(
                builder: (context, c) {
                  final panels = [
                    _shopsPanel(stats),
                    _subscriptionsPanel(stats),
                    _revenuePanel(stats),
                    if (stats.subscriptionsByPlan.isNotEmpty)
                      _plansPanel(stats),
                  ];
                  if (c.maxWidth < 760) {
                    return Column(
                      children: [
                        for (final p in panels) ...[
                          p,
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ],
                    );
                  }
                  // Two-column masonry on wide screens.
                  final left = <Widget>[];
                  final right = <Widget>[];
                  for (var i = 0; i < panels.length; i++) {
                    (i.isEven ? left : right).addAll([
                      panels[i],
                      const SizedBox(height: AppSpacing.lg),
                    ]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(children: left)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: Column(children: right)),
                    ],
                  );
                },
              ),

              if (stats.recentActivities.isNotEmpty)
                SectionCard(
                  title: 'Recent activity',
                  icon: Icons.history_rounded,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (final (i, a)
                          in stats.recentActivities.take(10).indexed) ...[
                        if (i > 0) const Divider(indent: 64),
                        _ActivityTile(activity: a),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shopsPanel(AdminDashboardStats s) {
    final status = context.status;
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Shops',
      icon: Icons.storefront_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.shops),
        child: const Text('View all'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniStat(label: 'Today', value: _number.format(s.newShopsToday)),
              _MiniStat(
                label: 'This week',
                value: _number.format(s.newShopsThisWeek),
              ),
              _MiniStat(
                label: 'This month',
                value: _number.format(s.newShopsThisMonth),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DistributionBar(
            segments: [
              ('Active', s.activeShops, status.success),
              ('Suspended', s.suspendedShops, scheme.error),
              (
                'Other',
                (s.totalShops - s.activeShops - s.suspendedShops).clamp(
                  0,
                  s.totalShops,
                ),
                status.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subscriptionsPanel(AdminDashboardStats s) {
    final status = context.status;
    return SectionCard(
      title: 'Subscriptions',
      icon: Icons.card_membership_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.subscriptions),
        child: const Text('View all'),
      ),
      child: _DistributionBar(
        segments: [
          ('Active', s.activeSubscriptions, status.success),
          ('Trial', s.trialSubscriptions, status.info),
          ('Expiring soon', s.expiringSoon, status.warning),
          ('Expired', s.expiredSubscriptions, status.neutral),
        ],
      ),
    );
  }

  Widget _revenuePanel(AdminDashboardStats s) {
    return SectionCard(
      title: 'Revenue',
      icon: Icons.account_balance_wallet_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.revenue),
        child: const Text('Report'),
      ),
      child: Column(
        children: [
          InfoRow(
            label: 'This month',
            value: _currency.format(s.totalRevenueThisMonth),
            valueColor: context.status.success,
          ),
          InfoRow(
            label: 'This year',
            value: _currency.format(s.totalRevenueThisYear),
          ),
          InfoRow(
            label: 'Payments this month',
            value: _number.format(s.totalPaymentsThisMonth),
          ),
        ],
      ),
    );
  }

  Widget _plansPanel(AdminDashboardStats s) {
    final entries = s.subscriptionsByPlan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Subscriptions by plan',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        _number.format(e.value),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: total == 0 ? 0 : e.value / total,
                      backgroundColor: scheme.surfaceContainerHigh,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AttentionBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _AttentionBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: status.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: status.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: status.onWarningContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: status.onWarningContainer,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'New ${label.toLowerCase()}',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Stacked horizontal bar with a legend underneath.
class _DistributionBar extends StatelessWidget {
  final List<(String, int, Color)> segments;
  const _DistributionBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = segments.fold<int>(0, (s, e) => s + e.$2);
    final number = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 10,
            child: total == 0
                ? ColoredBox(color: scheme.surfaceContainerHigh)
                : Row(
                    children: [
                      for (final (_, v, c) in segments)
                        if (v > 0)
                          Expanded(
                            flex: v,
                            child: Container(
                              color: c,
                              margin: const EdgeInsets.only(right: 2),
                            ),
                          ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (label, v, c) in segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(label)),
                Text(
                  number.format(v),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    total == 0 ? '—' : '${(v * 100 / total).round()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color) = switch (activity.type.toUpperCase()) {
      'SHOP_CREATED' => (Icons.add_business_rounded, status.success),
      'SUBSCRIPTION_UPGRADED' => (Icons.upgrade_rounded, status.info),
      'PAYMENT_RECEIVED' => (Icons.payments_rounded, status.warning),
      _ => (Icons.info_outline_rounded, status.neutral),
    };

    return ListTile(
      leading: IconBadge(icon: icon, color: color, size: 36),
      title: Text(
        activity.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: activity.shopName != null ? Text(activity.shopName!) : null,
      trailing: Text(
        _relative(activity.timestamp),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  static String _relative(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return timestamp;
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(date);
  }
}
