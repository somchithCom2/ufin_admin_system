import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shop_products_page.dart';

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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(shopsProvider.notifier).loadShops(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search shops...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      _scrollController.jumpTo(0); // Reset scroll position
                      ref.read(shopsProvider.notifier).loadShops(search: value);
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
                    _scrollController.jumpTo(0); // Reset scroll position
                    ref
                        .read(shopsProvider.notifier)
                        .loadShops(
                          search: _searchController.text,
                          status: status,
                        );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('All')),
                    const PopupMenuItem(value: 'active', child: Text('Active')),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: Text('Suspended'),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Shop List
          Expanded(
            child: shopsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : shopsState.error != null
                ? _buildErrorView(shopsState.error!)
                : shopsState.shops.isEmpty
                ? const Center(child: Text('No shops found'))
                : _buildShopList(shopsState.shops, shopsState.isLoadingMore),
          ),
        ],
      ),
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
            onPressed: () => ref.read(shopsProvider.notifier).loadShops(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShopList(List<AdminShop> shops, bool isLoadingMore) {
    final shopsState = ref.watch(shopsProvider);
    final hasMore = shopsState.hasNext;

    return RefreshIndicator(
      onRefresh: () async {
        _scrollController.jumpTo(0); // Reset scroll on refresh
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
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
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
          backgroundColor: _getStatusColor(shop.status).withValues(alpha: 0.1),
          child: Icon(Icons.storefront, color: _getStatusColor(shop.status)),
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
                color: Colors.grey[500],
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
            Row(
              children: [
                _buildStatusChip(shop.status),
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
            const PopupMenuItem(
              value: 'products',
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('View Products'),
                ],
              ),
            ),
            if (shop.status != 'suspended')
              const PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Suspend'),
                  ],
                ),
              ),
            if (shop.status == 'suspended')
              const PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
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
                    backgroundColor: _getStatusColor(
                      shop.status,
                    ).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.storefront,
                      size: 30,
                      color: _getStatusColor(shop.status),
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
                        _buildStatusChip(shop.status),
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
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showStatusDialog(AdminShop shop, String newStatus) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == 'suspended' ? 'Suspend Shop' : 'Activate Shop',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to ${newStatus == 'suspended' ? 'suspend' : 'activate'} "${shop.name}"?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(shopsProvider.notifier)
                  .updateShopStatus(
                    shop.id,
                    newStatus,
                    reasonController.text.isNotEmpty
                        ? reasonController.text
                        : null,
                  );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
