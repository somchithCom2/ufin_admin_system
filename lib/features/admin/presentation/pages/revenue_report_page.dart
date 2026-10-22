import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/admin_revenue_report.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/statistics_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class RevenueReportPage extends ConsumerStatefulWidget {
  const RevenueReportPage({super.key});

  @override
  ConsumerState<RevenueReportPage> createState() => _RevenueReportPageState();
}

class _RevenueReportPageState extends ConsumerState<RevenueReportPage> {
  DateTimeRange? _dateRange;
  String _groupBy = 'day';

  @override
  void initState() {
    super.initState();
    // Default to the last 30 whole days, as the date range picker gives them:
    // the backend counts any time of day sent with a date
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day - 30),
      end: DateTime(now.year, now.month, now.day),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(revenueReportProvider.notifier)
          .loadRevenueReport(
            startDate: _dateRange!.start,
            endDate: _dateRange!.end,
            groupBy: _groupBy,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(revenueReportProvider);
    final notifier = ref.read(revenueReportProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Revenue Report'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading ? null : notifier.refresh,
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            _buildFilters(state),
            const Divider(),
            Expanded(
              child: state.isLoading
                  ? const AppLoadingView()
                  : state.error != null
                  ? AppErrorView(error: state.error, onRetry: notifier.refresh)
                  : state.report == null
                  ? const AppEmptyView(
                      icon: Icons.insights_outlined,
                      title: 'No data available',
                      message: 'There is nothing to show for this period.',
                    )
                  : RefreshIndicator(
                      onRefresh: notifier.loadRevenueReport,
                      child: _buildReport(state.report!),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// The currency the loaded report's amounts are in.
  String get _currency =>
      ref.read(revenueReportProvider).report?.currency ?? 'LAK';

  String _money(double value) => MoneyFormat.format(value, _currency);

  Widget _buildFilters(RevenueReportState state) {
    final currencies = state.report?.availableCurrencies ?? const <String>[];
    final range = _dateRange;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range_rounded, size: 18),
            label: Text(
              range == null
                  ? 'Select dates'
                  : '${DateFormat('d MMM y').format(range.start)} – '
                        '${DateFormat('d MMM y').format(range.end)}',
            ),
          ),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'day', label: Text('Day')),
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_groupBy},
            onSelectionChanged: (s) => _setGroupBy(s.first),
          ),
          // Payments in different currencies are reported apart, one at a time.
          if (currencies.length > 1)
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final code in currencies)
                  ButtonSegment(value: code, label: Text(code)),
              ],
              selected: {state.currency},
              onSelectionChanged: (s) =>
                  ref.read(revenueReportProvider.notifier).setCurrency(s.first),
            ),
        ],
      ),
    );
  }

  Widget _buildReport(AdminRevenueReport report) {
    final textTheme = context.text;
    final muted = context.colors.onSurfaceVariant;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total revenue · ${report.currency}',
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _money(report.totalRevenue),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _miniStat('Subscriptions', report.subscriptionRevenue),
                    _miniStat('Other', report.otherRevenue),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ResponsiveGrid(
          children: [
            StatCard(
              label: 'Transactions',
              value: report.totalTransactions.toString(),
              icon: Icons.receipt_long_rounded,
            ),
            StatCard(
              label: 'Success rate',
              value: '${report.successRate.toStringAsFixed(1)}%',
              caption: '${report.successfulTransactions} successful',
              icon: Icons.check_circle_outline_rounded,
              color: context.status.success,
            ),
            StatCard(
              label: 'Failed',
              value: report.failedTransactions.toString(),
              icon: Icons.error_outline_rounded,
              color: report.failedTransactions > 0
                  ? context.colors.error
                  : null,
            ),
            StatCard(
              label: 'Average transaction',
              value: _money(report.averageTransactionValue),
              icon: Icons.functions_rounded,
            ),
          ],
        ),
        if (report.revenueByPeriod.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Revenue by period',
            child: SizedBox(
              height: 180,
              child: _buildBarChart(report.revenueByPeriod),
            ),
          ),
        ],
        if (report.revenueByPlan.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Revenue by current plan',
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, plan) in report.revenueByPlan.indexed) ...[
                  if (i > 0) const Divider(),
                  _breakdownRow(
                    title: plan.planName,
                    subtitle: '${plan.subscriptionCount} payments',
                    amount: plan.revenue,
                    percentage: plan.percentage,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (report.revenueByPaymentMethod.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Revenue by payment method',
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, method)
                    in report.revenueByPaymentMethod.indexed) ...[
                  if (i > 0) const Divider(),
                  _breakdownRow(
                    icon: _getPaymentMethodIcon(method.paymentMethod),
                    title: method.paymentMethodDisplay,
                    subtitle: '${method.transactionCount} transactions',
                    amount: method.revenue,
                    percentage: method.percentage,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _miniStat(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _money(value),
          style: context.text.titleMedium?.copyWith(
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

  /// One line of a breakdown: name and count on the left, amount and share
  /// on the right, with a thin bar showing the share.
  Widget _breakdownRow({
    IconData? icon,
    required String title,
    required String subtitle,
    required double amount,
    required double percentage,
  }) {
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: muted),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(amount),
                    style: context.text.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: context.text.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<RevenueByPeriod> data) {
    final maxValue = data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    // Label every bar only while they fit; otherwise every nth one.
    final labelEvery = (data.length / 10).ceil().clamp(1, data.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barArea = constraints.maxHeight - 20;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, item) in data.indexed)
              Expanded(
                child: Tooltip(
                  message:
                      '${_formatPeriodLabel(item.period)}: ${_money(item.revenue)}'
                      ' · ${item.transactionCount} transactions',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: maxValue > 0
                              ? (barArea * item.revenue / maxValue).clamp(
                                  item.revenue > 0 ? 2.0 : 0.0,
                                  barArea,
                                )
                              : 0,
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: i % labelEvery == 0
                              ? Text(
                                  _formatPeriodLabel(item.period),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: context.text.labelSmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatPeriodLabel(String period) {
    try {
      final date = DateTime.parse(period);
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return period;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'bank_transfer':
        return Icons.account_balance_outlined;
      case 'qr_code':
        return Icons.qr_code_rounded;
      case 'card':
      case 'credit_card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      ref
          .read(revenueReportProvider.notifier)
          .loadRevenueReport(startDate: picked.start, endDate: picked.end);
    }
  }

  void _setGroupBy(String groupBy) {
    setState(() => _groupBy = groupBy);
    ref.read(revenueReportProvider.notifier).setGroupBy(groupBy);
  }
}
