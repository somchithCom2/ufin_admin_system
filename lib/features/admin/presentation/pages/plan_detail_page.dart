import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/edit_plan_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.planId);
      if (id != null) {
        ref.read(planDetailProvider.notifier).loadPlan(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planDetailProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final id = int.tryParse(widget.planId);
                  if (id != null) {
                    ref.read(planDetailProvider.notifier).loadPlan(id);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final plan = state.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan Details')),
        body: const Center(child: Text('Plan not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(planDetailProvider.notifier).loadPlan(plan.id);
            },
          ),
          Switch(
            value: plan.isActive,
            onChanged: (value) {
              if (value) {
                ref.read(planDetailProvider.notifier).activatePlan(plan.id);
              } else {
                ref.read(planDetailProvider.notifier).deactivatePlan(plan.id);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditPlanDialog(context, plan),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(planDetailProvider.notifier).loadPlan(plan.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                                  style: Theme.of(context).textTheme.titleLarge,
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
                            const SizedBox(height: 4),
                            Text(
                              plan.code,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                ),
              ),
              if (plan.description != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(plan.description!),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailSection(context, 'Pricing', [
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
              const SizedBox(height: 12),
              _buildDetailSection(context, 'Limits', [
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
                const SizedBox(height: 12),
                _buildDetailSection(context, 'Trial', [
                  _buildDetailRow('Trial Available', 'Yes'),
                  _buildDetailRow('Trial Days', plan.trialDays.toString()),
                ]),
              ],
              const SizedBox(height: 12),
              _buildDetailSection(context, 'Statistics', [
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
                const SizedBox(height: 12),
                _buildDetailSection(
                  context,
                  'Features',
                  plan.features.entries
                      .map((e) => _buildDetailRow(e.key, e.value.toString()))
                      .toList(),
                ),
              ],
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
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

  void _showEditPlanDialog(BuildContext context, AdminPlan plan) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EditPlanPage(plan: plan)),
    );

    // Refresh plan data if edit was successful
    if (result == true) {
      ref.read(planDetailProvider.notifier).loadPlan(plan.id);
    }
  }
}
