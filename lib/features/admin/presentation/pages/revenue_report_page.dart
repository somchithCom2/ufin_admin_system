import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/statistics_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

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
    // Default to last 30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
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

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Revenue Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(revenueReportProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),

          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(state.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(revenueReportProvider.notifier)
                              .refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : state.report == null
                ? const Center(child: Text('No data available'))
                : _buildReport(state),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              // Date range picker
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _dateRange != null
                              ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                              : 'Select dates',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Group by: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Day'),
                selected: _groupBy == 'day',
                onSelected: (_) => _setGroupBy('day'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Week'),
                selected: _groupBy == 'week',
                onSelected: (_) => _setGroupBy('week'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Month'),
                selected: _groupBy == 'month',
                onSelected: (_) => _setGroupBy('month'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReport(RevenueReportState state) {
    final report = state.report!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Revenue Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    symbol: '₭',
                    decimalDigits: 0,
                  ).format(report.totalRevenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniStat(
                      'Subscriptions',
                      report.subscriptionRevenue,
                      Colors.white70,
                    ),
                    const SizedBox(width: 24),
                    _buildMiniStat(
                      'Other',
                      report.otherRevenue,
                      Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Transaction Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Transactions',
                  report.totalTransactions.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  '${report.successRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Successful',
                  report.successfulTransactions.toString(),
                  Icons.done_all,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Failed',
                  report.failedTransactions.toString(),
                  Icons.error_outline,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildStatCard(
            'Average Transaction',
            NumberFormat.currency(
              symbol: '₭',
              decimalDigits: 0,
            ).format(report.averageTransactionValue),
            Icons.analytics,
            Colors.purple,
          ),

          const SizedBox(height: 24),

          // Revenue by Period
          if (report.revenueByPeriod.isNotEmpty) ...[
            _buildSectionTitle('Revenue by Period'),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSimpleBarChart(report.revenueByPeriod),
            ),
          ],

          const SizedBox(height: 24),

          // Revenue by Plan
          if (report.revenueByPlan.isNotEmpty) ...[
            _buildSectionTitle('Revenue by Plan'),
            const SizedBox(height: 12),
            ...report.revenueByPlan.map(_buildPlanRevenueCard),
          ],

          const SizedBox(height: 24),

          // Revenue by Payment Method
          if (report.revenueByPaymentMethod.isNotEmpty) ...[
            _buildSectionTitle('Revenue by Payment Method'),
            const SizedBox(height: 12),
            ...report.revenueByPaymentMethod.map(_buildPaymentMethodCard),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          NumberFormat.currency(symbol: '₭', decimalDigits: 0).format(value),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSimpleBarChart(List<dynamic> data) {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data
        .map((e) => e.revenue as double)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final heightRatio = maxValue > 0 ? (item.revenue / maxValue) : 0.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: (140 * heightRatio).toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPeriodLabel(item.period),
                  style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanRevenueCard(dynamic plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.planName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${plan.subscriptionCount} subscriptions',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  symbol: '₭',
                  decimalDigits: 0,
                ).format(plan.revenue),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text(
                '${plan.percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(dynamic method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(method.paymentMethod),
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.paymentMethodDisplay,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${method.transactionCount} transactions',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  symbol: '₭',
                  decimalDigits: 0,
                ).format(method.revenue),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text(
                '${method.percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPeriodLabel(String period) {
    try {
      final date = DateTime.parse(period);
      return DateFormat('M/d').format(date);
    } catch (_) {
      return period.length > 5 ? period.substring(0, 5) : period;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'qr_code':
        return Icons.qr_code;
      case 'card':
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.payment;
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
