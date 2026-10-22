import 'package:flutter/material.dart';
import 'subscription_action_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_history_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/change_plan_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/subscription_days_form.dart';
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
  static final _dateFormat = DateFormat('d MMM y');

  late AdminSubscription _subscription;
  bool _savingAutoRenew = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  bool get _isRunning =>
      _subscription.status == 'active' || _subscription.status == 'trial';

  bool get _isLapsed =>
      _subscription.status == 'expired' || _subscription.status == 'cancelled';

  String _date(DateTime? value) =>
      value == null ? '—' : _dateFormat.format(value);

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

  /// Turns auto-renewal on or off.
  ///
  /// Auto-renewal does not hand out free time: the scheduler only rolls a paid
  /// subscription forward when a completed payment that has not been spent yet
  /// covers the next period. This switch decides whether such a payment is
  /// applied automatically or whether the admin extends by hand.
  Future<void> _toggleAutoRenew(bool value) async {
    if (_savingAutoRenew) return;
    setState(() => _savingAutoRenew = true);
    try {
      final updated = await ref
          .read(adminRepositoryProvider)
          .setAutoRenew(
            _subscription.shopId,
            UpdateAutoRenewRequest(
              autoRenew: value,
              reason: value
                  ? 'Enabled from admin console'
                  : 'Disabled from admin console',
            ),
          );
      if (!mounted) return;
      setState(() => _subscription = updated);
      ref.read(subscriptionsProvider.notifier).refresh();
      AppFeedback.success(
        context,
        value ? 'Auto-renew is on' : 'Auto-renew is off',
      );
    } catch (e) {
      if (mounted) AppFeedback.error(context, e);
    } finally {
      if (mounted) setState(() => _savingAutoRenew = false);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_subscription.shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: _navigateToHistory,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshSubscription,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSubscription,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ContentWidth(
              maxWidth: 860,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummary(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActions(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDetailsCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRenewalCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildUsageCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status, plan and how much time is left, readable at a glance.
  Widget _buildSummary() {
    final expiresAt = _subscription.expiresAt;
    final now = DateTime.now();
    final isExpired = expiresAt != null && expiresAt.isBefore(now);
    final daysLeft = expiresAt?.difference(now).inDays;
    final muted = context.colors.onSurfaceVariant;

    final String timeLine;
    Color? timeColor;
    if (_subscription.billingCycle == 'lifetime') {
      timeLine = 'Lifetime · never expires';
    } else if (expiresAt == null) {
      timeLine = 'No expiry date';
    } else if (isExpired) {
      timeLine = 'Expired ${_date(expiresAt)}';
      timeColor = context.colors.error;
    } else {
      timeLine =
          'Expires ${_date(expiresAt)} · '
          '${daysLeft == 0 ? 'today' : '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} left'}';
      if (daysLeft! <= 7) timeColor = context.status.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _subscription.planName ?? 'No plan',
              style: context.text.headlineSmall,
            ),
            StatusBadge.fromStatus(_subscription.status),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          timeLine,
          style: context.text.bodyMedium?.copyWith(color: timeColor ?? muted),
        ),
      ],
    );
  }

  /// Every action in one place, the usual ones first.
  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (_isLapsed)
              FilledButton.icon(
                onPressed: () =>
                    _manageSubscription(SubscriptionAction.reactivate),
                icon: const Icon(Icons.restore_rounded, size: 18),
                label: const Text('Reactivate'),
              ),
            FilledButton.tonalIcon(
              onPressed: _showExtendForm,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Extend'),
            ),
            OutlinedButton.icon(
              onPressed: _navigateToChangePlan,
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Change plan'),
            ),
            // Shortening a period only applies to a running subscription; the
            // server refuses this for an expired or cancelled one rather than
            // silently reactivating it.
            if (_isRunning)
              OutlinedButton.icon(
                onPressed: _showReduceForm,
                icon: const Icon(Icons.remove_rounded, size: 18),
                label: const Text('Reduce'),
              ),
            if (_isRunning)
              TextButton.icon(
                onPressed: () => _manageSubscription(SubscriptionAction.cancel),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel subscription'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    final cycle = _subscription.billingCycle;
    return SectionCard(
      title: 'Details',
      child: Column(
        children: [
          InfoRow(label: 'Shop ID', value: '#${_subscription.shopId}'),
          if (_subscription.shopOwnerEmail != null)
            InfoRow(label: 'Owner email', value: _subscription.shopOwnerEmail!),
          if (_subscription.planCode != null)
            InfoRow(label: 'Plan code', value: _subscription.planCode!),
          InfoRow(
            label: 'Price paid',
            value: MoneyFormat.format(
              _subscription.pricePaid,
              _subscription.currency,
            ),
          ),
          InfoRow(
            label: 'Billing cycle',
            value: cycle == null ? '—' : humanize(cycle),
          ),
          InfoRow(label: 'Started', value: _date(_subscription.startedAt)),
          InfoRow(
            label: 'Expires',
            value: _date(_subscription.expiresAt),
            valueColor:
                _subscription.expiresAt != null &&
                    _subscription.expiresAt!.isBefore(DateTime.now())
                ? context.colors.error
                : null,
          ),
          if (_subscription.trialEndsAt != null)
            InfoRow(
              label: 'Trial ends',
              value: _date(_subscription.trialEndsAt),
            ),
          if (_subscription.cancelledAt != null)
            InfoRow(
              label: 'Cancelled',
              value: _date(_subscription.cancelledAt),
            ),
        ],
      ),
    );
  }

  /// Renewal state: whether auto-renew is on, when the next period is due, and
  /// — the part that used to be invisible — whether that renewal is actually
  /// funded. Auto-renewal only rolls a paid subscription forward when a
  /// completed payment that has not been spent yet covers the next period, so
  /// "auto-renew on" and "will actually renew" are two different things.
  Widget _buildRenewalCard() {
    final isLifetime = _subscription.billingCycle == 'lifetime';
    final isPaid = _subscription.pricePaid > 0;
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return SectionCard(
      title: 'Renewal',
      trailing: _savingAutoRenew
          ? const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(
            label: 'Next billing date',
            value: _date(_subscription.nextBillingDate),
          ),
          if (isLifetime)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'A lifetime subscription never expires and is never renewed.',
                style: muted,
              ),
            )
          else ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-renew'),
              subtitle: Text(
                _subscription.autoRenew
                    ? 'Rolls forward automatically when the next period is paid for.'
                    : 'Will not roll forward; the shop drops to the Free plan at expiry.',
              ),
              value: _subscription.autoRenew,
              onChanged: _savingAutoRenew || _isLapsed
                  ? null
                  : _toggleAutoRenew,
            ),
            if (_isLapsed)
              Text(
                'Reactivate the subscription before changing auto-renew.',
                style: muted,
              )
            else if (isPaid && _subscription.autoRenew)
              Text(
                'This is a paid plan. It only renews if a completed payment '
                'covering the next period is recorded in Payments, or if you '
                'extend it manually.',
                style: muted,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageCard() {
    return SectionCard(
      title: 'Usage',
      child: Column(
        children: [
          _buildUsageRow(
            'Employees',
            _subscription.currentEmployees,
            _subscription.maxEmployees,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildUsageRow(
            'Products',
            _subscription.currentProducts,
            _subscription.maxProducts,
          ),
        ],
      ),
    );
  }

  /// Null [max] means no limit; 0 is a real limit of zero.
  Widget _buildUsageRow(String label, int current, int? max) {
    final isUnlimited = max == null;
    final percentage = max == null
        ? 0.0
        : max == 0
        ? (current > 0 ? 1.0 : 0.0)
        : (current / max).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              isUnlimited ? '$current · unlimited' : '$current of $max',
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isNearLimit ? context.status.warning : null,
              ),
            ),
          ],
        ),
        if (!isUnlimited) ...[
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
            color: isNearLimit ? context.status.warning : null,
          ),
        ],
      ],
    );
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

  Future<void> _navigateToChangePlan() async {
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

  Future<void> _showExtendForm() async {
    final days = await showSubscriptionDaysForm(
      context,
      reduce: false,
      shopName: _subscription.shopName,
      save: (days, reason) => ref
          .read(subscriptionsProvider.notifier)
          .extendSubscription(_subscription.shopId, days: days, reason: reason),
    );
    if (days == null || !mounted) return;
    AppFeedback.success(
      context,
      'Extended by $days ${days == 1 ? 'day' : 'days'}',
    );
    _refreshSubscription();
  }

  Future<void> _showReduceForm() async {
    final days = await showSubscriptionDaysForm(
      context,
      reduce: true,
      shopName: _subscription.shopName,
      save: (days, reason) => ref
          .read(subscriptionsProvider.notifier)
          .reduceSubscription(_subscription.shopId, days: days, reason: reason),
    );
    if (days == null || !mounted) return;
    AppFeedback.success(
      context,
      'Reduced by $days ${days == 1 ? 'day' : 'days'}',
    );
    _refreshSubscription();
  }
}
