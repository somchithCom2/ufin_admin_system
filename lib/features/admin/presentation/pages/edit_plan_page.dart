import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class EditPlanPage extends ConsumerStatefulWidget {
  final AdminPlan plan;

  const EditPlanPage({super.key, required this.plan});

  @override
  ConsumerState<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends ConsumerState<EditPlanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceMonthlyController;
  late TextEditingController _priceYearlyController;
  late TextEditingController _maxEmployeesController;
  late TextEditingController _maxProductsController;
  late TextEditingController _maxOrdersController;
  late TextEditingController _maxStorageController;
  late TextEditingController _trialDaysController;
  late TextEditingController _displayOrderController;
  late TextEditingController _badgeTextController;

  late bool _isTrialAvailable;
  late bool _isActive;
  Map<String, dynamic> _features = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
    _descriptionController = TextEditingController(
      text: widget.plan.description ?? '',
    );
    _priceMonthlyController = TextEditingController(
      text: widget.plan.priceMonthly.toStringAsFixed(0),
    );
    _priceYearlyController = TextEditingController(
      text: widget.plan.priceYearly.toStringAsFixed(0),
    );
    _maxEmployeesController = TextEditingController(
      text: widget.plan.maxEmployees?.toString() ?? '',
    );
    _maxProductsController = TextEditingController(
      text: widget.plan.maxProducts?.toString() ?? '',
    );
    _maxOrdersController = TextEditingController(
      text: widget.plan.maxOrdersPerMonth?.toString() ?? '',
    );
    _maxStorageController = TextEditingController(
      text: widget.plan.maxStorageMb?.toString() ?? '',
    );
    _trialDaysController = TextEditingController(
      text: widget.plan.trialDays.toString(),
    );
    _displayOrderController = TextEditingController(
      text: widget.plan.displayOrder.toString(),
    );
    _badgeTextController = TextEditingController(
      text: widget.plan.badgeText ?? '',
    );
    _isTrialAvailable = widget.plan.isTrialAvailable;
    _isActive = widget.plan.isActive;
    _features = Map<String, dynamic>.from(widget.plan.features);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceMonthlyController.dispose();
    _priceYearlyController.dispose();
    _maxEmployeesController.dispose();
    _maxProductsController.dispose();
    _maxOrdersController.dispose();
    _maxStorageController.dispose();
    _trialDaysController.dispose();
    _displayOrderController.dispose();
    _badgeTextController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = UpdatePlanRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priceMonthly: double.tryParse(_priceMonthlyController.text) ?? 0,
      priceYearly: double.tryParse(_priceYearlyController.text) ?? 0,
      maxEmployees: int.tryParse(_maxEmployeesController.text),
      maxProducts: int.tryParse(_maxProductsController.text),
      maxOrdersPerMonth: int.tryParse(_maxOrdersController.text),
      maxStorageMb: int.tryParse(_maxStorageController.text),
      isTrialAvailable: _isTrialAvailable,
      trialDays: int.tryParse(_trialDaysController.text) ?? 0,
      displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
      badgeText: _badgeTextController.text.trim().isEmpty
          ? null
          : _badgeTextController.text.trim(),
      isActive: _isActive,
      features: _features,
    );

    final success = await ref
        .read(planDetailProvider.notifier)
        .updatePlan(widget.plan.id, request);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final error = ref.read(planDetailProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to update plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Plan'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info Section
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name *',
                        hintText: 'e.g., Premium Plan',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Plan name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Plan description...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _displayOrderController,
                            decoration: const InputDecoration(
                              labelText: 'Display Order',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _badgeTextController,
                            decoration: const InputDecoration(
                              labelText: 'Badge Text',
                              hintText: 'e.g., POPULAR',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pricing Section
            _buildSectionTitle('Pricing'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceMonthlyController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Price (₭)',
                          prefixText: '₭ ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _priceYearlyController,
                        decoration: const InputDecoration(
                          labelText: 'Yearly Price (₭)',
                          prefixText: '₭ ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Limits Section
            _buildSectionTitle('Limits (leave empty for unlimited)'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxEmployeesController,
                            decoration: const InputDecoration(
                              labelText: 'Max Employees',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxProductsController,
                            decoration: const InputDecoration(
                              labelText: 'Max Products',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxOrdersController,
                            decoration: const InputDecoration(
                              labelText: 'Max Orders/Month',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxStorageController,
                            decoration: const InputDecoration(
                              labelText: 'Max Storage (MB)',
                              hintText: 'Unlimited',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Trial Section
            _buildSectionTitle('Trial Settings'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Trial Available'),
                      subtitle: const Text('Allow trial period for this plan'),
                      value: _isTrialAvailable,
                      onChanged: (value) {
                        setState(() => _isTrialAvailable = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isTrialAvailable) ...[
                      const Divider(),
                      TextFormField(
                        controller: _trialDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Trial Days',
                          suffixText: 'days',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Features Section
            _buildSectionTitle('Features'),
            const SizedBox(height: 8),
            _buildFeaturesCard(),
            const SizedBox(height: 16),

            // Status Section
            _buildSectionTitle('Status'),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(
                  _isActive
                      ? 'Plan is visible and can be subscribed to'
                      : 'Plan is hidden from subscription options',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

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
