import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shop_products_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_data_reset_form.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_ownership_forms.dart';
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
        title: Text(context.tr(NavText.shops)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const AppIcon(AppIcons.refresh),
            onPressed: () => ref.read(shopsProvider.notifier).loadShops(),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            FilterBar(
              search: AppSearchField(
                controller: _searchController,
                hintText: context.tr(ShopText.namePhoneEmailOwnerOr),
                onSubmitted: (value) => _reload(search: value),
              ),
              filters: [
                FilterSelect<String>(
                  icon: AppIcons.flag,
                  label: context.tr(CommonText.status),
                  value: _statusFilter,
                  allLabel: context.tr(CommonText.all),
                  options: [
                    FilterOption('active', context.tr(ShopText.active)),
                    FilterOption('suspended', context.tr(ShopText.suspended)),
                    FilterOption('inactive', context.tr(ShopText.inactive)),
                    FilterOption('deleted', context.tr(ShopText.deleted)),
                  ],
                  onChanged: (status) {
                    setState(() => _statusFilter = status);
                    _reload();
                  },
                ),
              ],
            ),
            // Shop List
            Expanded(
              child: shopsState.isLoading
                  ? const AppLoadingView()
                  : shopsState.error != null && shopsState.shops.isEmpty
                  ? _buildErrorView(shopsState.error!)
                  : shopsState.shops.isEmpty
                  ? AppEmptyView(
                      icon: AppIcons.shop,
                      title: context.tr(ShopText.noShopsFound),
                      message: context.tr(ShopText.tryADifferentSearchOr),
                    )
                  : _buildShopList(shopsState.shops, shopsState.isLoadingMore),
            ),
          ],
        ),
      ),
    );
  }

  void _reload({String? search}) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    ref
        .read(shopsProvider.notifier)
        .loadShops(
          search: search ?? _searchController.text,
          status: _statusFilter,
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
          child: AppIcon(
            AppIcons.shop,
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
              Text(context.tr(ShopText.owner(shop.ownerUsername))),
            if (shop.isBranch)
              Text(
                context.tr(
                  ShopText.branchOf(
                    shop.parentShopName ?? '#${shop.parentShopId}',
                  ),
                ),
              ),
            // Wraps: a branch's plan chip names its main shop, which can be
            // longer than a phone-width row.
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildStatusChip(_displayStatus(shop)),
                if (shop.planLabel != null)
                  Chip(
                    label: Text(
                      shop.planLabel!,
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
          icon: const AppIcon(AppIcons.moreVertical),
          onSelected: (action) => _handleShopAction(shop, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  AppIcon(AppIcons.eye),
                  SizedBox(width: 8),
                  Text(context.tr(ShopText.viewDetails)),
                ],
              ),
            ),
            if (shop.isDeleted)
              PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    AppIcon(AppIcons.undo, color: context.status.success),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.restore)),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'products',
              child: Row(
                children: [
                  AppIcon(AppIcons.package, color: context.status.info),
                  SizedBox(width: 8),
                  Text(context.tr(ShopText.viewProducts)),
                ],
              ),
            ),
            if (!shop.isDeleted && shop.status != 'suspended')
              PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    AppIcon(AppIcons.ban, color: context.status.warning),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.suspend)),
                  ],
                ),
              ),
            if (!shop.isDeleted && shop.status == 'suspended')
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    AppIcon(
                      AppIcons.checkCircle,
                      color: context.status.success,
                    ),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.activate)),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            if (!shop.isBranch)
              PopupMenuItem(
                value: 'branches',
                child: Row(
                  children: [
                    AppIcon(AppIcons.network),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.branches)),
                  ],
                ),
              ),
            if (!shop.isDeleted && !shop.isBranch)
              PopupMenuItem(
                value: 'link',
                child: Row(
                  children: [
                    AppIcon(AppIcons.link),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.linkAsBranch)),
                  ],
                ),
              ),
            if (!shop.isDeleted && shop.isBranch)
              PopupMenuItem(
                value: 'unlink',
                child: Row(
                  children: [
                    AppIcon(AppIcons.split, color: context.status.warning),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.unlinkBranch)),
                  ],
                ),
              ),
            if (!shop.isDeleted && !shop.isBranch)
              PopupMenuItem(
                value: 'owner',
                child: Row(
                  children: [
                    AppIcon(AppIcons.swap, color: context.status.warning),
                    SizedBox(width: 8),
                    Text(context.tr(ShopText.changeOwner)),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'owner_history',
              child: Row(
                children: [
                  AppIcon(AppIcons.history),
                  SizedBox(width: 8),
                  Text(context.tr(ShopText.ownerHistory)),
                ],
              ),
            ),
            if (!shop.isDeleted) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'reset_data',
                child: Row(
                  children: [
                    AppIcon(AppIcons.reset, color: context.colors.error),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(ShopText.resetData),
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    AppIcon(AppIcons.delete, color: context.colors.error),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(ShopText.deleteShop),
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ),
              ),
            ],
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
      case 'delete':
        _showDeleteDialog(shop);
        break;
      case 'reset_data':
        _resetShopData(shop);
        break;
      case 'branches':
        showBranchesSheet(context, shop);
        break;
      case 'link':
        _runOwnershipAction(
          showLinkBranchForm(context, shop),
          context.tr(ShopText.linkedAsABranch),
        );
        break;
      case 'unlink':
        _runOwnershipAction(
          showUnlinkBranchForm(context, shop),
          context.tr(ShopText.unlinkedFromTheGroup),
        );
        break;
      case 'owner':
        _runOwnershipAction(
          showChangeOwnerForm(context, shop),
          context.tr(ShopText.ownerChanged),
        );
        break;
      case 'owner_history':
        showOwnerHistorySheet(context, shop);
        break;
    }
  }

  /// Waits for an ownership form and, once it is saved, shows what changed and
  /// which staff to review. A cancelled form shows nothing.
  Future<void> _runOwnershipAction(
    Future<ShopOwnershipResult?> form,
    String title,
  ) async {
    final result = await form;
    if (result == null || !mounted) return;
    await showOwnershipResultDialog(context, title: title, result: result);
  }

  /// Waits for the reset form and, once it is done, shows what was removed.
  Future<void> _resetShopData(AdminShop shop) async {
    final result = await showResetShopDataForm(context, shop);
    if (result == null || !mounted) return;
    await showShopDataResetResultDialog(context, result);
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getStatusColor(
                      _displayStatus(shop),
                    ).withValues(alpha: 0.1),
                    child: AppIcon(
                      AppIcons.shop,
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
              _buildDetailSection(context.tr(ShopText.shopInformation), [
                _buildDetailRow(
                  context.tr(ShopText.businessName),
                  shop.businessName ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(ShopText.businessType),
                  shop.businessType?['en'] ??
                      shop.businessType?.values.firstOrNull ??
                      'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.email),
                  shop.email ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.phone),
                  shop.phone ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.address),
                  shop.address ?? 'N/A',
                ),
                if (shop.isBranch)
                  _buildDetailRow(
                    context.tr(ShopText.branchOf2),
                    shop.parentShopName ?? '#${shop.parentShopId}',
                  ),
                if (shop.isDeleted)
                  _buildDetailRow(
                    context.tr(ShopText.deletedOn),
                    shop.deletedAt!.toLocal().toString().split('.')[0],
                  ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(CommonText.owner), [
                _buildDetailRow(
                  context.tr(AuthText.username),
                  shop.ownerUsername ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.email),
                  shop.ownerEmail ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.phone),
                  shop.ownerPhone ?? 'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(ShopText.subscription), [
                _buildDetailRow(
                  context.tr(CommonText.plan),
                  shop.planLabel ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.status),
                  shop.subscriptionStatus ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(ShopText.expires),
                  shop.isBranch
                      ? context.tr(ShopText.sameAsMainShop)
                      : shop.subscriptionExpires?.toString().split(' ')[0] ??
                            'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(NavText.statistics), [
                _buildDetailRow(
                  context.tr(ShopText.employees),
                  shop.employeeCount.toString(),
                ),
                _buildDetailRow(
                  context.tr(ShopText.products),
                  shop.productCount.toString(),
                ),
              ]),
              const SizedBox(height: 24),
              if (shop.isDeleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const AppIcon(AppIcons.undo),
                    label: Text(context.tr(ShopText.restoreShop)),
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
                  icon: const AppIcon(AppIcons.package),
                  label: Text(
                    context.tr(ShopText.viewProducts2(shop.productCount)),
                  ),
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
      title: context.tr(ShopText.restoreShop2),
      message: context.tr(ShopText.willBeActiveAgainWith(shop.name)),
      confirmLabel: context.tr(ShopText.restore),
      icon: AppIcons.undo,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(shopsProvider.notifier).restoreShop(shop.id);
      messenger.showSuccess(ShopText.hasBeenRestored(shop.name).current);
    } catch (e) {
      messenger.showError(
        ShopText.couldNotRestore(shop.name, friendlyError(e)).current,
      );
    }
  }

  /// Soft delete: nothing is erased, and the shop can be restored from the
  /// Deleted filter. A main shop with live branches is refused by the
  /// backend (ERR_SHOP_HAS_BRANCHES), which [friendlyError] explains.
  Future<void> _showDeleteDialog(AdminShop shop) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: context.tr(ShopText.deleteShop2),
      message: context.tr(ShopText.willBeClosedItsOwner(shop.name)),
      confirmLabel: context.tr(CommonText.delete),
      destructive: true,
      icon: AppIcons.delete,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(shopsProvider.notifier).deleteShop(shop.id);
      messenger.showSuccess(ShopText.hasBeenDeleted(shop.name).current);
    } catch (e) {
      messenger.showError(
        ShopText.couldNotDelete(shop.name, friendlyError(e)).current,
      );
    }
  }

  Future<void> _showStatusDialog(AdminShop shop, String newStatus) async {
    final suspend = newStatus == 'suspended';
    final reason = await AppDialogs.confirmWithReason(
      context,
      title: suspend
          ? context.tr(ShopText.suspendShop)
          : context.tr(ShopText.activateShop),
      message: suspend
          ? context.tr(ShopText.andItsStaffWillBe(shop.name))
          : context.tr(ShopText.andItsStaffWillRegain(shop.name)),
      confirmLabel: suspend
          ? context.tr(ShopText.suspend)
          : context.tr(ShopText.activate),
      destructive: suspend,
      icon: suspend ? AppIcons.ban : AppIcons.checkCircle,
    );
    if (reason == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(shopsProvider.notifier)
          .updateShopStatus(shop.id, newStatus, reason.isEmpty ? null : reason);
      messenger.showSuccess(
        suspend
            ? ShopText.hasBeenSuspended(shop.name).current
            : ShopText.hasBeenActivated(shop.name).current,
      );
    } catch (e) {
      messenger.showError(
        ShopText.couldNotUpdate(shop.name, friendlyError(e)).current,
      );
    }
  }
}
