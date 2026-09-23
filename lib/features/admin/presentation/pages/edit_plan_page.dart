import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class EditPlanPage extends ConsumerStatefulWidget {
  final AdminPlan? plan;
  const EditPlanPage({super.key, this.plan});
  @override
  ConsumerState<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends ConsumerState<EditPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _currency = TextEditingController();
  final _monthly = TextEditingController();
  final _yearly = TextEditingController();
  final _trialDays = TextEditingController();
  final _order = TextEditingController();
  final _badge = TextEditingController();
  final _names = <String, TextEditingController>{};
  final _descriptions = <String, TextEditingController>{};
  final _limits = <String, TextEditingController>{};
  Map<String, dynamic> _features = {};
  bool _trial = false;
  bool _active = true;
  int _featureRevision = 0;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _code.text = plan?.code ?? '';
    _currency.text = plan?.currency ?? 'LAK';
    _monthly.text = plan?.priceMonthly.toString() ?? '0';
    _yearly.text = plan?.priceYearly.toString() ?? '0';
    _trialDays.text = plan?.trialDays.toString() ?? '14';
    _order.text = plan?.displayOrder.toString() ?? '0';
    _badge.text = plan?.badgeText ?? '';
    _trial = plan?.isTrialAvailable ?? false;
    _active = plan?.isActive ?? true;
    final names = plan?.localizedNames ?? const <String, String>{};
    final descriptions =
        plan?.localizedDescriptions ?? const <String, String>{};
    for (final locale in {
      'en',
      'lo',
      'th',
      ...names.keys,
      ...descriptions.keys,
    }) {
      _names[locale] = TextEditingController(
        text:
            names[locale] ??
            (locale == 'en' && names.isEmpty ? plan?.name : null),
      );
      _descriptions[locale] = TextEditingController(
        text:
            descriptions[locale] ??
            (locale == 'en' && descriptions.isEmpty ? plan?.description : null),
      );
    }
    for (final entry in <String, int?>{
      'Max Employees': plan?.maxEmployees,
      'Max Products': plan?.maxProducts,
      'Max Orders/Month': plan?.maxOrdersPerMonth,
      'Max Storage (MB)': plan?.maxStorageMb,
    }.entries) {
      _limits[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }
    _features = Map<String, dynamic>.from(plan?.features ?? {});
  }

  @override
  void dispose() {
    for (final controller in [
      _code,
      _currency,
      _monthly,
      _yearly,
      _trialDays,
      _order,
      _badge,
      ..._names.values,
      ..._descriptions.values,
      ..._limits.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _integerError(
    String? text, {
    bool optional = false,
    int minimum = 0,
  }) {
    if (optional && (text == null || text.trim().isEmpty)) return null;
    final value = int.tryParse(text?.trim() ?? '');
    if (value == null || value < minimum || value > 2147483647) {
      return 'Enter a whole number from $minimum to 2147483647';
    }
    return null;
  }

  String? _priceError(String? text) {
    final value = double.tryParse(text?.trim() ?? '');
    if (value == null ||
        !value.isFinite ||
        value < 0 ||
        value >= 10000000000000 ||
        !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text!.trim())) {
      return 'Enter a nonnegative price with at most 2 decimals';
    }
    return null;
  }

  Map<String, String> _translations(
    Map<String, TextEditingController> controllers,
  ) => {
    for (final entry in controllers.entries)
      if (entry.value.text.trim().isNotEmpty)
        entry.key: entry.value.text.trim(),
  };

  Future<void> _savePlan() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final repository = ref.read(adminRepositoryProvider);
      final names = _translations(_names);
      final descriptions = _translations(_descriptions);
      final limits = _limits.values
          .map((c) => int.tryParse(c.text.trim()))
          .toList();
      if (widget.plan == null) {
        await repository.createPlan(
          CreatePlanRequest(
            code: _code.text.trim(),
            name: names,
            description: descriptions,
            currency: _currency.text.trim().toUpperCase(),
            priceMonthly: double.parse(_monthly.text.trim()),
            priceYearly: double.parse(_yearly.text.trim()),
            maxEmployees: limits[0],
            maxProducts: limits[1],
            maxOrdersPerMonth: limits[2],
            maxStorageMb: limits[3],
            features: _features,
            isTrialAvailable: _trial,
            trialDays: _trial ? int.parse(_trialDays.text) : 0,
            displayOrder: int.parse(_order.text),
            badgeText: _badge.text.trim(),
          ),
        );
      } else {
        await repository.updatePlan(
          widget.plan!.id,
          UpdatePlanRequest(
            name: names,
            description: descriptions,
            currency: _currency.text.trim().toUpperCase(),
            priceMonthly: double.parse(_monthly.text.trim()),
            priceYearly: double.parse(_yearly.text.trim()),
            replaceLimits: true,
            maxEmployees: limits[0],
            maxProducts: limits[1],
            maxOrdersPerMonth: limits[2],
            maxStorageMb: limits[3],
            features: _features,
            isTrialAvailable: _trial,
            trialDays: _trial ? int.parse(_trialDays.text) : 0,
            displayOrder: int.parse(_order.text),
            badgeText: _badge.text.trim(),
            isActive: _active,
          ),
        );
      }
      if (!mounted) return;
      ref.read(plansProvider.notifier).loadPlans();
      if (widget.plan != null) {
        ref.read(planDetailProvider.notifier).loadPlan(widget.plan!.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.plan == null
                ? 'Plan created successfully'
                : 'Plan updated successfully',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.plan == null ? 'Create Plan' : 'Edit Plan'),
          actions: [
            TextButton.icon(
              onPressed: _isSaving ? null : _savePlan,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _isSaving,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _code,
                    enabled: widget.plan == null,
                    maxLength: 50,
                    decoration: const InputDecoration(labelText: 'Plan Code *'),
                    validator: (v) =>
                        v == null ||
                            !RegExp(r'^[A-Za-z0-9_-]{1,50}$').hasMatch(v.trim())
                        ? 'Use letters, numbers, underscores or hyphens'
                        : null,
                  ),
                  for (final locale in _names.keys) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _names[locale],
                      decoration: InputDecoration(
                        labelText: 'Plan Name ($locale)',
                      ),
                      validator: (_) => _translations(_names).isEmpty
                          ? 'Enter a name in at least one language'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptions[locale],
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description ($locale)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _currency,
                    maxLength: 3,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    validator: (v) =>
                        RegExp(r'^[A-Za-z]{3}$').hasMatch(v?.trim() ?? '')
                        ? null
                        : 'Enter a 3-letter currency code',
                  ),
                  _numberField('Monthly Price', _monthly, _priceError),
                  _numberField('Yearly Price', _yearly, _priceError),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Limits (leave empty for unlimited)'),
                  ),
                  for (final entry in _limits.entries)
                    _numberField(
                      entry.key,
                      entry.value,
                      (v) => _integerError(v, optional: true),
                    ),
                  _numberField('Display Order', _order, _integerError),
                  TextFormField(
                    controller: _badge,
                    maxLength: 50,
                    decoration: const InputDecoration(labelText: 'Badge Text'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Trial Available'),
                    value: _trial,
                    onChanged: (v) => setState(() => _trial = v),
                  ),
                  if (_trial)
                    _numberField(
                      'Trial Days',
                      _trialDays,
                      (v) => _integerError(v, minimum: 1),
                    ),
                  const SizedBox(height: 12),
                  _buildFeaturesCard(),
                  if (widget.plan == null &&
                      ref.watch(plansProvider).plans.isNotEmpty)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Copy features from an existing plan',
                      ),
                      items: ref
                          .watch(plansProvider)
                          .plans
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        final source = ref
                            .read(plansProvider)
                            .plans
                            .firstWhere((p) => p.id == id);
                        setState(() {
                          _features = Map<String, dynamic>.from(
                            source.features,
                          );
                          _featureRevision++;
                        });
                      },
                    ),
                  if (widget.plan != null)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: _active,
                      onChanged: (v) => setState(() => _active = v),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
    ),
  );

  Widget _buildFeaturesCard() {
    // Group features by category
    final boolFeatures = <String, bool>{};
    final stringFeatures = <String, String>{};
    final nullableIntFeatures = <String, int?>{};

    for (final entry in _features.entries) {
      if (entry.value is bool) {
        boolFeatures[entry.key] = entry.value;
      } else if (entry.value is String) {
        stringFeatures[entry.key] = entry.value;
      } else if (entry.value == null || entry.value is int) {
        nullableIntFeatures[entry.key] = entry.value;
      }
    }

    return Card(
      key: ValueKey(_featureRevision),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boolean toggles
            if (boolFeatures.isNotEmpty) ...[
              Text(
                'Feature Flags',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: boolFeatures.entries.map((entry) {
                  return FilterChip(
                    label: Text(_formatFeatureName(entry.key)),
                    selected: entry.value,
                    onSelected: (selected) {
                      setState(() {
                        _features[entry.key] = selected;
                      });
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const Divider(height: 24),
            ],

            // String features
            if (stringFeatures.isNotEmpty) ...[
              Text(
                'Support & Tier Settings',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...stringFeatures.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(_formatFeatureName(entry.key)),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: entry.value,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'e.g., ${_getSupportHint(entry.key)}',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _features[entry.key] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
            ],

            // Nullable int features
            if (nullableIntFeatures.isNotEmpty) ...[
              Text(
                'Limits (leave empty for unlimited)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...nullableIntFeatures.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(_formatFeatureName(entry.key)),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: entry.value?.toString() ?? '',
                          validator: (value) =>
                              _integerError(value, optional: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Unlimited',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {
                              _features[entry.key] = value.isEmpty
                                  ? null
                                  : int.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFeatureName(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  String _getSupportHint(String key) {
    if (key == 'support') {
      return 'community, email, dedicated';
    }
    return 'basic, premium';
  }
}
