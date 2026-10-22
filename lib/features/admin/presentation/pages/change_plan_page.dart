import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class ChangePlanPage extends ConsumerStatefulWidget {
  final AdminSubscription subscription;

  const ChangePlanPage({super.key, required this.subscription});

  @override
  ConsumerState<ChangePlanPage> createState() => _ChangePlanPageState();
}

class _ChangePlanPageState extends ConsumerState<ChangePlanPage> {
  AdminPlan? _selectedPlan;
  late String _selectedBillingCycle; // 'monthly' or 'annual'
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Start on the cycle the shop already pays on.
    final cycle = widget.subscription.billingCycle?.toLowerCase();
    _selectedBillingCycle = cycle == 'yearly' || cycle == 'annual'
        ? 'annual'
        : 'monthly';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plansProvider.notifier).loadPlans();
    });
  }

  bool get _annual => _selectedBillingCycle == 'annual';

  /// What the server will charge for [plan] on the selected cycle.
  double _priceOf(AdminPlan plan) =>
      _annual ? plan.priceYearly : plan.priceMonthly;

  String _priceLabel(AdminPlan plan) {
    final price = _priceOf(plan);
    if (price == 0) return 'Free';
    return '${MoneyFormat.format(price, plan.currency)} / ${_annual ? 'year' : 'month'}';
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Plan'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
          ),
        ],
      ),
      body: ContentWidth(
        maxWidth: 760,
        child: Column(
          children: [
            Expanded(
              child: plansState.isLoading
                  ? const AppLoadingView()
                  : plansState.error != null
                  ? AppErrorView(
                      error: plansState.error,
                      onRetry: () =>
                          ref.read(plansProvider.notifier).loadPlans(),
                    )
                  : plansState.plans.isEmpty
                  ? const AppEmptyView(
                      icon: Icons.inventory_2_outlined,
                      title: 'No plans available',
                    )
                  : _buildPlansList(plansState.plans),
            ),
            if (_selectedPlan != null) _buildBottomAction(_selectedPlan!),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    final sub = widget.subscription;
    final muted = context.colors.onSurfaceVariant;
    final cycle = sub.billingCycle == null
        ? ''
        : ' · ${humanize(sub.billingCycle!)}';
    return SectionCard(
      title: 'Current plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sub.planName ?? 'No plan', style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${sub.shopName} · ${MoneyFormat.format(sub.pricePaid, sub.currency)} paid$cycle',
            style: context.text.bodyMedium?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(List<AdminPlan> plans) {
    final sortedPlans = List<AdminPlan>.from(plans)
      ..sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildCurrentPlan(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text('Choose a new plan', style: context.text.titleMedium),
            ),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ButtonSegment(value: 'annual', label: Text('Yearly')),
              ],
              selected: {_selectedBillingCycle},
              onSelectionChanged: (s) =>
                  setState(() => _selectedBillingCycle = s.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final plan in sortedPlans) ...[
          _buildPlanCard(plan),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildPlanCard(AdminPlan plan) {
    final isCurrentPlan = plan.code == widget.subscription.planCode;
    final isSelected = _selectedPlan?.id == plan.id;
    final changeType = _getChangeType(plan);
    final scheme = context.colors;
    final muted = scheme.onSurfaceVariant;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: isCurrentPlan || _isProcessing
            ? null
            : () => setState(() => _selectedPlan = isSelected ? null : plan),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  isCurrentPlan
                      ? Icons.check_circle_rounded
                      : isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: isSelected || isCurrentPlan ? scheme.primary : muted,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(plan.name, style: context.text.titleMedium),
                        if (isCurrentPlan)
                          const StatusBadge(
                            label: 'Current',
                            tone: StatusTone.primary,
                          )
                        else if (changeType != null)
                          StatusBadge(
                            label: _actionLabel(changeType),
                            tone: StatusTone.neutral,
                            icon: _actionIcon(changeType),
                          ),
                        if (plan.badgeText != null &&
                            plan.badgeText!.isNotEmpty)
                          StatusBadge(
                            label: plan.badgeText!,
                            tone: StatusTone.neutral,
                          ),
                      ],
                    ),
                    if (plan.description != null &&
                        plan.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        plan.description!,
                        style: context.text.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_priceLabel(plan), style: context.text.titleSmall),
                        if (_annual) ?_yearlySaving(plan),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        _limit(plan.maxEmployees, 'employees'),
                        _limit(plan.maxProducts, 'products'),
                        if (plan.maxOrdersPerMonth != null)
                          _limit(plan.maxOrdersPerMonth, 'orders / month'),
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Null means no limit; 0 is a real limit of zero.
  String _limit(int? value, String unit) =>
      value == null ? 'Unlimited $unit' : '$value $unit';

  /// The saving against twelve monthly payments, when there is one.
  Widget? _yearlySaving(AdminPlan plan) {
    final twelveMonths = plan.priceMonthly * 12;
    final saving = twelveMonths - plan.priceYearly;
    if (plan.priceYearly <= 0 || saving <= 0) return null;
    return Text(
      'Saves ${(saving / twelveMonths * 100).round()}%',
      style: context.text.bodySmall?.copyWith(color: context.status.success),
    );
  }

  Widget _buildBottomAction(AdminPlan plan) {
    final action = _actionLabel(_getChangeType(plan));
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$action to ${plan.name} · ${_priceLabel(plan)}',
              style: context.text.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _effectNote(),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _isProcessing ? null : _confirmChange,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('$action plan'),
            ),
          ],
        ),
      ),
    );
  }

  /// What the server does on a plan change with a billing cycle: the new plan
  /// applies at once and a fresh period starts today.
  String _effectNote() =>
      'Applies immediately. A new ${_annual ? 'one-year' : 'one-month'} '
      'period starts today and the subscription becomes active.';

  /// Upgrade or downgrade, decided the way the server records it: by
  /// comparing monthly prices with the shop's current plan. Plan codes are
  /// admin-defined, so they say nothing about rank. Returns null when the
  /// prices are equal or the current plan is not in the list.
  String? _getChangeType(AdminPlan plan) {
    final sub = widget.subscription;
    AdminPlan? currentPlan;
    for (final p in ref.read(plansProvider).plans) {
      if ((sub.planId != null && p.id == sub.planId) ||
          p.code == sub.planCode) {
        currentPlan = p;
        break;
      }
    }
    if (currentPlan == null) return null;

    final diff = plan.priceMonthly.compareTo(currentPlan.priceMonthly);
    if (diff > 0) return 'upgrade';
    if (diff < 0) return 'downgrade';
    return null;
  }

  String _actionLabel(String? changeType) => switch (changeType) {
    'upgrade' => 'Upgrade',
    'downgrade' => 'Downgrade',
    _ => 'Change',
  };

  IconData _actionIcon(String? changeType) => switch (changeType) {
    'upgrade' => Icons.arrow_upward_rounded,
    'downgrade' => Icons.arrow_downward_rounded,
    _ => Icons.swap_horiz_rounded,
  };

  Future<void> _confirmChange() async {
    final plan = _selectedPlan!;
    final changeType = _getChangeType(plan);
    final action = _actionLabel(changeType);

    final reason = await AppDialogs.confirmWithReason(
      context,
      title: '$action plan?',
      message:
          '${widget.subscription.shopName} moves from '
          '${widget.subscription.planName ?? 'no plan'} to ${plan.name} '
          'at ${_priceLabel(plan)}. ${_effectNote()}',
      confirmLabel: action,
      icon: _actionIcon(changeType),
      destructive: changeType == 'downgrade',
    );
    if (reason == null || !mounted) return;

    setState(() => _isProcessing = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(subscriptionsProvider.notifier)
          .changePlan(
            widget.subscription.shopId,
            plan.code,
            billingCycle: _selectedBillingCycle,
            reason: reason.isEmpty ? null : reason,
          );
      if (!mounted) return;
      messenger.showSuccess(switch (changeType) {
        'upgrade' => 'Upgraded to ${plan.name}',
        'downgrade' => 'Downgraded to ${plan.name}',
        _ => 'Plan changed to ${plan.name}',
      });
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showError('Failed to change plan: ${friendlyError(e)}');
    }
  }
}
