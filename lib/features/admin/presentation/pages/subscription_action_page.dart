import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_picker.dart';

enum SubscriptionAction { create, cancel, reactivate }

class SubscriptionActionPage extends ConsumerStatefulWidget {
  final SubscriptionAction action;
  final AdminSubscription? subscription;
  const SubscriptionActionPage({
    super.key,
    required this.action,
    this.subscription,
  });
  @override
  ConsumerState<SubscriptionActionPage> createState() =>
      _SubscriptionActionPageState();
}

class _SubscriptionActionPageState
    extends ConsumerState<SubscriptionActionPage> {
  final _form = GlobalKey<FormState>();
  ShopSelection? _shop;
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  List<AdminPlan> _plans = [];
  String? _planCode;
  String _cycle = 'monthly';
  bool _trial = false;
  bool _immediate = false;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  String get _title => switch (widget.action) {
    SubscriptionAction.create => context.tr(SubsText.createSubscription2),
    SubscriptionAction.cancel => context.tr(SubsText.cancelSubscription2),
    SubscriptionAction.reactivate => context.tr(
      SubsText.reactivateSubscription,
    ),
  };

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    if (sub != null) {
      _shop = ShopSelection(id: sub.shopId, name: sub.shopName);
    }
    _cycle = switch (widget.subscription?.billingCycle) {
      'yearly' => 'yearly',
      'lifetime' => 'lifetime',
      _ => 'monthly',
    };
    if (widget.action != SubscriptionAction.cancel) _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await ref.read(adminRepositoryProvider).getPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans.where((p) => p.isActive).toList();
        final current = widget.subscription?.planCode;
        _planCode = _plans.any((p) => p.code == current)
            ? current
            : _plans.firstOrNull?.code;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(adminRepositoryProvider);
      final shopId = _shop!.id;
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      final result = switch (widget.action) {
        SubscriptionAction.create => await repository.createSubscription(
          shopId,
          CreateSubscriptionRequest(
            planCode: _planCode!,
            billingCycle: _cycle,
            startAsTrial: _trial,
            notes: notes,
          ),
        ),
        SubscriptionAction.cancel => await repository.cancelSubscription(
          shopId,
          CancelSubscriptionRequest(
            reason: _reason.text.trim(),
            immediate: _immediate,
            notes: notes,
          ),
        ),
        SubscriptionAction.reactivate =>
          await repository.reactivateSubscription(
            shopId,
            ReactivateSubscriptionRequest(
              planCode: _planCode,
              billingCycle: _cycle,
              reason: _reason.text.trim(),
              notes: notes,
            ),
          ),
      };
      if (!mounted) return;
      ref.read(subscriptionsProvider.notifier).refresh();
      ref.read(dashboardProvider.notifier).loadDashboard();
      Navigator.of(context).pop(result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _plans.where((p) => p.code == _planCode).firstOrNull;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: _loading
            ? const AppLoadingView()
            : AbsorbPointer(
                absorbing: _saving,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          if (_plans.isEmpty &&
                              widget.action != SubscriptionAction.cancel)
                            TextButton(
                              onPressed: _loadPlans,
                              child: Text(
                                context.tr(SubsText.retryLoadingPlans),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                        ShopPickerField(
                          initialValue: _shop,
                          locked: widget.subscription != null,
                          enabled: !_saving,
                          onChanged: (shop) => _shop = shop,
                        ),
                        const SizedBox(height: 16),
                        if (widget.action != SubscriptionAction.cancel) ...[
                          DropdownButtonFormField<String>(
                            initialValue: _planCode,
                            decoration: InputDecoration(
                              labelText: context.tr(CommonText.plan),
                            ),
                            items: _plans
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p.code,
                                    child: Text('${p.name} (${p.code})'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _planCode = v;
                              _trial = false;
                            }),
                            validator: (v) => v == null
                                ? context.tr(SubsText.selectAnActivePlan)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _cycle,
                            decoration: InputDecoration(
                              labelText: context.tr(SubsText.billingCycle2),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text(context.tr(SubsText.monthly)),
                              ),
                              DropdownMenuItem(
                                value: 'yearly',
                                child: Text(context.tr(SubsText.yearly)),
                              ),
                              DropdownMenuItem(
                                value: 'lifetime',
                                child: Text(context.tr(SubsText.lifetime)),
                              ),
                            ],
                            onChanged: (v) => setState(() => _cycle = v!),
                          ),
                          if (selected != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                _cycle == 'lifetime'
                                    ? context.tr(
                                        SubsText.oneOffPriceNeverExpires(
                                          selected.priceYearly,
                                          selected.currency,
                                        ),
                                      )
                                    : context.tr(
                                        SubsText.planPrice(
                                          _cycle == 'yearly'
                                              ? selected.priceYearly
                                              : selected.priceMonthly,
                                          selected.currency,
                                        ),
                                      ),
                              ),
                            ),
                          if (widget.action == SubscriptionAction.create &&
                              selected?.isTrialAvailable == true &&
                              selected!.trialDays > 0)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                context.tr(
                                  SubsText.startWithTrialDays(
                                    selected.trialDays,
                                  ),
                                ),
                              ),
                              value: _trial,
                              onChanged: (v) => setState(() => _trial = v),
                            ),
                          Text(
                            _cycle == 'lifetime'
                                ? context.tr(
                                    SubsText.thisChangesSubscriptionAccessA,
                                  )
                                : context.tr(
                                    SubsText.thisChangesSubscriptionAccessAuto,
                                  ),
                          ),
                        ],
                        if (widget.action == SubscriptionAction.cancel) ...[
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(context.tr(SubsText.cancelImmediately)),
                            value: _immediate,
                            onChanged: (v) => setState(() => _immediate = v),
                          ),
                          Text(
                            _immediate
                                ? context.tr(SubsText.thePaidPlanEndsNow)
                                : context.tr(
                                    SubsText.accessContinuesUntilTheCurrent,
                                  ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (widget.action != SubscriptionAction.create)
                          TextFormField(
                            controller: _reason,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              labelText: context.tr(CommonText.reason),
                            ),
                            validator: (v) =>
                                widget.action == SubscriptionAction.cancel &&
                                    (v == null || v.trim().isEmpty)
                                ? context.tr(
                                    SubsText.aCancellationReasonIsRequired,
                                  )
                                : null,
                          ),
                        TextFormField(
                          controller: _notes,
                          maxLines: 3,
                          maxLength: 4000,
                          decoration: InputDecoration(
                            labelText: context.tr(CommonText.notes),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _saving ? null : _submit,
                          child: Text(
                            _saving ? context.tr(CommonText.saving) : _title,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
