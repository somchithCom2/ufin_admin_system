import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/plan_detail_page.dart';

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
        padding: const EdgeInsets.all(12),
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
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(planId: plan.id.toString()),
            ),
          );
        },
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
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
                        ref
                            .read(plansProvider.notifier)
                            .deactivatePlan(plan.id);
                      }
                    },
                  ),
                ],
              ),
            ),
            // Pricing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriceColumn(
                        'Monthly',
                        currencyFormat.format(plan.priceMonthly),
                      ),
                      Container(height: 32, width: 1, color: Colors.grey[300]),
                      _buildPriceColumn(
                        'Yearly',
                        currencyFormat.format(plan.priceYearly),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
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
                  const Divider(height: 20),
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
                ],
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (plan.isTrialAvailable)
                    Text(
                      '${plan.trialDays} days trial',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PlanDetailPage(planId: plan.id.toString()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceColumn(String label, String price) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 2),
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
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
      ],
    );
  }

  void _showCreatePlanDialog() {
    // TODO: Implement create plan dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create plan feature coming soon')),
    );
  }
}
