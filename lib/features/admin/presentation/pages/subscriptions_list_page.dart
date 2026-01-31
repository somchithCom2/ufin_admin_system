import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_history_page.dart';

class SubscriptionsListPage extends ConsumerStatefulWidget {
  const SubscriptionsListPage({super.key});

  @override
  ConsumerState<SubscriptionsListPage> createState() =>
      _SubscriptionsListPageState();
}

class _SubscriptionsListPageState extends ConsumerState<SubscriptionsListPage> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionsProvider.notifier).loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsState = ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'All History',
            onPressed: () => _navigateToAllHistory(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(subscriptionsProvider.notifier).loadSubscriptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Trial', 'trial'),
                _buildFilterChip('Expired', 'expired'),
                _buildFilterChip('Expiring Soon', 'expiring'),
              ],
            ),
          ),
          // Subscription List
          Expanded(
            child: subscriptionsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : subscriptionsState.error != null
                ? _buildErrorView(subscriptionsState.error!)
                : subscriptionsState.subscriptions.isEmpty
                ? _buildEmptyView()
                : _buildSubscriptionList(subscriptionsState.subscriptions),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _statusFilter = selected ? status : null);
          ref
              .read(subscriptionsProvider.notifier)
              .loadSubscriptions(status: _statusFilter);
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load subscriptions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(subscriptionsProvider.notifier).loadSubscriptions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No subscriptions found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_statusFilter != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _statusFilter = null);
                ref.read(subscriptionsProvider.notifier).loadSubscriptions();
              },
              child: const Text('Clear filter'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionList(List<AdminSubscription> subscriptions) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(subscriptionsProvider.notifier)
            .loadSubscriptions(status: _statusFilter);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return _buildSubscriptionCard(subscription);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(AdminSubscription subscription) {
    final daysLeft =
        subscription.expiresAt?.difference(DateTime.now()).inDays ?? 0;
    final isExpiringSoon = daysLeft <= 7 && daysLeft > 0;
    final isExpired = daysLeft < 0;
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(subscription),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.planName ?? 'No Plan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(subscription.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Price',
                      currencyFormat.format(subscription.pricePaid),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.people,
                      'Employees',
                      '${subscription.currentEmployees}/${subscription.maxEmployees == 0 ? '∞' : subscription.maxEmployees}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.inventory_2,
                      'Products',
                      '${subscription.currentProducts}/${subscription.maxProducts == 0 ? '∞' : subscription.maxProducts}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Expiry Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.red.shade50
                      : isExpiringSoon
                      ? Colors.orange.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpired
                          ? Icons.error
                          : isExpiringSoon
                          ? Icons.warning_amber
                          : Icons.calendar_today,
                      size: 16,
                      color: isExpired
                          ? Colors.red
                          : isExpiringSoon
                          ? Colors.orange
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpired
                          ? 'Expired ${-daysLeft} days ago'
                          : isExpiringSoon
                          ? 'Expires in $daysLeft days'
                          : 'Expires: ${DateFormat('MMM d, yyyy').format(subscription.expiresAt ?? DateTime.now())}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange.shade700
                            : Colors.grey[700],
                        fontWeight: isExpiringSoon || isExpired
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _navigateToDetail(AdminSubscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubscriptionDetailPage(subscription: subscription),
      ),
    );
  }

  void _navigateToAllHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionHistoryPage()),
    );
  }
}
