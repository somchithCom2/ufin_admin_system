import 'package:flutter/material.dart';
import 'edit_plan_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/plan_detail_page.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});

  @override
  ConsumerState<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends ConsumerState<PlansPage> {
  Future<void> _setPlanActive(AdminPlan plan, bool active) async {
    if (!active) {
      final ok = await AppDialogs.confirm(
        context,
        title: context.tr(PlansText.deactivatePlan),
        message: context.tr(PlansText.willNoLongerBeOffered(plan.name)),
        confirmLabel: context.tr(PlansText.deactivate),
        destructive: true,
        icon: Icons.pause_circle_outline_rounded,
      );
      if (!ok || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(plansProvider.notifier);
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
        PlansText.couldNotUpdate(plan.name, friendlyError(e)).current,
      );
    }
  }

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
        title: Text(context.tr(NavText.plans)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(plansProvider.notifier).loadPlans(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(),
        icon: const Icon(Icons.add),
        label: Text(context.tr(PlansText.addPlan)),
      ),
      body: ContentWidth(
        child: plansState.isLoading
            ? const AppLoadingView()
            : plansState.error != null && plansState.plans.isEmpty
            ? _buildErrorView(plansState.error!)
            : plansState.plans.isEmpty
            ? AppEmptyView(
                icon: Icons.inventory_2_outlined,
                title: context.tr(PlansText.noPlansYet),
                message: context.tr(PlansText.createAPlanToStart),
              )
            : _buildPlanList(plansState.plans, currencyFormat),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref.read(plansProvider.notifier).loadPlans(),
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
                    : context.colors.surfaceContainerHigh,
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
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(plan.name, style: context.text.titleMedium),
                            if (plan.badgeText != null &&
                                plan.badgeText!.isNotEmpty)
                              StatusBadge(
                                label: plan.badgeText!,
                                tone: StatusTone.neutral,
                              ),
                          ],
                        ),
                        Text(
                          plan.code,
                          style: TextStyle(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: plan.isActive,
                    onChanged: (value) => _setPlanActive(plan, value),
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
                        context.tr(PlansText.monthly),
                        currencyFormat.format(plan.priceMonthly),
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: context.colors.outline,
                      ),
                      _buildPriceColumn(
                        context.tr(PlansText.yearly),
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
                        context.tr(PlansText.employees),
                      ),
                      _buildLimitItem(
                        Icons.inventory,
                        plan.maxProducts?.toString() ?? '∞',
                        context.tr(PlansText.products),
                      ),
                      _buildLimitItem(
                        Icons.receipt_long,
                        plan.maxOrdersPerMonth?.toString() ?? '∞',
                        context.tr(PlansText.ordersMo),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(PlansText.active(plan.activeSubscriptions)),
                        style: TextStyle(color: context.status.success),
                      ),
                      Text(
                        context.tr(PlansText.total(plan.totalSubscriptions)),
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
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
                color: context.colors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (plan.isTrialAvailable)
                    Text(
                      context.tr(PlansText.daysTrial(plan.trialDays)),
                      style: TextStyle(
                        color: context.status.info,
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
                    label: Text(context.tr(CommonText.edit)),
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
        Text(
          label,
          style: TextStyle(
            color: context.colors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
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
        Icon(icon, color: context.colors.onSurfaceVariant, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: context.colors.onSurfaceVariant),
        ),
      ],
    );
  }

  void _showCreatePlanDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<bool>(builder: (_) => const EditPlanPage()));
  }
}
