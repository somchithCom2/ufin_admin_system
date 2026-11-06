import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
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
        title: Text(context.tr(NavText.units)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const AppIcon(AppIcons.refresh),
            onPressed: () => ref.read(unitsProvider.notifier).loadUnits(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const AppIcon(AppIcons.add),
        label: Text(context.tr(ShopTypeText.addUnit)),
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
                  ? AppEmptyView(
                      icon: AppIcons.ruler,
                      title: context.tr(ShopTypeText.noUnitsFound),
                      message: context.tr(ShopTypeText.tryADifferentFilterOr),
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

    final notifier = ref.read(unitsProvider.notifier);
    return FilterBar(
      filters: [
        FilterSelect<String>(
          icon: AppIcons.shapes,
          label: context.tr(ShopTypeText.category),
          value: state.categoryFilter,
          allLabel: context.tr(CommonText.all),
          options: [
            for (final cat in categories)
              FilterOption(
                cat,
                unitCategoryLabel(context, cat),
                icon: _getCategoryIcon(cat),
              ),
          ],
          onChanged: notifier.setCategoryFilter,
        ),
        FilterSelect<bool>(
          icon: AppIcons.flag,
          label: context.tr(CommonText.status),
          value: state.isActiveFilter,
          allLabel: context.tr(CommonText.all),
          options: [
            FilterOption(true, context.tr(ShopTypeText.active2)),
            FilterOption(false, context.tr(ShopTypeText.inactive2)),
          ],
          onChanged: notifier.setActiveFilter,
        ),
      ],
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
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
            child: AppIcon(
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
                context.tr(ShopTypeText.code(unit.code)),
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
                        context.tr(ShopTypeText.defaultText),
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
            icon: const AppIcon(AppIcons.moreVertical),
            onSelected: (action) => _handleAction(unit, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    AppIcon(AppIcons.eye),
                    SizedBox(width: 8),
                    Text(context.tr(ShopTypeText.viewDetails2)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    AppIcon(AppIcons.edit),
                    SizedBox(width: 8),
                    Text(context.tr(CommonText.edit)),
                  ],
                ),
              ),
              if (unit.isActive)
                PopupMenuItem(
                  value: 'deactivate',
                  child: Row(
                    children: [
                      AppIcon(AppIcons.eyeOff, color: context.status.warning),
                      SizedBox(width: 8),
                      Text(context.tr(ShopTypeText.deactivate)),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      AppIcon(AppIcons.eye, color: context.status.success),
                      SizedBox(width: 8),
                      Text(context.tr(ShopTypeText.activate)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'set-default',
                child: Row(
                  children: [
                    AppIcon(AppIcons.star),
                    SizedBox(width: 8),
                    Text(context.tr(ShopTypeText.setAsDefault)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    AppIcon(AppIcons.delete, color: context.colors.error),
                    SizedBox(width: 8),
                    Text(context.tr(CommonText.delete)),
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
      label: isActive
          ? context.tr(ShopTypeText.active2)
          : context.tr(ShopTypeText.inactive2),
      tone: isActive ? StatusTone.success : StatusTone.neutral,
    );
  }

  AppIconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'piece':
        return AppIcons.hash;
      case 'weight':
        return AppIcons.scale;
      case 'volume':
        return AppIcons.droplet;
      case 'length':
        return AppIcons.ruler;
      case 'area':
        return AppIcons.grid;
      case 'custom':
        return AppIcons.settings;
      default:
        return AppIcons.shapes;
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
                    child: AppIcon(
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
              _buildDetailSection(context.tr(ShopTypeText.information2), [
                _buildDetailRow(context.tr(CommonText.code), unit.code),
                _buildDetailRow(
                  context.tr(ShopTypeText.abbreviation),
                  unit.abbreviation,
                ),
                _buildDetailRow(
                  context.tr(ShopTypeText.category),
                  unitCategoryLabel(context, unit.category),
                ),
                if (unit.description?.isNotEmpty == true)
                  _buildDetailRow(
                    context.tr(CommonText.description),
                    unit.description!,
                  ),
                _buildDetailRow(
                  context.tr(ShopTypeText.displayOrder),
                  unit.sortOrder.toString(),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(ShopTypeText.multilingualNames), [
                ...unit.name.entries.map(
                  (e) => _buildDetailRow(
                    e.key.toUpperCase(),
                    e.value?.toString() ?? 'N/A',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(CommonText.status), [
                _buildDetailRow(
                  context.tr(ShopTypeText.active2),
                  unit.isActive
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
                _buildDetailRow(
                  context.tr(ShopTypeText.defaultText2),
                  unit.isDefault
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(ShopTypeText.timestamps2), [
                _buildDetailRow(
                  context.tr(CommonText.created),
                  unit.createdAt?.toString().split(' ')[0] ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.updated),
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
      messenger.showSuccess(
        existing == null
            ? ShopTypeText.unitCreated.current
            : ShopTypeText.unitUpdated.current,
      );
    }
  }

  /// Confirms, runs [action], and reports the outcome with the server's reason
  /// on failure.
  Future<void> _confirmUnitAction(
    Unit unit, {
    required String title,
    required String message,
    required String confirmLabel,
    required AppIconData icon,
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
    title: context.tr(ShopTypeText.activate2(unit.displayName())),
    message: context.tr(ShopTypeText.theUnitBecomesAvailableFor),
    confirmLabel: context.tr(ShopTypeText.activate),
    icon: AppIcons.eye,
    done: context.tr(ShopTypeText.unitActivated),
    failed: context.tr(ShopTypeText.couldNotActivateUnit),
    action: (n) => n.activateUnit(unit.id),
  );

  void _showDeactivateDialog(Unit unit) => _confirmUnitAction(
    unit,
    title: context.tr(ShopTypeText.deactivate2(unit.displayName())),
    message: context.tr(ShopTypeText.theUnitCanNoLonger),
    confirmLabel: context.tr(ShopTypeText.deactivate),
    icon: AppIcons.eyeOff,
    done: context.tr(ShopTypeText.unitDeactivated),
    failed: context.tr(ShopTypeText.couldNotDeactivateUnit),
    action: (n) => n.deactivateUnit(unit.id),
  );

  void _showDeleteDialog(Unit unit) => _confirmUnitAction(
    unit,
    title: context.tr(ShopTypeText.delete2(unit.displayName())),
    message: context.tr(ShopTypeText.theUnitIsRemovedFrom),
    confirmLabel: context.tr(CommonText.delete),
    destructive: true,
    icon: AppIcons.delete,
    done: context.tr(ShopTypeText.unitDeleted),
    failed: context.tr(ShopTypeText.couldNotDeleteUnit),
    action: (n) => n.deleteUnit(unit.id),
  );

  Future<void> _showSetDefaultDialog(Unit unit) async {
    final ok = await AppDialogs.confirm(
      context,
      title: context.tr(ShopTypeText.setAsDefault2),
      message: context.tr(
        ShopTypeText.becomesTheDefaultUnitFor(
          unit.displayName(),
          unitCategoryLabel(context, unit.category),
        ),
      ),
      confirmLabel: context.tr(ShopTypeText.setAsDefault3),
      icon: AppIcons.star,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(unitsProvider.notifier)
        .setUnitDefault(unit.id);
    if (success) {
      messenger.showSuccess(ShopTypeText.unitSetAsDefault.current);
    } else {
      messenger.showError(ShopTypeText.failedToSetDefaultUnit.current);
    }
  }
}
