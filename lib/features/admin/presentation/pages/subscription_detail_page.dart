import 'package:flutter/material.dart';
import 'subscription_action_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_history_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/change_plan_page.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

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

  Future<void> _refreshSubscription() async {
    try {
      final value = await ref
          .read(adminRepositoryProvider)
          .getSubscriptionByShop(_subscription.shopId);
      if (mounted) setState(() => _subscription = value);
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, e);
      }
    }
  }

  Future<void> _manageSubscription(SubscriptionAction action) async {
    final result = await Navigator.of(context).push<AdminSubscription>(
      MaterialPageRoute(
        builder: (_) =>
            SubscriptionActionPage(action: action, subscription: _subscription),
      ),
    );
    if (mounted && result != null) setState(() => _subscription = result);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d, yyyy');

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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
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
            const SizedBox(height: 16),
            if (_subscription.status == 'active' ||
                _subscription.status == 'trial')
              OutlinedButton.icon(
                onPressed: () => _manageSubscription(SubscriptionAction.cancel),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Subscription'),
              ),
            if (_subscription.status == 'expired' ||
                _subscription.status == 'cancelled')
              FilledButton.icon(
                onPressed: () =>
                    _manageSubscription(SubscriptionAction.reactivate),
                icon: const Icon(Icons.restore),
                label: const Text('Reactivate Subscription'),
              ),
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
                      color: context.status.warningContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 14,
                          color: context.status.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$daysLeft days left',
                          style: TextStyle(
                            color: context.status.warning,
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
              valueColor: isExpired ? context.colors.error : null,
            ),
            if (!isExpired) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Days Remaining',
                '$daysLeft days',
                Icons.timer,
                valueColor: isExpiringSoon
                    ? context.status.warning
                    : context.status.success,
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
                Icon(Icons.analytics, color: context.status.info),
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

  Widget _buildUsageRow(String label, int current, int? max, IconData icon) {
    final isUnlimited = max == null;
    final percentage = max == null
        ? 0.0
        : max == 0
        ? (current > 0 ? 1.0 : 0.0)
        : (current / max).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              '$current / ${isUnlimited ? '∞' : max}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isNearLimit ? context.status.warning : null,
              ),
            ),
          ],
        ),
        if (!isUnlimited) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.colors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(
              isNearLimit ? context.status.warning : context.status.info,
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
                context.status.success,
                () => _showExtendDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Reduce',
                Icons.remove_circle_outline,
                context.status.warning,
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
                leading: CircleAvatar(
                  backgroundColor: context.status.info,
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
        Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: context.colors.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return StatusTone.fromStatus(status).foreground(context);
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
    final pageContext = context; // Capture parent context

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Extend Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: daysController,
              decoration: const InputDecoration(labelText: 'Days to extend'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final days = int.tryParse(daysController.text) ?? 30;
              try {
                await ref
                    .read(subscriptionsProvider.notifier)
                    .extendSubscription(
                      _subscription.shopId,
                      days: days,
                      reason: reasonController.text.isNotEmpty
                          ? reasonController.text
                          : null,
                    );
                if (pageContext.mounted) {
                  AppFeedback.success(
                    pageContext,
                    'Extended subscription by $days days',
                  );
                  _refreshSubscription();
                }
              } catch (e) {
                if (pageContext.mounted) {
                  AppFeedback.show(
                    pageContext,
                    'Failed to extend subscription: ${friendlyError(e)}',
                    kind: FeedbackKind.error,
                  );
                }
              }
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
    final pageContext = context; // Capture parent context

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_circle_outline, color: context.status.warning),
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
                color: context.status.warningContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: context.status.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cannot reduce below current date',
                      style: TextStyle(
                        color: context.status.warning,
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
              decoration: const InputDecoration(labelText: 'Days to reduce'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (required)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                AppFeedback.warning(pageContext, 'Please provide a reason');
                return;
              }
              Navigator.pop(dialogContext);
              final days = int.tryParse(daysController.text) ?? 7;
              try {
                await ref
                    .read(subscriptionsProvider.notifier)
                    .reduceSubscription(
                      _subscription.shopId,
                      days: days,
                      reason: reasonController.text,
                    );
                if (pageContext.mounted) {
                  AppFeedback.success(
                    pageContext,
                    'Reduced subscription by $days days',
                  );
                  _refreshSubscription();
                }
              } catch (e) {
                if (pageContext.mounted) {
                  AppFeedback.show(
                    pageContext,
                    'Failed to reduce subscription: ${friendlyError(e)}',
                    kind: FeedbackKind.error,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.status.warning,
            ),
            child: const Text('Reduce'),
          ),
        ],
      ),
    );
  }
}
