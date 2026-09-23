import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productsProvider(_shopId).notifier)
          .loadProducts(shopId: _shopId);
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
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
          inStockOnly: _inStockFilter,
        );
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final bucketUrl = dotenv.env['BUCKET_PUBLIC_BASE_URL'] ?? '';
    return '$bucketUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider(_shopId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shop.name} — Products'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _applyFilters,
          ),
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
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: 'Search products…',
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
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  if (state.hasNext) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• more available',
                      style: TextStyle(
                        color: context.status.info,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          // Product list
          Expanded(
            child: state.isLoading
                ? const AppLoadingView()
                : state.error != null && state.products.isEmpty
                ? _buildError(state.error!)
                : state.products.isEmpty
                ? const AppEmptyView(
                    icon: Icons.inventory_outlined,
                    title: 'No products found',
                    message: 'This shop has no products matching the filters.',
                  )
                : _buildList(state.products, state.isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return AppErrorView(error: error, onRetry: _applyFilters);
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
            return const LoadMoreIndicator();
          }
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(AdminProduct product) {
    final isOutOfStock = product.stockQuantity <= 0;
    final thumbnailUrl = _getFullImageUrl(product.thumbnailUrl);
    final imageUrl = _getFullImageUrl(product.imageUrl);
    final displayUrl = thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: displayUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: displayUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _productIcon(product),
                  errorWidget: (_, __, ___) => _productIcon(product),
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
            if (product.sku != null)
              Text(
                'SKU: ${product.sku}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            Row(
              children: [
                Text(
                  _formatPrice(product.price),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.status.success,
                  ),
                ),
                const SizedBox(width: 8),
                if (product.categoryName != null)
                  _chip(product.categoryName!, context.status.info),
                const SizedBox(width: 4),
                _chip(
                  isOutOfStock
                      ? 'Out of Stock'
                      : 'Qty: ${product.stockQuantity}',
                  isOutOfStock ? context.colors.error : context.status.success,
                ),
              ],
            ),
          ],
        ),
        trailing: !product.isActive
            ? _chip('Inactive', context.status.neutral)
            : null,
      ),
    );
  }

  Widget _productIcon(AdminProduct product) {
    return CircleAvatar(
      backgroundColor: context.status.info.withValues(alpha: 0.1),
      child: Icon(Icons.inventory_2, color: context.status.info),
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
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(price);
  }
}
