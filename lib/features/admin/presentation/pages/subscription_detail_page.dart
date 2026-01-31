import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_history_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/change_plan_page.dart';

class SubscriptionDetailPage extends ConsumerStatefulWidget {
  final AdminSubscription subscription;

  const SubscriptionDetailPage({super.key, required this.subscription});

  @override
  ConsumerState<SubscriptionDetailPage> createState() =>
      _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState
    extends ConsumerState<SubscriptionDetailPage> {
  late AdminSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  void _refreshSubscription() {
    // Re-fetch subscriptions to get updated data
    ref.read(subscriptionsProvider.notifier).loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    // Listen for subscription changes
    ref.listen<SubscriptionsState>(subscriptionsProvider, (previous, next) {
      if (!next.isLoading && next.subscriptions.isNotEmpty) {
        final updated = next.subscriptions.firstWhere(
          (s) => s.shopId == _subscription.shopId,
          orElse: () => _subscription,
        );
        if (mounted) {
          setState(() => _subscription = updated);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_subscription.shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () => _navigateToHistory(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSubscription,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(dateFormat),
            const SizedBox(height: 16),

            // Plan Info Card
            _buildPlanCard(currencyFormat),
            const SizedBox(height: 16),

            // Usage Card
            _buildUsageCard(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Management Actions
            _buildManagementActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(DateFormat dateFormat) {
    final statusColor = _getStatusColor(_subscription.status);
    final daysLeft =
        _subscription.expiresAt?.difference(DateTime.now()).inDays ?? 0;
    final isExpiringSoon = daysLeft <= 7 && daysLeft > 0;
    final isExpired = daysLeft < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _subscription.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$daysLeft days left',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Shop ID', '#${_subscription.shopId}', Icons.store),
            const Divider(height: 24),
            _buildInfoRow(
              'Start Date',
              _subscription.startedAt != null
                  ? dateFormat.format(_subscription.startedAt!)
                  : 'N/A',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Expiry Date',
              _subscription.expiresAt != null
                  ? dateFormat.format(_subscription.expiresAt!)
                  : 'N/A',
              isExpired ? Icons.error : Icons.event,
              valueColor: isExpired ? Colors.red : null,
            ),
            if (!isExpired) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Days Remaining',
                '$daysLeft days',
                Icons.timer,
                valueColor: isExpiringSoon ? Colors.orange : Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Plan Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Current Plan',
              _subscription.planName ?? 'No Plan',
              Icons.card_membership,
            ),
            if (_subscription.planCode != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Plan Code', _subscription.planCode!, Icons.code),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              'Price',
              currencyFormat.format(_subscription.pricePaid),
              Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildUsageRow(
              'Employees',
              _subscription.currentEmployees,
              _subscription.maxEmployees,
              Icons.people,
            ),
            const SizedBox(height: 16),
            _buildUsageRow(
              'Products',
              _subscription.currentProducts,
              _subscription.maxProducts,
              Icons.inventory_2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(String label, int current, int max, IconData icon) {
    final isUnlimited = max == 0;
    final percentage = isUnlimited ? 0.0 : (current / max).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.grey[600])),
            const Spacer(),
            Text(
              '$current / ${isUnlimited ? '∞' : max}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isNearLimit ? Colors.orange : null,
              ),
            ),
          ],
        ),
        if (!isUnlimited) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              isNearLimit ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Extend',
                Icons.add_circle_outline,
                Colors.green,
                () => _showExtendDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Reduce',
                Icons.remove_circle_outline,
                Colors.orange,
                () => _showReduceDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.swap_horiz, color: Colors.white),
                ),
                title: const Text('Change Plan'),
                subtitle: const Text('Upgrade or downgrade subscription plan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToChangePlan(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: const Text('View History'),
                subtitle: const Text('See all subscription changes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToHistory(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
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

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionHistoryPage(
          shopId: _subscription.shopId,
          shopName: _subscription.shopName,
        ),
      ),
    );
  }

  void _navigateToChangePlan() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePlanPage(subscription: _subscription),
      ),
    );
    if (result == true) {
      _refreshSubscription();
    }
  }

  void _showExtendDialog() {
    final daysController = TextEditingController(text: '30');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: daysController,
              decoration: const InputDecoration(
                labelText: 'Days to extend',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final days = int.tryParse(daysController.text) ?? 30;
              ref
                  .read(subscriptionsProvider.notifier)
                  .extendSubscription(
                    _subscription.shopId,
                    days: days,
                    reason: reasonController.text.isNotEmpty
                        ? reasonController.text
                        : null,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Extended subscription by $days days'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }

  void _showReduceDialog() {
    final daysController = TextEditingController(text: '7');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_circle_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Reduce Subscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cannot reduce below current date',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              decoration: const InputDecoration(
                labelText: 'Days to reduce',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final days = int.tryParse(daysController.text) ?? 7;
              ref
                  .read(subscriptionsProvider.notifier)
                  .reduceSubscription(
                    _subscription.shopId,
                    days: days,
                    reason: reasonController.text,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reduced subscription by $days days'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reduce'),
          ),
        ],
      ),
    );
  }
}
