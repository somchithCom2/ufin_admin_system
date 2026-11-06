import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/edit_plan_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  Future<void> _setPlanActive(AdminPlan plan, bool active) async {
    if (!active) {
      final ok = await AppDialogs.confirm(
        context,
        title: context.tr(PlanEditText.deactivatePlan),
        message: context.tr(PlanEditText.willNoLongerBeOffered(plan.name)),
        confirmLabel: context.tr(PlanEditText.deactivate),
        destructive: true,
        icon: Icons.pause_circle_outline_rounded,
      );
      if (!ok || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(planDetailProvider.notifier);
    try {
      if (active) {
        await notifier.activatePlan(plan.id);
      } else {
        await notifier.deactivatePlan(plan.id);
      }
      messenger.showSuccess(
        '"${plan.name}" ${active ? 'activated' : 'deactivated'}',
      );
    } catch (e) {
      messenger.showError(
        PlanEditText.couldNotUpdate(plan.name, friendlyError(e)).current,
      );
    }
  }

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
        appBar: AppBar(title: Text(context.tr(PlanEditText.planDetails))),
        body: const AppLoadingView(),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr(PlanEditText.planDetails))),
        body: AppErrorView(
          error: state.error,
          onRetry: () {
            final id = int.tryParse(widget.planId);
            if (id != null) {
              ref.read(planDetailProvider.notifier).loadPlan(id);
            }
          },
        ),
      );
    }

    final plan = state.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr(PlanEditText.planDetails))),
        body: AppEmptyView(
          icon: Icons.inventory_2_outlined,
          title: context.tr(PlanEditText.planNotFound),
          message: context.tr(PlanEditText.itMayHaveBeenDeleted),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(planDetailProvider.notifier).loadPlan(plan.id);
            },
          ),
          Switch(
            value: plan.isActive,
            onChanged: (value) => _setPlanActive(plan, value),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditPlanDialog(context, plan),
        icon: const Icon(Icons.edit),
        label: Text(context.tr(CommonText.edit)),
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
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  plan.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (plan.badgeText != null &&
                                    plan.badgeText!.isNotEmpty)
                                  StatusBadge(
                                    label: plan.badgeText!,
                                    tone: StatusTone.neutral,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.code,
                              style: TextStyle(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.fromStatus(
                        plan.isActive ? 'active' : 'inactive',
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
                          context.tr(CommonText.description),
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
              _buildDetailSection(context, context.tr(PlanEditText.pricing), [
                _buildDetailRow(
                  context.tr(PlanEditText.monthly),
                  currencyFormat.format(plan.priceMonthly),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.yearly),
                  currencyFormat.format(plan.priceYearly),
                ),
                _buildDetailRow(context.tr(CommonText.currency), plan.currency),
              ]),
              const SizedBox(height: 12),
              _buildDetailSection(context, context.tr(PlanEditText.limits), [
                _buildDetailRow(
                  context.tr(PlanEditText.maxEmployees),
                  plan.maxEmployees?.toString() ??
                      context.tr(PlanEditText.unlimited2),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.maxProducts),
                  plan.maxProducts?.toString() ??
                      context.tr(PlanEditText.unlimited2),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.maxOrdersMonth),
                  plan.maxOrdersPerMonth?.toString() ??
                      context.tr(PlanEditText.unlimited2),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.storage),
                  plan.maxStorageMb != null
                      ? context.tr(PlanEditText.mb(plan.maxStorageMb))
                      : context.tr(PlanEditText.unlimited2),
                ),
              ]),
              if (plan.isTrialAvailable) ...[
                const SizedBox(height: 12),
                _buildDetailSection(context, context.tr(PlanEditText.trial), [
                  _buildDetailRow(
                    context.tr(PlanEditText.trialAvailable2),
                    context.tr(CommonText.yes),
                  ),
                  _buildDetailRow(
                    context.tr(PlanEditText.trialDays2),
                    plan.trialDays.toString(),
                  ),
                ]),
              ],
              const SizedBox(height: 12),
              _buildDetailSection(context, context.tr(NavText.statistics), [
                _buildDetailRow(
                  context.tr(PlanEditText.activeSubscriptions),
                  plan.activeSubscriptions.toString(),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.totalSubscriptions),
                  plan.totalSubscriptions.toString(),
                ),
                _buildDetailRow(
                  context.tr(PlanEditText.displayOrder2),
                  plan.displayOrder.toString(),
                ),
              ]),
              if (plan.features.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailSection(
                  context,
                  context.tr(PlanEditText.features),
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
          Text(label, style: TextStyle(color: context.colors.onSurfaceVariant)),
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
