import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class ChangePlanPage extends ConsumerStatefulWidget {
  final AdminSubscription subscription;

  const ChangePlanPage({super.key, required this.subscription});

  @override
  ConsumerState<ChangePlanPage> createState() => _ChangePlanPageState();
}

class _ChangePlanPageState extends ConsumerState<ChangePlanPage> {
  AdminPlan? _selectedPlan;
  String _selectedBillingCycle = 'monthly'; // 'monthly' or 'annual'
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plansProvider.notifier).loadPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(plansProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Plan Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.subscription.planName ?? 'No Plan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.subscription.shopName} • ${currencyFormat.format(widget.subscription.pricePaid)}/month',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Plans List
          Expanded(
            child: plansState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : plansState.error != null
                ? _buildErrorView(plansState.error!)
                : plansState.plans.isEmpty
                ? const Center(child: Text('No plans available'))
                : Column(
                    children: [
                      // Billing Cycle Toggle
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedBillingCycle = 'monthly',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedBillingCycle == 'monthly'
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow:
                                          _selectedBillingCycle == 'monthly'
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Monthly',
                                        style: TextStyle(
                                          fontWeight:
                                              _selectedBillingCycle == 'monthly'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color:
                                              _selectedBillingCycle == 'monthly'
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedBillingCycle = 'annual',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedBillingCycle == 'annual'
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow:
                                          _selectedBillingCycle == 'annual'
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Annual',
                                            style: TextStyle(
                                              fontWeight:
                                                  _selectedBillingCycle ==
                                                      'annual'
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color:
                                                  _selectedBillingCycle ==
                                                      'annual'
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Save up to 20%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Plans List
                      Expanded(
                        child: _buildPlansList(
                          plansState.plans,
                          currencyFormat,
                        ),
                      ),
                    ],
                  ),
          ),

          // Bottom Action
          if (_selectedPlan != null) _buildBottomAction(currencyFormat),
        ],
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
              'Failed to load plans',
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
              onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(List<AdminPlan> plans, NumberFormat currencyFormat) {
    // Sort plans by price
    final sortedPlans = List<AdminPlan>.from(plans)
      ..sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedPlans.length,
      itemBuilder: (context, index) {
        final plan = sortedPlans[index];
        return _buildPlanCard(plan, currencyFormat);
      },
    );
  }

  Widget _buildPlanCard(AdminPlan plan, NumberFormat currencyFormat) {
    final isCurrentPlan = plan.code == widget.subscription.planCode;
    final isSelected = _selectedPlan?.id == plan.id;
    final changeType = _getChangeType(plan);
    final changeColor = _getChangeColor(changeType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? changeColor
              : isCurrentPlan
              ? Colors.blue
              : Colors.transparent,
          width: isSelected || isCurrentPlan ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: isCurrentPlan
            ? null
            : () => setState(() => _selectedPlan = plan),
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
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCurrentPlan) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (!isCurrentPlan && changeType != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: changeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      changeType == 'upgrade'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 12,
                                      color: changeColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      changeType.toUpperCase(),
                                      style: TextStyle(
                                        color: changeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (plan.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            plan.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isCurrentPlan)
                    Checkbox(
                      value: _selectedPlan?.id == plan.id,
                      onChanged: (value) => setState(
                        () => _selectedPlan = value == true ? plan : null,
                      ),
                      activeColor: changeColor,
                      shape: const CircleBorder(),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Price - Show based on billing cycle
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_selectedBillingCycle == 'annual' &&
                      plan.priceYearly > 0) ...[
                    // Annual price
                    Text(
                      currencyFormat.format(plan.priceYearly),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCurrentPlan ? Colors.blue : changeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/year',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show monthly equivalent
                    if (plan.priceMonthly > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${currencyFormat.format(plan.priceYearly / 12)}/mo',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ] else ...[
                    // Monthly price
                    Text(
                      currencyFormat.format(plan.priceMonthly),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCurrentPlan ? Colors.blue : changeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/month',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ],
              ),
              // Show savings for annual
              if (_selectedBillingCycle == 'annual' &&
                  plan.priceYearly > 0 &&
                  plan.priceMonthly > 0) ...[
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final monthlyTotal = plan.priceMonthly * 12;
                    final savings = monthlyTotal - plan.priceYearly;
                    final savingsPercent = (savings / monthlyTotal * 100)
                        .round();
                    if (savings > 0) {
                      return Text(
                        'Save ${currencyFormat.format(savings)} (${savingsPercent}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Features
              _buildFeatureRow(
                Icons.people,
                'Employees',
                plan.maxEmployees == null || plan.maxEmployees == 0
                    ? 'Unlimited'
                    : '${plan.maxEmployees}',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                Icons.inventory_2,
                'Products',
                plan.maxProducts == null || plan.maxProducts == 0
                    ? 'Unlimited'
                    : '${plan.maxProducts}',
              ),
              if (plan.maxOrdersPerMonth != null) ...[
                const SizedBox(height: 8),
                _buildFeatureRow(
                  Icons.receipt_long,
                  'Orders/month',
                  plan.maxOrdersPerMonth == 0
                      ? 'Unlimited'
                      : '${plan.maxOrdersPerMonth}',
                ),
              ],

              // Badge
              if (plan.badgeText != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        plan.badgeText!,
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomAction(NumberFormat currencyFormat) {
    final changeType = _getChangeType(_selectedPlan!);
    final changeColor = _getChangeColor(changeType);
    final isUpgrade = changeType == 'upgrade';

    // Get price based on billing cycle
    final price =
        _selectedBillingCycle == 'annual' && _selectedPlan!.priceYearly > 0
        ? _selectedPlan!.priceYearly
        : _selectedPlan!.priceMonthly;
    final billingLabel = _selectedBillingCycle == 'annual' ? 'year' : 'month';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isUpgrade ? Icons.arrow_upward : Icons.arrow_downward,
                    color: changeColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isUpgrade ? 'Upgrade' : 'Downgrade'} to ${_selectedPlan!.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: changeColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${currencyFormat.format(price)}/$billingLabel',
                              style: TextStyle(
                                color: changeColor.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: changeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _selectedBillingCycle == 'annual'
                                    ? 'Annual'
                                    : 'Monthly',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: changeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warning for downgrade
            if (!isUpgrade) ...[
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
                        'Downgrading may limit features. Changes apply at next billing cycle.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isProcessing ? null : () => _confirmChange(),
                style: FilledButton.styleFrom(
                  backgroundColor: changeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm ${isUpgrade ? 'Upgrade' : 'Downgrade'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getChangeType(AdminPlan plan) {
    final hierarchy = {
      'trial': 0,
      'free': 0,
      'basic': 1,
      'standard': 2,
      'premium': 3,
      'enterprise': 4,
    };

    final currentLevel =
        hierarchy[widget.subscription.planCode?.toLowerCase()] ?? 0;
    final newLevel = hierarchy[plan.code.toLowerCase()] ?? 0;

    if (newLevel > currentLevel) return 'upgrade';
    if (newLevel < currentLevel) return 'downgrade';
    return null;
  }

  Color _getChangeColor(String? changeType) {
    switch (changeType) {
      case 'upgrade':
        return Colors.green;
      case 'downgrade':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _confirmChange() {
    final changeType = _getChangeType(_selectedPlan!);
    final isUpgrade = changeType == 'upgrade';
    final reasonController = TextEditingController();
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    // Get price based on billing cycle
    final price =
        _selectedBillingCycle == 'annual' && _selectedPlan!.priceYearly > 0
        ? _selectedPlan!.priceYearly
        : _selectedPlan!.priceMonthly;
    final billingLabel = _selectedBillingCycle == 'annual' ? 'year' : 'month';

    // Capture page context for snackbar
    final pageContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isUpgrade ? Icons.arrow_upward : Icons.arrow_downward,
              color: isUpgrade ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text('Confirm ${isUpgrade ? 'Upgrade' : 'Downgrade'}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(dialogContext).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Change '),
                  TextSpan(
                    text: widget.subscription.shopName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' from '),
                  TextSpan(
                    text: widget.subscription.planName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: _selectedPlan!.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUpgrade ? Colors.green : Colors.orange,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currencyFormat.format(price)}/$billingLabel',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedBillingCycle == 'annual' ? 'Annual' : 'Monthly',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          dialogContext,
                        ).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isProcessing = true);

              debugPrint(
                '🔄 Changing plan with billingCycle: $_selectedBillingCycle',
              );

              try {
                await ref
                    .read(subscriptionsProvider.notifier)
                    .changePlan(
                      widget.subscription.shopId,
                      _selectedPlan!.code,
                      billingCycle: _selectedBillingCycle,
                      reason: reasonController.text.isNotEmpty
                          ? reasonController.text
                          : null,
                    );

                if (!mounted) return;
                setState(() => _isProcessing = false);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully ${isUpgrade ? 'upgraded' : 'downgraded'} to ${_selectedPlan!.name}',
                    ),
                    backgroundColor: isUpgrade ? Colors.green : Colors.orange,
                  ),
                );
                Navigator.pop(pageContext, true);
              } catch (e) {
                if (!mounted) return;
                setState(() => _isProcessing = false);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: Text('Failed to change plan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isUpgrade ? Colors.green : Colors.orange,
            ),
            child: Text(isUpgrade ? 'Upgrade' : 'Downgrade'),
          ),
        ],
      ),
    );
  }
}
