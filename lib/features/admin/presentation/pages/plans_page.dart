import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});

  @override
  ConsumerState<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends ConsumerState<PlansPage> {
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
        leading: buildAdminMenuButton(context),
        title: const Text('Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
      body: plansState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plansState.error != null
          ? _buildErrorView(plansState.error!)
          : plansState.plans.isEmpty
          ? const Center(child: Text('No plans found'))
          : _buildPlanList(plansState.plans, currencyFormat),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(List<AdminPlan> plans, NumberFormat currencyFormat) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(plansProvider.notifier).loadPlans();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return _buildPlanCard(plan, currencyFormat);
        },
      ),
    );
  }

  Widget _buildPlanCard(AdminPlan plan, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plan.isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
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
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (plan.badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan.badgeText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan.code,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: plan.isActive,
                  onChanged: (value) {
                    if (value) {
                      ref.read(plansProvider.notifier).activatePlan(plan.id);
                    } else {
                      ref.read(plansProvider.notifier).deactivatePlan(plan.id);
                    }
                  },
                ),
              ],
            ),
          ),
          // Pricing
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriceColumn(
                      'Monthly',
                      currencyFormat.format(plan.priceMonthly),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildPriceColumn(
                      'Yearly',
                      currencyFormat.format(plan.priceYearly),
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Limits
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLimitItem(
                      Icons.people,
                      plan.maxEmployees?.toString() ?? '∞',
                      'Employees',
                    ),
                    _buildLimitItem(
                      Icons.inventory,
                      plan.maxProducts?.toString() ?? '∞',
                      'Products',
                    ),
                    _buildLimitItem(
                      Icons.receipt_long,
                      plan.maxOrdersPerMonth?.toString() ?? '∞',
                      'Orders/mo',
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active: ${plan.activeSubscriptions}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      'Total: ${plan.totalSubscriptions}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (plan.isTrialAvailable) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${plan.trialDays} days trial available',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showPlanDetails(plan, currencyFormat),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showEditPlanDialog(plan),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, String price) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLimitItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _showPlanDetails(AdminPlan plan, NumberFormat currencyFormat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(plan.code),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: plan.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (plan.description != null) ...[
                const SizedBox(height: 16),
                Text(plan.description!),
              ],
              const SizedBox(height: 24),
              _buildDetailSection('Pricing', [
                _buildDetailRow(
                  'Monthly',
                  currencyFormat.format(plan.priceMonthly),
                ),
                _buildDetailRow(
                  'Yearly',
                  currencyFormat.format(plan.priceYearly),
                ),
                _buildDetailRow('Currency', plan.currency),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Limits', [
                _buildDetailRow(
                  'Max Employees',
                  plan.maxEmployees?.toString() ?? 'Unlimited',
                ),
                _buildDetailRow(
                  'Max Products',
                  plan.maxProducts?.toString() ?? 'Unlimited',
                ),
                _buildDetailRow(
                  'Max Orders/Month',
                  plan.maxOrdersPerMonth?.toString() ?? 'Unlimited',
                ),
                _buildDetailRow(
                  'Storage',
                  plan.maxStorageMb != null
                      ? '${plan.maxStorageMb} MB'
                      : 'Unlimited',
                ),
              ]),
              if (plan.isTrialAvailable) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Trial', [
                  _buildDetailRow('Trial Available', 'Yes'),
                  _buildDetailRow('Trial Days', plan.trialDays.toString()),
                ]),
              ],
              const SizedBox(height: 16),
              _buildDetailSection('Statistics', [
                _buildDetailRow(
                  'Active Subscriptions',
                  plan.activeSubscriptions.toString(),
                ),
                _buildDetailRow(
                  'Total Subscriptions',
                  plan.totalSubscriptions.toString(),
                ),
                _buildDetailRow('Display Order', plan.displayOrder.toString()),
              ]),
              if (plan.features.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Features',
                  plan.features.entries
                      .map((e) => _buildDetailRow(e.key, e.value.toString()))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showCreatePlanDialog() {
    // TODO: Implement create plan dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create plan feature coming soon')),
    );
  }

  void _showEditPlanDialog(AdminPlan plan) {
    // TODO: Implement edit plan dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit plan feature coming soon')),
    );
  }
}
