import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shop_products_page.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class ShopsPage extends ConsumerStatefulWidget {
  const ShopsPage({super.key});

  @override
  ConsumerState<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends ConsumerState<ShopsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopsProvider.notifier).loadShops();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(shopsProvider);
      if (!state.isLoadingMore && state.hasNext) {
        ref.read(shopsProvider.notifier).loadMoreShops();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopsState = ref.watch(shopsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Shops'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(shopsProvider.notifier).loadShops(),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      controller: _searchController,
                      hintText: 'Name, phone, email, owner or ID…',
                      onSubmitted: (value) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                        ref
                            .read(shopsProvider.notifier)
                            .loadShops(search: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String?>(
                    icon: Badge(
                      isLabelVisible: _statusFilter != null,
                      child: const Icon(Icons.filter_list),
                    ),
                    onSelected: (status) {
                      setState(() => _statusFilter = status);
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                      ref
                          .read(shopsProvider.notifier)
                          .loadShops(
                            search: _searchController.text,
                            status: status,
                          );
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('All')),
                      const PopupMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      const PopupMenuItem(
                        value: 'suspended',
                        child: Text('Suspended'),
                      ),
                      const PopupMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                      const PopupMenuItem(
                        value: 'deleted',
                        child: Text('Deleted'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Shop List
            Expanded(
              child: shopsState.isLoading
                  ? const AppLoadingView()
                  : shopsState.error != null && shopsState.shops.isEmpty
                  ? _buildErrorView(shopsState.error!)
                  : shopsState.shops.isEmpty
                  ? const AppEmptyView(
                      icon: Icons.storefront_outlined,
                      title: 'No shops found',
                      message: 'Try a different search or filter.',
                    )
                  : _buildShopList(shopsState.shops, shopsState.isLoadingMore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref.read(shopsProvider.notifier).loadShops(),
    );
  }

  Widget _buildShopList(List<AdminShop> shops, bool isLoadingMore) {
    final shopsState = ref.watch(shopsProvider);
    final hasMore = shopsState.hasNext;

    return RefreshIndicator(
      onRefresh: () async {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        await ref
            .read(shopsProvider.notifier)
            .loadShops(
              search: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
              status: _statusFilter,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures scrolling works even if items don't fill screen
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Only add the loader slot if there actually IS more data to load
        itemCount: shops.length + (isLoadingMore && hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == shops.length) {
            return const LoadMoreIndicator();
          }
          return _buildShopCard(shops[index]);
        },
      ),
    );
  }

  Widget _buildShopCard(AdminShop shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(
            _displayStatus(shop),
          ).withValues(alpha: 0.1),
          child: Icon(
            Icons.storefront,
            color: _getStatusColor(_displayStatus(shop)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                shop.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '#${shop.id}',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shop.ownerUsername != null)
              Text('Owner: ${shop.ownerUsername}'),
            if (shop.isBranch)
              Text(
                'Branch of: ${shop.parentShopName ?? '#${shop.parentShopId}'}',
              ),
            Row(
              children: [
                _buildStatusChip(_displayStatus(shop)),
                const SizedBox(width: 8),
                if (shop.subscriptionPlan != null)
                  Chip(
                    label: Text(
                      shop.subscriptionPlan!,
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleShopAction(shop, action),
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
            if (shop.isDeleted)
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: context.status.success),
                    SizedBox(width: 8),
                    Text('Restore'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'products',
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: context.status.info),
                  SizedBox(width: 8),
                  Text('View Products'),
                ],
              ),
            ),
            if (!shop.isDeleted && shop.status != 'suspended')
              PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block, color: context.status.warning),
                    SizedBox(width: 8),
                    Text('Suspend'),
                  ],
                ),
              ),
            if (!shop.isDeleted && shop.status == 'suspended')
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: context.status.success),
                    SizedBox(width: 8),
                    Text('Activate'),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _showShopDetails(shop),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return StatusBadge.fromStatus(status);
  }

  /// A deleted shop is stored as "inactive"; show why it is gone instead.
  String _displayStatus(AdminShop shop) =>
      shop.isDeleted ? 'deleted' : shop.status;

  Color _getStatusColor(String status) {
    return StatusTone.fromStatus(status).foreground(context);
  }

  void _handleShopAction(AdminShop shop, String action) {
    switch (action) {
      case 'view':
        _showShopDetails(shop);
        break;
      case 'products':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShopProductsPage(shop: shop)),
        );
        break;
      case 'suspend':
        _showStatusDialog(shop, 'suspended');
        break;
      case 'activate':
        _showStatusDialog(shop, 'active');
        break;
      case 'restore':
        _showRestoreDialog(shop);
        break;
    }
  }

  void _showShopDetails(AdminShop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                    backgroundColor: _getStatusColor(
                      _displayStatus(shop),
                    ).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.storefront,
                      size: 30,
                      color: _getStatusColor(_displayStatus(shop)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        _buildStatusChip(_displayStatus(shop)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Shop Information', [
                _buildDetailRow('Business Name', shop.businessName ?? 'N/A'),
                _buildDetailRow(
                  'Business Type',
                  shop.businessType?['en'] ??
                      shop.businessType?.values.firstOrNull ??
                      'N/A',
                ),
                _buildDetailRow('Email', shop.email ?? 'N/A'),
                _buildDetailRow('Phone', shop.phone ?? 'N/A'),
                _buildDetailRow('Address', shop.address ?? 'N/A'),
                if (shop.isBranch)
                  _buildDetailRow(
                    'Branch of',
                    shop.parentShopName ?? '#${shop.parentShopId}',
                  ),
                if (shop.isDeleted)
                  _buildDetailRow(
                    'Deleted on',
                    shop.deletedAt!.toLocal().toString().split('.')[0],
                  ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Owner', [
                _buildDetailRow('Username', shop.ownerUsername ?? 'N/A'),
                _buildDetailRow('Email', shop.ownerEmail ?? 'N/A'),
                _buildDetailRow('Phone', shop.ownerPhone ?? 'N/A'),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Subscription', [
                _buildDetailRow('Plan', shop.subscriptionPlan ?? 'N/A'),
                _buildDetailRow('Status', shop.subscriptionStatus ?? 'N/A'),
                _buildDetailRow(
                  'Expires',
                  shop.subscriptionExpires?.toString().split(' ')[0] ?? 'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Statistics', [
                _buildDetailRow('Employees', shop.employeeCount.toString()),
                _buildDetailRow('Products', shop.productCount.toString()),
              ]),
              const SizedBox(height: 24),
              if (shop.isDeleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore Shop'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showRestoreDialog(shop);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: Text('View Products (${shop.productCount})'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => ShopProductsPage(shop: shop),
                      ),
                    );
                  },
                ),
              ),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(AdminShop shop) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Restore shop',
      message:
          '"${shop.name}" will be active again with all its products, staff '
          'and sales history. Its owner and staff can sign in to it right away.',
      confirmLabel: 'Restore',
      icon: Icons.restore_rounded,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(shopsProvider.notifier).restoreShop(shop.id);
      messenger.showSuccess('"${shop.name}" has been restored');
    } catch (e) {
      messenger.showError(
        'Could not restore "${shop.name}": ${friendlyError(e)}',
      );
    }
  }

  Future<void> _showStatusDialog(AdminShop shop, String newStatus) async {
    final suspend = newStatus == 'suspended';
    final reason = await AppDialogs.confirmWithReason(
      context,
      title: suspend ? 'Suspend shop' : 'Activate shop',
      message: suspend
          ? '"${shop.name}" and its staff will be blocked from using UFin until reactivated.'
          : '"${shop.name}" and its staff will regain access to UFin.',
      confirmLabel: suspend ? 'Suspend' : 'Activate',
      destructive: suspend,
      icon: suspend ? Icons.block_rounded : Icons.check_circle_outline_rounded,
    );
    if (reason == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(shopsProvider.notifier)
          .updateShopStatus(shop.id, newStatus, reason.isEmpty ? null : reason);
      messenger.showSuccess(
        '"${shop.name}" has been ${suspend ? 'suspended' : 'activated'}',
      );
    } catch (e) {
      messenger.showError(
        'Could not update "${shop.name}": ${friendlyError(e)}',
      );
    }
  }
}
