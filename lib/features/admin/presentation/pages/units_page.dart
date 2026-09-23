import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class UnitsPage extends ConsumerStatefulWidget {
  const UnitsPage({super.key});

  @override
  ConsumerState<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends ConsumerState<UnitsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unitsProvider.notifier).loadUnits();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(unitsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsState = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Units'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(unitsProvider.notifier).loadUnits(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Unit'),
      ),
      body: ContentWidth(
        child: Column(
          children: [
            _buildFilterBar(unitsState),
            Expanded(
              child: unitsState.isLoading && unitsState.units.isEmpty
                  ? const AppLoadingView()
                  : unitsState.error != null && unitsState.units.isEmpty
                  ? _buildErrorView(unitsState.error!)
                  : unitsState.units.isEmpty
                  ? const AppEmptyView(
                      icon: Icons.straighten_outlined,
                      title: 'No units found',
                      message: 'Try a different filter or add a new unit.',
                    )
                  : _buildUnitsList(unitsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(UnitsState state) {
    const categories = [
      'piece',
      'weight',
      'volume',
      'length',
      'area',
      'custom',
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: state.categoryFilter == null,
                    onSelected: (_) => ref
                        .read(unitsProvider.notifier)
                        .setCategoryFilter(null),
                  ),
                ),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(cat),
                      selected: state.categoryFilter == cat,
                      onSelected: (_) => ref
                          .read(unitsProvider.notifier)
                          .setCategoryFilter(cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                FilterChip(
                  label: const Text('Active'),
                  selected: state.isActiveFilter == true,
                  onSelected: (_) => ref
                      .read(unitsProvider.notifier)
                      .setActiveFilter(
                        state.isActiveFilter == true ? null : true,
                      ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: state.isActiveFilter == false,
                  onSelected: (_) => ref
                      .read(unitsProvider.notifier)
                      .setActiveFilter(
                        state.isActiveFilter == false ? null : false,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref.read(unitsProvider.notifier).loadUnits(),
    );
  }

  Widget _buildUnitsList(UnitsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(unitsProvider.notifier).loadUnits();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: state.units.length + (state.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.units.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox(),
              ),
            );
          }
          final unit = state.units[index];
          return _buildUnitCard(unit);
        },
      ),
    );
  }

  Widget _buildUnitCard(Unit unit) {
    final isInactive = !unit.isActive;
    return Opacity(
      opacity: isInactive ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: unit.isActive
                ? context.status.success.withValues(alpha: 0.1)
                : context.status.neutral.withValues(alpha: 0.1),
            child: Icon(
              _getCategoryIcon(unit.category),
              color: unit.isActive
                  ? context.status.success
                  : context.status.neutral,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unit.displayNameMultilingual(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: isInactive ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                unit.abbreviation,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code: ${unit.code}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  _buildStatusChip(unit.isActive),
                  if (unit.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.status.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.status.info,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleAction(unit, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (unit.isActive)
                PopupMenuItem(
                  value: 'deactivate',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off, color: context.status.warning),
                      SizedBox(width: 8),
                      Text('Deactivate'),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: context.status.success),
                      SizedBox(width: 8),
                      Text('Activate'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'set-default',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: context.colors.error),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: context.status.info),
                    SizedBox(width: 8),
                    Text('Restore'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _showDetailsDialog(unit),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return StatusBadge(
      label: isActive ? 'Active' : 'Inactive',
      tone: isActive ? StatusTone.success : StatusTone.neutral,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'piece':
        return Icons.looks_one;
      case 'weight':
        return Icons.balance;
      case 'volume':
        return Icons.water_drop;
      case 'length':
        return Icons.straighten;
      case 'area':
        return Icons.grid_3x3;
      case 'custom':
        return Icons.settings;
      default:
        return Icons.category;
    }
  }

  void _handleAction(Unit unit, String action) {
    switch (action) {
      case 'view':
        _showDetailsDialog(unit);
        break;
      case 'edit':
        _showEditDialog(unit);
        break;
      case 'activate':
        _showActivateDialog(unit);
        break;
      case 'deactivate':
        _showDeactivateDialog(unit);
        break;
      case 'delete':
        _showDeleteDialog(unit);
        break;
      case 'restore':
        _showRestoreDialog(unit);
        break;
      case 'set-default':
        _showSetDefaultDialog(unit);
        break;
    }
  }

  void _showDetailsDialog(Unit unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
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
                    color: context.colors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: unit.isActive
                        ? context.status.success.withValues(alpha: 0.1)
                        : context.status.neutral.withValues(alpha: 0.1),
                    child: Icon(
                      _getCategoryIcon(unit.category),
                      size: 30,
                      color: unit.isActive
                          ? context.status.success
                          : context.status.neutral,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.displayName(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(unit.code),
                        _buildStatusChip(unit.isActive),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Information', [
                _buildDetailRow('Code', unit.code),
                _buildDetailRow('Abbreviation', unit.abbreviation),
                _buildDetailRow('Category', unit.category),
                if (unit.description?.isNotEmpty == true)
                  _buildDetailRow('Description', unit.description!),
                _buildDetailRow('Display Order', unit.sortOrder.toString()),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Multilingual Names', [
                ...unit.name.entries.map(
                  (e) => _buildDetailRow(
                    e.key.toUpperCase(),
                    e.value?.toString() ?? 'N/A',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Status', [
                _buildDetailRow('Active', unit.isActive ? 'Yes' : 'No'),
                _buildDetailRow('Default', unit.isDefault ? 'Yes' : 'No'),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Timestamps', [
                _buildDetailRow(
                  'Created',
                  unit.createdAt?.toString().split(' ')[0] ?? 'N/A',
                ),
                _buildDetailRow(
                  'Updated',
                  unit.updatedAt?.toString().split(' ')[0] ?? 'N/A',
                ),
              ]),
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
          Text(label, style: TextStyle(color: context.colors.onSurfaceVariant)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final codeController = TextEditingController();
    final nameEnController = TextEditingController();
    final nameLoController = TextEditingController();
    final nameThController = TextEditingController();
    final nameViController = TextEditingController();
    final nameZhController = TextEditingController();
    final abbreviationController = TextEditingController();
    final descriptionController = TextEditingController();
    final sortOrderController = TextEditingController(text: '0');
    String? selectedCategory;
    bool isActive = true;
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create Unit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code *',
                      hintText: 'e.g., piece',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameEnController,
                    decoration: const InputDecoration(
                      labelText: 'Name (EN) *',
                      hintText: 'e.g., Piece',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameLoController,
                    decoration: const InputDecoration(
                      labelText: 'Name (LO)',
                      hintText: 'e.g., ຊີ້ນ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameThController,
                    decoration: const InputDecoration(labelText: 'Name (TH)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameViController,
                    decoration: const InputDecoration(labelText: 'Name (VI)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameZhController,
                    decoration: const InputDecoration(labelText: 'Name (ZH)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: abbreviationController,
                    decoration: const InputDecoration(
                      labelText: 'Abbreviation *',
                      hintText: 'e.g., pc',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category *'),
                    items:
                        [
                              'piece',
                              'weight',
                              'volume',
                              'length',
                              'area',
                              'custom',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortOrderController,
                    decoration: const InputDecoration(labelText: 'Sort Order'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Default'),
                    value: isDefault,
                    onChanged: (value) {
                      setDialogState(() => isDefault = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (codeController.text.isEmpty ||
                                nameEnController.text.isEmpty ||
                                abbreviationController.text.isEmpty ||
                                selectedCategory == null) {
                              AppFeedback.warning(
                                context,
                                'Code, Name (EN), Abbreviation, and Category are required',
                              );
                              return;
                            }
                            Navigator.pop(context);

                            final nameMap = <String, dynamic>{
                              'en': nameEnController.text,
                              if (nameLoController.text.isNotEmpty)
                                'lo': nameLoController.text,
                              if (nameThController.text.isNotEmpty)
                                'th': nameThController.text,
                              if (nameViController.text.isNotEmpty)
                                'vi': nameViController.text,
                              if (nameZhController.text.isNotEmpty)
                                'zh': nameZhController.text,
                            };

                            final request = CreateUnitRequest(
                              code: codeController.text,
                              name: nameMap,
                              abbreviation: abbreviationController.text,
                              category: selectedCategory!,
                              description: descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                              isActive: isActive,
                              isDefault: isDefault,
                              sortOrder: int.tryParse(sortOrderController.text),
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final success = await ref
                                .read(unitsProvider.notifier)
                                .createUnit(request);
                            if (success) {
                              messenger.showSuccess(
                                'Unit created successfully',
                              );
                            } else {
                              messenger.showError('Failed to create unit');
                            }
                          },
                          child: const Text('Create'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Unit unit) {
    final codeController = TextEditingController(text: unit.code);
    final nameEnController = TextEditingController(
      text: unit.name['en']?.toString() ?? '',
    );
    final nameLoController = TextEditingController(
      text: unit.name['lo']?.toString() ?? '',
    );
    final nameThController = TextEditingController(
      text: unit.name['th']?.toString() ?? '',
    );
    final nameViController = TextEditingController(
      text: unit.name['vi']?.toString() ?? '',
    );
    final nameZhController = TextEditingController(
      text: unit.name['zh']?.toString() ?? '',
    );
    final abbreviationController = TextEditingController(
      text: unit.abbreviation,
    );
    final descriptionController = TextEditingController(
      text: unit.description ?? '',
    );
    final sortOrderController = TextEditingController(
      text: unit.sortOrder.toString(),
    );
    String? selectedCategory = unit.category;
    bool isActive = unit.isActive;
    bool isDefault = unit.isDefault;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Unit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Code *'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameEnController,
                    decoration: const InputDecoration(labelText: 'Name (EN) *'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameLoController,
                    decoration: const InputDecoration(labelText: 'Name (LO)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameThController,
                    decoration: const InputDecoration(labelText: 'Name (TH)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameViController,
                    decoration: const InputDecoration(labelText: 'Name (VI)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameZhController,
                    decoration: const InputDecoration(labelText: 'Name (ZH)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: abbreviationController,
                    decoration: const InputDecoration(
                      labelText: 'Abbreviation *',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category *'),
                    items:
                        [
                              'piece',
                              'weight',
                              'volume',
                              'length',
                              'area',
                              'custom',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortOrderController,
                    decoration: const InputDecoration(labelText: 'Sort Order'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Default'),
                    value: isDefault,
                    onChanged: (value) {
                      setDialogState(() => isDefault = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (codeController.text.isEmpty ||
                                nameEnController.text.isEmpty ||
                                abbreviationController.text.isEmpty ||
                                selectedCategory == null) {
                              AppFeedback.warning(
                                context,
                                'Code, Name (EN), Abbreviation, and Category are required',
                              );
                              return;
                            }
                            Navigator.pop(context);

                            final nameMap = <String, dynamic>{
                              'en': nameEnController.text,
                              if (nameLoController.text.isNotEmpty)
                                'lo': nameLoController.text,
                              if (nameThController.text.isNotEmpty)
                                'th': nameThController.text,
                              if (nameViController.text.isNotEmpty)
                                'vi': nameViController.text,
                              if (nameZhController.text.isNotEmpty)
                                'zh': nameZhController.text,
                            };

                            final request = UpdateUnitRequest(
                              code: codeController.text,
                              name: nameMap,
                              abbreviation: abbreviationController.text,
                              category: selectedCategory,
                              description: descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                              isActive: isActive,
                              isDefault: isDefault,
                              sortOrder: int.tryParse(sortOrderController.text),
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final success = await ref
                                .read(unitsProvider.notifier)
                                .updateUnit(unit.id, request);
                            if (success) {
                              messenger.showSuccess(
                                'Unit updated successfully',
                              );
                            } else {
                              messenger.showError('Failed to update unit');
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActivateDialog(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Unit'),
        content: Text(
          'Are you sure you want to activate "${unit.displayName()}"?\n\n'
          'This unit will be available for use immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.status.success,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(unitsProvider.notifier)
                  .activateUnit(unit.id);
              if (success) {
                messenger.showSuccess('Unit activated successfully');
              } else {
                messenger.showError('Failed to activate unit');
              }
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Unit'),
        content: Text(
          'Are you sure you want to deactivate "${unit.displayName()}"?\n\n'
          'This unit will not be available for use, but can be reactivated later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.status.warning,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(unitsProvider.notifier)
                  .deactivateUnit(unit.id);
              if (success) {
                messenger.showSuccess('Unit deactivated successfully');
              } else {
                messenger.showError('Failed to deactivate unit');
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text(
          'Are you sure you want to delete "${unit.displayName()}"?\n\n'
          'This action CANNOT be undone. The unit will be removed from the system and hidden from queries. '
          'An audit trail will be maintained for compliance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(unitsProvider.notifier)
                  .deleteUnit(unit.id);
              if (success) {
                messenger.showSuccess('Unit deleted successfully');
              } else {
                messenger.showError('Failed to delete unit');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Unit'),
        content: Text(
          'Are you sure you want to restore "${unit.displayName()}"?\n\n'
          'This will recover the deleted unit and make it available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.status.info),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(unitsProvider.notifier)
                  .restoreUnit(unit.id);
              if (success) {
                messenger.showSuccess('Unit restored successfully');
              } else {
                messenger.showError('Failed to restore unit');
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showSetDefaultDialog(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Default'),
        content: Text(
          'Are you sure you want to set "${unit.displayName()}" as the default unit for the ${unit.category} category?\n\n'
          'This will remove the default from any other unit in this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(unitsProvider.notifier)
                  .setUnitDefault(unit.id);
              if (success) {
                messenger.showSuccess('Unit set as default');
              } else {
                messenger.showError('Failed to set default unit');
              }
            },
            child: const Text('Set as Default'),
          ),
        ],
      ),
    );
  }
}
