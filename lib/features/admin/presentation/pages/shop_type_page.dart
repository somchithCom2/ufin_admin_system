import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

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
            icon: const Icon(Icons.refresh),
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
      body: shopTypesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopTypesState.error != null
          ? _buildErrorView(shopTypesState.error!)
          : shopTypesState.shopTypes.isEmpty
          ? const Center(child: Text('No shop types found'))
          : _buildShopTypeList(shopTypesState.shopTypes),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(shopTypesProvider.notifier).loadShopTypes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
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
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            child: Icon(
              _getIconData(shopType.iconName),
              color: shopType.enabled ? Colors.green : Colors.grey,
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              Row(
                children: [
                  _buildStatusChip(shopType.enabled),
                  const SizedBox(width: 8),
                  Text(
                    '${shopType.shopCount} shops',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                      color: shopType.enabled ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(shopType.enabled ? 'Disable' : 'Enable'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        enabled ? 'ENABLED' : 'DISABLED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: enabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'store':
        return Icons.store;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_bar':
        return Icons.local_bar;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'local_mall':
        return Icons.local_mall;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'spa':
        return Icons.spa;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'hotel':
        return Icons.hotel;
      case 'car_repair':
        return Icons.car_repair;
      default:
        return Icons.storefront;
    }
  }

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
    final success = await ref
        .read(shopTypesProvider.notifier)
        .toggleShopType(shopType.id);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shopType.enabled ? 'Shop type disabled' : 'Shop type enabled',
          ),
        ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: shopType.enabled
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Icon(
                      _getIconData(shopType.iconName),
                      size: 30,
                      color: shopType.enabled ? Colors.green : Colors.grey,
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
                _buildDetailRow('Icon', shopType.iconName ?? 'Default'),
                _buildDetailRow(
                  'Display Order',
                  shopType.displayOrder.toString(),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Features', [
                if (shopType.features.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No features defined',
                      style: TextStyle(color: Colors.grey),
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
                _buildDetailRow('Shop Count', shopType.shopCount.toString()),
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
                _buildDetailRow(
                  'Updated',
                  shopType.updatedAt?.toString().split(' ')[0] ?? 'N/A',
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
          Text(label, style: TextStyle(color: Colors.grey[600])),
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
    final descEnController = TextEditingController();
    final descLoController = TextEditingController();
    final orderController = TextEditingController(text: '0');
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Shop Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code *',
                    hintText: 'e.g., RESTAURANT',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Name (EN) *',
                    hintText: 'e.g., Restaurant',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameLoController,
                  decoration: const InputDecoration(
                    labelText: 'Name (LO)',
                    hintText: 'e.g., ຮ້ານອາຫານ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descEnController,
                  decoration: const InputDecoration(
                    labelText: 'Description (EN)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descLoController,
                  decoration: const InputDecoration(
                    labelText: 'Description (LO)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: _iconOptions
                      .map(
                        (icon) => DropdownMenuItem(
                          value: icon,
                          child: Row(
                            children: [
                              Icon(_getIconData(icon), size: 20),
                              const SizedBox(width: 8),
                              Text(icon),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedIcon = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (codeController.text.isEmpty ||
                    nameEnController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code and Name (EN) are required'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                final nameMap = <String, dynamic>{
                  'en': nameEnController.text,
                  if (nameLoController.text.isNotEmpty)
                    'lo': nameLoController.text,
                };
                final descMap = <String, dynamic>{
                  if (descEnController.text.isNotEmpty)
                    'en': descEnController.text,
                  if (descLoController.text.isNotEmpty)
                    'lo': descLoController.text,
                };
                final request = CreateShopTypeRequest(
                  code: codeController.text.toUpperCase(),
                  name: nameMap,
                  description: descMap.isNotEmpty ? descMap : null,
                  iconName: selectedIcon,
                  displayOrder: int.tryParse(orderController.text),
                );
                final success = await ref
                    .read(shopTypesProvider.notifier)
                    .createShopType(request);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop type created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ShopType shopType) {
    final codeController = TextEditingController(text: shopType.code);
    final nameEnController = TextEditingController(text: shopType.name);
    final nameLoController = TextEditingController();
    final descEnController = TextEditingController(
      text: shopType.description ?? '',
    );
    final descLoController = TextEditingController();
    final orderController = TextEditingController(
      text: shopType.displayOrder.toString(),
    );
    String? selectedIcon = shopType.iconName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Shop Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Name (EN) *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameLoController,
                  decoration: const InputDecoration(
                    labelText: 'Name (LO)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descEnController,
                  decoration: const InputDecoration(
                    labelText: 'Description (EN)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descLoController,
                  decoration: const InputDecoration(
                    labelText: 'Description (LO)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: _iconOptions
                      .map(
                        (icon) => DropdownMenuItem(
                          value: icon,
                          child: Row(
                            children: [
                              Icon(_getIconData(icon), size: 20),
                              const SizedBox(width: 8),
                              Text(icon),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedIcon = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: 'Display Order',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (codeController.text.isEmpty ||
                    nameEnController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code and Name (EN) are required'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                final nameMap = <String, dynamic>{
                  'en': nameEnController.text,
                  if (nameLoController.text.isNotEmpty)
                    'lo': nameLoController.text,
                };
                final descMap = <String, dynamic>{
                  if (descEnController.text.isNotEmpty)
                    'en': descEnController.text,
                  if (descLoController.text.isNotEmpty)
                    'lo': descLoController.text,
                };
                final request = UpdateShopTypeRequest(
                  code: codeController.text.toUpperCase(),
                  name: nameMap,
                  description: descMap.isNotEmpty ? descMap : null,
                  iconName: selectedIcon,
                  displayOrder: int.tryParse(orderController.text),
                );
                final success = await ref
                    .read(shopTypesProvider.notifier)
                    .updateShopType(shopType.id, request);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop type updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ShopType shopType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shop Type'),
        content: Text(
          'Are you sure you want to delete "${shopType.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(shopTypesProvider.notifier)
                  .deleteShopType(shopType.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shop type deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static const List<String> _iconOptions = [
    'restaurant',
    'store',
    'shopping_cart',
    'local_cafe',
    'local_bar',
    'local_grocery_store',
    'local_mall',
    'local_pharmacy',
    'local_hospital',
    'local_laundry_service',
    'spa',
    'fitness_center',
    'hotel',
    'car_repair',
  ];
}
