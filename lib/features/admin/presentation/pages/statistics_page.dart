import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/statistics_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expiringDaysFilter = 30;

  /// Shop whose subscription is being fetched to open its detail page.
  int? _openingShopId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionStatsProvider.notifier).loadStatistics();
      ref
          .read(expiringSubscriptionsProvider.notifier)
          .loadExpiringSubscriptions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Statistics'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(subscriptionStatsProvider.notifier).refresh();
              ref.read(expiringSubscriptionsProvider.notifier).refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Expiring'),
          ],
        ),
      ),
      body: ContentWidth(
        child: TabBarView(
          controller: _tabController,
          children: [_buildOverviewTab(), _buildExpiringTab()],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final state = ref.watch(subscriptionStatsProvider);
    final notifier = ref.read(subscriptionStatsProvider.notifier);

    if (state.isLoading) {
      return const AppLoadingView();
    }

    if (state.error != null) {
      return AppErrorView(error: state.error, onRetry: notifier.refresh);
    }

    final stats = state.stats;
    if (stats == null) {
      return const AppEmptyView(
        icon: Icons.insights_outlined,
        title: 'No data available',
        message: 'There is nothing to show for this period.',
      );
    }
    final currencies = _revenueCurrencies(stats);
    final status = context.status;

    return RefreshIndicator(
      onRefresh: notifier.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ResponsiveGrid(
            minItemWidth: 180,
            children: [
              StatCard(
                label: 'Total',
                value: stats.totalSubscriptions.toString(),
                icon: Icons.card_membership_rounded,
              ),
              StatCard(
                label: 'Active',
                value: stats.activeSubscriptions.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: status.success,
              ),
              StatCard(
                label: 'Trial',
                value: stats.trialSubscriptions.toString(),
                icon: Icons.hourglass_top_rounded,
                color: status.info,
              ),
              StatCard(
                label: 'Expiring soon',
                value: stats.expiringSoon.toString(),
                caption: 'Within 30 days',
                icon: Icons.schedule_rounded,
                color: stats.expiringSoon > 0 ? status.warning : null,
                onTap: () => _tabController.animateTo(1),
              ),
              StatCard(
                label: 'Expired',
                value: stats.expiredSubscriptions.toString(),
                icon: Icons.timer_off_outlined,
              ),
              StatCard(
                label: 'Cancelled',
                value: stats.cancelledSubscriptions.toString(),
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Revenue',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // One block per currency; LAK first.
                for (final (i, currency) in currencies.indexed) ...[
                  if (i > 0) const Divider(height: AppSpacing.xl),
                  if (currencies.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(currency, style: context.text.titleSmall),
                    ),
                  Wrap(
                    spacing: AppSpacing.xxl,
                    runSpacing: AppSpacing.md,
                    children: [
                      _buildRevenueItem(
                        'Total revenue',
                        stats.totalRevenue[currency] ?? 0,
                        currency,
                      ),
                      _buildRevenueItem(
                        'Monthly recurring (MRR)',
                        stats.monthlyRecurringRevenue[currency] ?? 0,
                        currency,
                      ),
                      _buildRevenueItem(
                        'Average per paying shop (ARPU)',
                        stats.averageRevenuePerUser[currency] ?? 0,
                        currency,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (stats.byPlan.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'Active and trial by plan',
              child: Column(
                children: [
                  for (final entry in stats.byPlan.entries)
                    _buildPlanBar(
                      entry.key,
                      entry.value,
                      stats.totalSubscriptions,
                    ),
                ],
              ),
            ),
          ],
          if (stats.byStatus.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: 'By status',
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final entry in stats.byStatus.entries)
                    StatusBadge(
                      label: '${humanize(entry.key)} · ${entry.value}',
                      tone: StatusTone.fromStatus(entry.key),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildExpiringTab() {
    final state = ref.watch(expiringSubscriptionsProvider);
    final notifier = ref.read(expiringSubscriptionsProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 14, label: Text('14 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_expiringDaysFilter},
                onSelectionChanged: (s) {
                  setState(() => _expiringDaysFilter = s.first);
                  notifier.setDaysFilter(s.first);
                },
              ),
              if (!state.isLoading && state.subscriptions.isNotEmpty)
                Text(
                  '${state.subscriptions.length} expiring · '
                  '${state.urgentCount} within 7 days · '
                  '${state.criticalCount} within 3 days',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: state.isLoading
              ? const AppLoadingView()
              : state.error != null
              ? AppErrorView(error: state.error, onRetry: notifier.refresh)
              : state.subscriptions.isEmpty
              ? AppEmptyView(
                  icon: Icons.event_available_outlined,
                  title: 'Nothing expiring',
                  message:
                      'No subscription expires in the next $_expiringDaysFilter days.',
                )
              : RefreshIndicator(
                  onRefresh: notifier.loadExpiringSubscriptions,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: state.subscriptions.length,
                    separatorBuilder: (_, _) => const Divider(indent: 72),
                    itemBuilder: (context, index) =>
                        _buildExpiringTile(state.subscriptions[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRevenueItem(String label, double value, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MoneyFormat.format(value, currency),
          style: context.text.titleLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Every currency with revenue or recurring revenue; LAK alone when none.
  List<String> _revenueCurrencies(AdminSubscriptionStats stats) {
    final codes = MoneyFormat.ordered([
      ...stats.totalRevenue.keys,
      ...stats.monthlyRecurringRevenue.keys,
    ]);
    return codes.isEmpty ? const ['LAK'] : codes;
  }

  Widget _buildPlanBar(String planName, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(humanize(planName), style: context.text.bodyMedium),
              Text(
                '$count · ${(percentage * 100).toStringAsFixed(1)}%',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringTile(ExpiringSubscription sub) {
    final urgency = sub.isCritical
        ? context.colors.error
        : sub.isUrgent
        ? context.status.warning
        : context.colors.onSurfaceVariant;
    final opening = _openingShopId == sub.shopId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: SizedBox(
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${sub.daysUntilExpiry}',
              style: context.text.titleMedium?.copyWith(color: urgency),
            ),
            Text(
              sub.daysUntilExpiry == 1 ? 'day' : 'days',
              style: context.text.labelSmall?.copyWith(color: urgency),
            ),
          ],
        ),
      ),
      title: Text(sub.shopName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${sub.planName} · expires ${DateFormat('d MMM y').format(sub.endDate)}',
      ),
      trailing: opening
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: _openingShopId == null ? () => _openSubscription(sub) : null,
    );
  }

  /// Loads the shop's full subscription and opens its detail page, where it
  /// can be extended or renewed.
  Future<void> _openSubscription(ExpiringSubscription sub) async {
    setState(() => _openingShopId = sub.shopId);
    try {
      final subscription = await ref
          .read(adminRepositoryProvider)
          .getSubscriptionByShop(sub.shopId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubscriptionDetailPage(subscription: subscription),
        ),
      );
      if (mounted) {
        ref.read(expiringSubscriptionsProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) AppFeedback.error(context, e);
    } finally {
      if (mounted) setState(() => _openingShopId = null);
    }
  }
}
