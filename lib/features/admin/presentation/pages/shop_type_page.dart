import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
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
        title: Text(context.tr(NavText.shopTypes)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(shopTypesProvider.notifier).loadShopTypes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: Text(context.tr(ShopTypeText.addType)),
      ),
      body: ContentWidth(
        child: shopTypesState.isLoading
            ? const AppLoadingView()
            : shopTypesState.error != null && shopTypesState.shopTypes.isEmpty
            ? _buildErrorView(shopTypesState.error!)
            : shopTypesState.shopTypes.isEmpty
            ? AppEmptyView(
                icon: Icons.category_outlined,
                title: context.tr(ShopTypeText.noShopTypesYet),
                message: context.tr(ShopTypeText.addAShopTypeTo),
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
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text(context.tr(ShopTypeText.viewDetails)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text(context.tr(CommonText.edit)),
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
                    Text(
                      shopType.enabled
                          ? context.tr(CommonText.disable)
                          : context.tr(CommonText.enable),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: context.colors.error),
                    SizedBox(width: 8),
                    Text(context.tr(CommonText.delete)),
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
      label: enabled
          ? context.tr(ShopTypeText.enabled)
          : context.tr(ShopTypeText.disabled),
      tone: enabled ? StatusTone.success : StatusTone.neutral,
    );
  }

  String _shopCountLabel(ShopTypeUsage? usage) => switch (usage) {
    null => context.tr(ShopTypeText.shopCountUnavailable),
    ShopTypeUsage(total: 1) => context.tr(ShopTypeText.n1Shop),
    ShopTypeUsage(:final total) => context.tr(ShopTypeText.shops(total)),
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
        title: context.tr(ShopTypeText.disable(shopType.name)),
        message: context.tr(ShopTypeText.newShopsCanNoLonger),
        confirmLabel: context.tr(CommonText.disable),
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
      messenger.showError(
        ShopTypeText.couldNotUpdateShopType(friendlyError(e)).current,
      );
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
              _buildDetailSection(context.tr(ShopTypeText.information), [
                _buildDetailRow(context.tr(CommonText.code), shopType.code),
                _buildDetailRow(context.tr(CommonText.name), shopType.name),
                _buildDetailRow(
                  context.tr(CommonText.description),
                  shopType.description ?? 'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(ShopTypeText.features), [
                if (shopType.features.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      context.tr(ShopTypeText.noFeaturesDefined),
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
              _buildDetailSection(context.tr(NavText.statistics), [
                if (shopType.usage case final usage?) ...[
                  _buildDetailRow(
                    context.tr(NavText.shops),
                    usage.total.toString(),
                  ),
                  _buildDetailRow(
                    context.tr(ShopTypeText.active),
                    usage.active.toString(),
                  ),
                  _buildDetailRow(
                    context.tr(ShopTypeText.inactive),
                    usage.inactive.toString(),
                  ),
                  _buildDetailRow(
                    context.tr(ShopTypeText.suspended),
                    usage.suspended.toString(),
                  ),
                ] else
                  _buildDetailRow(
                    context.tr(NavText.shops),
                    context.tr(ShopTypeText.unavailable),
                  ),
                _buildDetailRow(
                  context.tr(CommonText.status),
                  shopType.enabled
                      ? context.tr(ShopTypeText.enabled)
                      : context.tr(ShopTypeText.disabled),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(ShopTypeText.timestamps), [
                _buildDetailRow(
                  context.tr(CommonText.created),
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
        existing == null
            ? ShopTypeText.created.current
            : ShopTypeText.updated.current,
      );
    }
  }

  Future<void> _showDeleteDialog(ShopType shopType) async {
    final ok = await AppDialogs.confirm(
      context,
      title: context.tr(ShopTypeText.delete(shopType.name)),
      message: context.tr(ShopTypeText.thisCannotBeUndone),
      confirmLabel: context.tr(CommonText.delete),
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(shopTypesProvider.notifier);
    final success = await notifier.deleteShopType(shopType.id);
    if (success) {
      messenger.showSuccess(ShopTypeText.shopTypeDeleted.current);
    } else {
      messenger.showError(
        ShopTypeText.couldNotDeleteShopType(
          friendlyError(ref.read(shopTypesProvider).error),
        ).current,
      );
    }
  }
}
