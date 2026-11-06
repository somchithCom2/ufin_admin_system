import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/work_queue_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/work_queue_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static final _number = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  /// Reloads the figures and the work queue together.
  Future<void> _refreshAll() => Future.wait([
    ref.read(dashboardProvider.notifier).loadDashboard(),
    ref.read(workQueueProvider.notifier).refresh(force: true),
  ]);

  void _goTo(AdminSection section) =>
      ref.read(adminSectionProvider.notifier).state = section;

  Tr _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return DashText.goodMorning;
    if (h < 18) return DashText.goodAfternoon;
    return DashText.goodEvening;
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
        title: Text(context.tr(NavText.dashboard)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading ? null : _refreshAll,
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
        (true, _, _) => AppLoadingView(message: context.tr(DashText.loading)),
        (_, final String error, null) => AppErrorView(
          error: error,
          onRetry: _refreshAll,
        ),
        (_, _, null) => AppEmptyView(
          icon: Icons.space_dashboard_outlined,
          title: context.tr(DashText.noData),
          message: context.tr(DashText.noDataHint),
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

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                '${context.tr(_greeting())}${username == null ? '' : ', $username'}',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  DashText.overview(
                    DateFormat(
                      'EEEE, d MMM y',
                      context.localeName,
                    ).format(DateTime.now()),
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // What to act on comes before the figures.
              const WorkQueueCard(),
              const SizedBox(height: AppSpacing.lg),

              // KPIs
              ResponsiveGrid(
                children: [
                  StatCard(
                    label: context.tr(DashText.totalShops),
                    value: _number.format(stats.totalShops),
                    caption: context.tr(
                      DashText.nActive(_number.format(stats.activeShops)),
                    ),
                    icon: Icons.storefront_rounded,
                    onTap: () => _goTo(AdminSection.shops),
                  ),
                  StatCard(
                    label: context.tr(DashText.totalUsers),
                    value: _number.format(stats.totalUsers),
                    caption: context.tr(
                      DashText.nActive(_number.format(stats.activeUsers)),
                    ),
                    icon: Icons.people_rounded,
                    onTap: () => _goTo(AdminSection.users),
                  ),
                  StatCard(
                    label: context.tr(NavText.subscriptions),
                    value: _number.format(stats.totalSubscriptions),
                    caption: context.tr(
                      DashText.nActive(
                        _number.format(stats.activeSubscriptions),
                      ),
                    ),
                    icon: Icons.card_membership_rounded,
                    onTap: () => _goTo(AdminSection.subscriptions),
                  ),
                  StatCard(
                    label: context.tr(DashText.monthlyRevenue),
                    value: _primaryAmount(stats.revenueThisMonthByCurrency),
                    // Other currencies are listed, never added to the kip.
                    caption: stats.revenueThisMonthByCurrency.length > 1
                        ? '+ ${stats.revenueThisMonthByCurrency.keys.skip(1).join(', ')}'
                        : context.tr(
                            DashText.nPayments(
                              _number.format(stats.totalPaymentsThisMonth),
                            ),
                          ),
                    icon: Icons.payments_rounded,
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
                  title: context.tr(DashText.recentActivity),
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
      title: context.tr(NavText.shops),
      icon: Icons.storefront_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.shops),
        child: Text(context.tr(CommonText.viewAll)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniStat(
                label: context.tr(DashText.newToday),
                value: _number.format(s.newShopsToday),
              ),
              _MiniStat(
                label: context.tr(DashText.newThisWeek),
                value: _number.format(s.newShopsThisWeek),
              ),
              _MiniStat(
                label: context.tr(DashText.newThisMonth),
                value: _number.format(s.newShopsThisMonth),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DistributionBar(
            segments: [
              (
                StatusText.lookup('active')!.of(context),
                s.activeShops,
                status.success,
              ),
              (
                StatusText.lookup('suspended')!.of(context),
                s.suspendedShops,
                scheme.error,
              ),
              (
                context.tr(DashText.other),
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
      title: context.tr(NavText.subscriptions),
      icon: Icons.card_membership_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.subscriptions),
        child: Text(context.tr(CommonText.viewAll)),
      ),
      child: _DistributionBar(
        segments: [
          (_status('active'), s.activeSubscriptions, status.success),
          (_status('trial'), s.trialSubscriptions, status.info),
          (_status('expiring_soon'), s.expiringSoon, status.warning),
          (_status('expired'), s.expiredSubscriptions, status.neutral),
        ],
      ),
    );
  }

  Widget _revenuePanel(AdminDashboardStats s) {
    return SectionCard(
      title: context.tr(DashText.revenue),
      icon: Icons.account_balance_wallet_outlined,
      trailing: TextButton(
        onPressed: () => _goTo(AdminSection.revenue),
        child: Text(context.tr(CommonText.report)),
      ),
      child: Column(
        children: [
          ..._amountRows(
            context.tr(CommonText.thisMonth),
            s.revenueThisMonthByCurrency,
            valueColor: context.status.success,
          ),
          ..._amountRows(
            context.tr(CommonText.thisYear),
            s.revenueThisYearByCurrency,
          ),
          InfoRow(
            label: context.tr(DashText.paymentsThisMonth),
            value: _number.format(s.totalPaymentsThisMonth),
          ),
        ],
      ),
    );
  }

  String _status(String raw) => StatusText.lookup(raw)!.of(context);

  /// The first currency's amount (LAK when present), or ₭ 0 with no revenue.
  String _primaryAmount(Map<String, double> amounts) => amounts.isEmpty
      ? MoneyFormat.format(0, 'LAK')
      : MoneyFormat.format(amounts.values.first, amounts.keys.first);

  /// One row per currency; a single LAK row when there is no revenue yet.
  List<Widget> _amountRows(
    String label,
    Map<String, double> amounts, {
    Color? valueColor,
  }) {
    final entries = amounts.isEmpty
        ? const [MapEntry('LAK', 0.0)]
        : amounts.entries.toList();
    return [
      for (final e in entries)
        InfoRow(
          label: entries.length > 1 ? '$label · ${e.key}' : label,
          value: MoneyFormat.format(e.value, e.key),
          valueColor: valueColor,
        ),
    ];
  }

  Widget _plansPanel(AdminDashboardStats s) {
    final entries = s.subscriptionsByPlan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: context.tr(DashText.byPlan),
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
            label,
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
        _relative(context, activity.timestamp),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  static String _relative(BuildContext context, String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return timestamp;
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.isNegative || diff.inMinutes < 1) {
      return context.tr(CommonText.justNow);
    }
    if (diff.inMinutes < 60) {
      return context.tr(CommonText.minutesAgo(diff.inMinutes));
    }
    if (diff.inHours < 24) return context.tr(CommonText.hoursAgo(diff.inHours));
    if (diff.inDays < 7) return context.tr(CommonText.daysAgo(diff.inDays));
    return DateFormat('d MMM', context.localeName).format(date);
  }
}
