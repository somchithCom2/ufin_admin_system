import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class ShopProductsPage extends ConsumerStatefulWidget {
  final AdminShop shop;

  const ShopProductsPage({super.key, required this.shop});

  @override
  ConsumerState<ShopProductsPage> createState() => _ShopProductsPageState();
}

class _ShopProductsPageState extends ConsumerState<ShopProductsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool? _inStockFilter;

  int get _shopId => widget.shop.id;
  int get _empId => widget.shop.ownerId ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productsProvider(_shopId).notifier)
          .loadProducts(shopId: _shopId, empId: _empId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider(_shopId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref
        .read(productsProvider(_shopId).notifier)
        .loadProducts(
          shopId: _shopId,
          empId: _empId,
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
          inStockOnly: _inStockFilter,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider(_shopId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shop.name} — Products'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _applyFilters),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String?>(
                  icon: Badge(
                    isLabelVisible: _inStockFilter != null,
                    child: const Icon(Icons.filter_list),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _inStockFilter = value == 'inStock' ? true : null;
                    });
                    _applyFilters();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Products'),
                    ),
                    const PopupMenuItem(
                      value: 'inStock',
                      child: Text('In Stock Only'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Summary chip row
          if (state.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${state.products.length} product${state.products.length == 1 ? '' : 's'} loaded',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (state.hasNext) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• more available',
                      style: TextStyle(color: Colors.blue[400], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Product list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildError(state.error!)
                : state.products.isEmpty
                ? const Center(child: Text('No products found'))
                : _buildList(state.products, state.isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AdminProduct> products, bool isLoadingMore) {
    return RefreshIndicator(
      onRefresh: () async => _applyFilters(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(AdminProduct product) {
    final isOutOfStock = product.stockQuantity <= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  product.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _productIcon(product),
                ),
              )
            : _productIcon(product),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '#${product.id}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.sku != null)
              Text(
                'SKU: ${product.sku}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Row(
              children: [
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                if (product.categoryName != null)
                  _chip(product.categoryName!, Colors.blue),
                const SizedBox(width: 4),
                _chip(
                  isOutOfStock
                      ? 'Out of Stock'
                      : 'Qty: ${product.stockQuantity}',
                  isOutOfStock ? Colors.red : Colors.green,
                ),
              ],
            ),
          ],
        ),
        trailing: !product.isActive ? _chip('Inactive', Colors.grey) : null,
      ),
    );
  }

  Widget _productIcon(AdminProduct product) {
    return CircleAvatar(
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      child: const Icon(Icons.inventory_2, color: Colors.blue),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '₭${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '₭${(price / 1000).toStringAsFixed(0)}K';
    }
    return '₭${price.toStringAsFixed(0)}';
  }
}
