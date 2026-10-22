import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/unit_form.dart';

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
                    ? const LoadMoreIndicator()
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
                    Icon(Icons.star_outline_rounded),
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

  void _showCreateDialog() => _openForm();

  void _showEditDialog(Unit unit) => _openForm(unit);

  Future<void> _openForm([Unit? existing]) async {
    final notifier = ref.read(unitsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showUnitForm(
      context,
      existing: existing,
      save: (create, update) async {
        final ok = create != null
            ? await notifier.createUnit(create)
            : await notifier.updateUnit(existing!.id, update!);
        if (!ok) throw Exception(ref.read(unitsProvider).error);
      },
    );
    if (saved) {
      messenger.showSuccess(existing == null ? 'Unit created' : 'Unit updated');
    }
  }

  /// Confirms, runs [action], and reports the outcome with the server's reason
  /// on failure.
  Future<void> _confirmUnitAction(
    Unit unit, {
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    required String done,
    required String failed,
    required Future<bool> Function(UnitsNotifier notifier) action,
    bool destructive = false,
  }) async {
    final ok = await AppDialogs.confirm(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
      icon: icon,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final success = await action(ref.read(unitsProvider.notifier));
    if (success) {
      messenger.showSuccess(done);
    } else {
      final reason = ref.read(unitsProvider).error;
      messenger.showError(
        reason == null ? failed : '$failed: ${friendlyError(reason)}',
      );
    }
  }

  void _showActivateDialog(Unit unit) => _confirmUnitAction(
    unit,
    title: 'Activate "${unit.displayName()}"?',
    message: 'The unit becomes available for use immediately.',
    confirmLabel: 'Activate',
    icon: Icons.visibility_outlined,
    done: 'Unit activated',
    failed: 'Could not activate unit',
    action: (n) => n.activateUnit(unit.id),
  );

  void _showDeactivateDialog(Unit unit) => _confirmUnitAction(
    unit,
    title: 'Deactivate "${unit.displayName()}"?',
    message: 'The unit can no longer be used. You can activate it again later.',
    confirmLabel: 'Deactivate',
    icon: Icons.visibility_off_outlined,
    done: 'Unit deactivated',
    failed: 'Could not deactivate unit',
    action: (n) => n.deactivateUnit(unit.id),
  );

  void _showDeleteDialog(Unit unit) => _confirmUnitAction(
    unit,
    title: 'Delete "${unit.displayName()}"?',
    message:
        'The unit is removed from every list. It cannot be restored from '
        'this console.',
    confirmLabel: 'Delete',
    destructive: true,
    icon: Icons.delete_outline_rounded,
    done: 'Unit deleted',
    failed: 'Could not delete unit',
    action: (n) => n.deleteUnit(unit.id),
  );

  Future<void> _showSetDefaultDialog(Unit unit) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Set as default?',
      message:
          '"${unit.displayName()}" becomes the default unit for the '
          '${unit.category} category, replacing the current default.',
      confirmLabel: 'Set as default',
      icon: Icons.star_outline_rounded,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(unitsProvider.notifier)
        .setUnitDefault(unit.id);
    if (success) {
      messenger.showSuccess('Unit set as default');
    } else {
      messenger.showError('Failed to set default unit');
    }
  }
}
