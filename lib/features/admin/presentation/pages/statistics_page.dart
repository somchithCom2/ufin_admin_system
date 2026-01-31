import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/statistics_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expiringDaysFilter = 30;

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(subscriptionStatsProvider.notifier).refresh();
              ref.read(expiringSubscriptionsProvider.notifier).refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Expiring', icon: Icon(Icons.timer)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildExpiringTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final state = ref.watch(subscriptionStatsProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(subscriptionStatsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = state.stats;
    if (stats == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  stats.totalSubscriptions.toString(),
                  Icons.subscriptions,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Active',
                  stats.activeSubscriptions.toString(),
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
                child: _buildSummaryCard(
                  'Expired',
                  stats.expiredSubscriptions.toString(),
                  Icons.timer_off,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Cancelled',
                  stats.cancelledSubscriptions.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Trial',
                  stats.trialSubscriptions.toString(),
                  Icons.stars,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expiring Soon',
                  stats.expiringSoon.toString(),
                  Icons.warning,
                  Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue section
          _buildSectionTitle('Revenue'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRevenueItem(
                      'Total Revenue',
                      stats.totalRevenue,
                      Colors.green[700]!,
                    ),
                    _buildRevenueItem(
                      'MRR',
                      stats.monthlyRecurringRevenue,
                      Colors.blue[700]!,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRevenueItem(
                      'ARPU',
                      stats.averageRevenuePerUser,
                      Colors.purple[700]!,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // By Plan
          if (stats.byPlan.isNotEmpty) ...[
            _buildSectionTitle('By Plan'),
            const SizedBox(height: 12),
            ...stats.byPlan.entries.map(
              (entry) => _buildPlanBar(
                entry.key,
                entry.value,
                stats.totalSubscriptions,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // By Status
          if (stats.byStatus.isNotEmpty) ...[
            _buildSectionTitle('By Status'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.byStatus.entries
                  .map((entry) => _buildStatusChip(entry.key, entry.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpiringTab() {
    final state = ref.watch(expiringSubscriptionsProvider);

    return Column(
      children: [
        // Days filter
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[50],
          child: Row(
            children: [
              const Text('Show expiring within: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('7 days'),
                selected: _expiringDaysFilter == 7,
                onSelected: (_) {
                  setState(() => _expiringDaysFilter = 7);
                  ref
                      .read(expiringSubscriptionsProvider.notifier)
                      .setDaysFilter(7);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('14 days'),
                selected: _expiringDaysFilter == 14,
                onSelected: (_) {
                  setState(() => _expiringDaysFilter = 14);
                  ref
                      .read(expiringSubscriptionsProvider.notifier)
                      .setDaysFilter(14);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('30 days'),
                selected: _expiringDaysFilter == 30,
                onSelected: (_) {
                  setState(() => _expiringDaysFilter = 30);
                  ref
                      .read(expiringSubscriptionsProvider.notifier)
                      .setDaysFilter(30);
                },
              ),
            ],
          ),
        ),

        // Summary
        if (!state.isLoading && state.subscriptions.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${state.subscriptions.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Total', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${state.urgentCount}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    Text('≤7 days', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${state.criticalCount}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    Text('≤3 days', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),

        // List
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
                      ElevatedButton(
                        onPressed: () => ref
                            .read(expiringSubscriptionsProvider.notifier)
                            .refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.subscriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 16),
                      const Text('No subscriptions expiring soon!'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = state.subscriptions[index];
                    return _buildExpiringCard(sub);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
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

  Widget _buildRevenueItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          NumberFormat.currency(symbol: '₭', decimalDigits: 0).format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildPlanBar(String planName, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('$count (${(percentage * 100).toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, int count) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$status: $count',
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringCard(sub) {
    final urgencyColor = sub.isCritical
        ? Colors.red
        : sub.isUrgent
        ? Colors.orange
        : Colors.amber;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${sub.daysUntilExpiry}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: urgencyColor,
                ),
              ),
              Text('days', style: TextStyle(fontSize: 10, color: urgencyColor)),
            ],
          ),
        ),
        title: Text(
          sub.shopName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub.planName),
            Text(
              'Expires: ${DateFormat('MMM d, yyyy').format(sub.endDate)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          // Navigate to subscription detail or show action sheet
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'trial':
        return Colors.purple;
      case 'suspended':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
