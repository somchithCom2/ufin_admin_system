import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_type_form.dart';

class ShopTypePage extends ConsumerStatefulWidget {
  const ShopTypePage({super.key});

  @override
  ConsumerState<ShopTypePage> createState() => _ShopTypePageState();
}

class _ShopTypePageState extends ConsumerState<ShopTypePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopTypesProvider.notifier).loadShopTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopTypesState = ref.watch(shopTypesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Shop Types'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(shopTypesProvider.notifier).loadShopTypes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Type'),
      ),
      body: ContentWidth(
        child: shopTypesState.isLoading
            ? const AppLoadingView()
            : shopTypesState.error != null && shopTypesState.shopTypes.isEmpty
            ? _buildErrorView(shopTypesState.error!)
            : shopTypesState.shopTypes.isEmpty
            ? const AppEmptyView(
                icon: Icons.category_outlined,
                title: 'No shop types yet',
                message: 'Add a shop type to categorize shops.',
              )
            : _buildShopTypeList(shopTypesState.shopTypes),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref.read(shopTypesProvider.notifier).loadShopTypes(),
    );
  }

  Widget _buildShopTypeList(List<ShopType> shopTypes) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(shopTypesProvider.notifier).loadShopTypes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shopTypes.length,
        itemBuilder: (context, index) {
          final shopType = shopTypes[index];
          return _buildShopTypeCard(shopType);
        },
      ),
    );
  }

  Widget _buildShopTypeCard(ShopType shopType) {
    final isDisabled = !shopType.enabled;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: shopType.enabled
                ? context.status.success.withValues(alpha: 0.1)
                : context.status.neutral.withValues(alpha: 0.1),
            child: Icon(
              shopTypeIcon(shopType.code),
              color: shopType.enabled
                  ? context.status.success
                  : context.status.neutral,
            ),
          ),
          title: Text(
            shopType.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isDisabled ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shopType.code),
              if (shopType.description?.isNotEmpty == true)
                Text(
                  shopType.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              Row(
                children: [
                  _buildStatusChip(shopType.enabled),
                  const SizedBox(width: 8),
                  Text(
                    _shopCountLabel(shopType.usage),
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleAction(shopType, action),
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
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      shopType.enabled
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: shopType.enabled
                          ? context.status.warning
                          : context.status.success,
                    ),
                    const SizedBox(width: 8),
                    Text(shopType.enabled ? 'Disable' : 'Enable'),
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
          onTap: () => _showDetailsDialog(shopType),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool enabled) {
    return StatusBadge(
      label: enabled ? 'Enabled' : 'Disabled',
      tone: enabled ? StatusTone.success : StatusTone.neutral,
    );
  }

  String _shopCountLabel(ShopTypeUsage? usage) => switch (usage) {
    null => 'Shop count unavailable',
    ShopTypeUsage(total: 1) => '1 shop',
    ShopTypeUsage(:final total) => '$total shops',
  };

  void _handleAction(ShopType shopType, String action) {
    switch (action) {
      case 'view':
        _showDetailsDialog(shopType);
        break;
      case 'edit':
        _showEditDialog(shopType);
        break;
      case 'toggle':
        _toggleShopType(shopType);
        break;
      case 'delete':
        _showDeleteDialog(shopType);
        break;
    }
  }

  Future<void> _toggleShopType(ShopType shopType) async {
    if (shopType.enabled) {
      final ok = await AppDialogs.confirm(
        context,
        title: 'Disable "${shopType.name}"?',
        message:
            'New shops can no longer choose this type. Shops already using '
            'it keep it.',
        confirmLabel: 'Disable',
        icon: Icons.toggle_off_outlined,
      );
      if (!ok || !mounted) return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(shopTypesProvider.notifier).toggleShopType(shopType.id);
      messenger.showSuccess(
        '"${shopType.name}" ${shopType.enabled ? 'disabled' : 'enabled'}',
      );
    } catch (e) {
      messenger.showError('Could not update shop type: ${friendlyError(e)}');
    }
  }

  void _showDetailsDialog(ShopType shopType) {
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
                    backgroundColor: shopType.enabled
                        ? context.status.success.withValues(alpha: 0.1)
                        : context.status.neutral.withValues(alpha: 0.1),
                    child: Icon(
                      shopTypeIcon(shopType.code),
                      size: 30,
                      color: shopType.enabled
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
                          shopType.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(shopType.code),
                        _buildStatusChip(shopType.enabled),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Information', [
                _buildDetailRow('Code', shopType.code),
                _buildDetailRow('Name', shopType.name),
                _buildDetailRow('Description', shopType.description ?? 'N/A'),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Features', [
                if (shopType.features.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No features defined',
                      style: TextStyle(color: context.status.neutral),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: shopType.features
                        .map(
                          (feature) => Chip(
                            label: Text(feature),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                        )
                        .toList(),
                  ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Statistics', [
                if (shopType.usage case final usage?) ...[
                  _buildDetailRow('Shops', usage.total.toString()),
                  _buildDetailRow('Active', usage.active.toString()),
                  _buildDetailRow('Inactive', usage.inactive.toString()),
                  _buildDetailRow('Suspended', usage.suspended.toString()),
                ] else
                  _buildDetailRow('Shops', 'Unavailable'),
                _buildDetailRow(
                  'Status',
                  shopType.enabled ? 'Enabled' : 'Disabled',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Timestamps', [
                _buildDetailRow(
                  'Created',
                  shopType.createdAt?.toString().split(' ')[0] ?? 'N/A',
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

  void _showEditDialog(ShopType shopType) => _openForm(shopType);

  Future<void> _openForm([ShopType? existing]) async {
    final notifier = ref.read(shopTypesProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showShopTypeForm(
      context,
      existing: existing,
      save: (create, update) async {
        final ok = create != null
            ? await notifier.createShopType(create)
            : await notifier.updateShopType(existing!.id, update!);
        // The notifier reports failures via state; surface them to the form.
        if (!ok) throw Exception(ref.read(shopTypesProvider).error);
      },
    );
    if (saved) {
      messenger.showSuccess(
        existing == null ? 'Shop type created' : 'Shop type updated',
      );
    }
  }

  Future<void> _showDeleteDialog(ShopType shopType) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Delete "${shopType.name}"?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(shopTypesProvider.notifier);
    final success = await notifier.deleteShopType(shopType.id);
    if (success) {
      messenger.showSuccess('Shop type deleted');
    } else {
      messenger.showError(
        'Could not delete shop type: '
        '${friendlyError(ref.read(shopTypesProvider).error)}',
      );
    }
  }
}
