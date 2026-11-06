import 'package:flutter/material.dart';
import 'subscription_action_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_history_page.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

/// Which plans the list shows. Paid first: free trials outnumber paying shops,
/// and paying shops are the ones to manage.
enum SubscriptionPlanFilter {
  paid('Paid'),
  free('Free'),
  all('All plans');

  const SubscriptionPlanFilter(this.label);

  final String label;
}

/// Filters another page asks the list to open with, e.g. the dashboard's
/// "lapsed to Free" row. The list applies it once and clears it.
typedef SubscriptionsListPreset = ({
  String? status,
  SubscriptionPlanFilter plan,
});

final subscriptionsListPresetProvider = StateProvider<SubscriptionsListPreset?>(
  (ref) => null,
);

class SubscriptionsListPage extends ConsumerStatefulWidget {
  const SubscriptionsListPage({super.key});

  @override
  ConsumerState<SubscriptionsListPage> createState() =>
      _SubscriptionsListPageState();
}

class _SubscriptionsListPageState extends ConsumerState<SubscriptionsListPage> {
  String? _statusFilter;
  SubscriptionPlanFilter _planFilter = SubscriptionPlanFilter.paid;
  final _searchController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_applyPreset()) _reload();
    });
  }

  /// Takes the preset another page left, if any, and reloads with it.
  /// Returns false when there was none.
  bool _applyPreset() {
    final preset = ref.read(subscriptionsListPresetProvider);
    if (preset == null || !mounted) return false;
    ref.read(subscriptionsListPresetProvider.notifier).state = null;
    _searchController.clear();
    setState(() {
      _statusFilter = preset.status;
      _planFilter = preset.plan;
    });
    _reload();
    return true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads the first page of what the filters and search box ask for.
  Future<void> _reload() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    final search = _searchController.text.trim();
    return ref
        .read(subscriptionsProvider.notifier)
        .loadSubscriptions(
          status: _statusFilter,
          planCode: _planFilter == SubscriptionPlanFilter.free ? 'free' : null,
          paid: _planFilter == SubscriptionPlanFilter.paid,
          search: search.isEmpty ? null : search,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      final state = ref.read(subscriptionsProvider);
      if (!state.isLoadingMore && state.hasNext) {
        ref.read(subscriptionsProvider.notifier).loadMoreSubscriptions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsState = ref.watch(subscriptionsProvider);
    // The page stays alive between visits, so a preset set later arrives here.
    ref.listen(subscriptionsListPresetProvider, (_, preset) {
      if (preset != null) _applyPreset();
    });

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'All History',
            onPressed: () => _navigateToAllHistory(),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reload,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<AdminSubscription>(
            builder: (_) =>
                const SubscriptionActionPage(action: SubscriptionAction.create),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create Subscription'),
      ),
      body: ContentWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppSearchField(
                controller: _searchController,
                hintText: 'Shop, phone, email, owner or ID…',
                onSubmitted: (_) => _reload(),
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (final plan in SubscriptionPlanFilter.values)
                    _buildPlanChip(plan),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  _buildFilterChip('Active', 'active'),
                  _buildFilterChip('Trial', 'trial'),
                  _buildFilterChip('Expired', 'expired'),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
            if (!subscriptionsState.isLoading &&
                subscriptionsState.subscriptions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subscriptionsState.totalElements == 1
                        ? '1 subscription'
                        : '${subscriptionsState.totalElements} subscriptions',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            // Subscription List
            Expanded(
              child: subscriptionsState.isLoading
                  ? const AppLoadingView()
                  : subscriptionsState.error != null &&
                        subscriptionsState.subscriptions.isEmpty
                  ? _buildErrorView(subscriptionsState.error!)
                  : subscriptionsState.subscriptions.isEmpty
                  ? _buildEmptyView()
                  : _buildSubscriptionList(subscriptionsState.subscriptions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanChip(SubscriptionPlanFilter plan) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(plan.label),
        selected: _planFilter == plan,
        onSelected: (_) {
          setState(() => _planFilter = plan);
          _reload();
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _statusFilter = selected ? status : null);
          _reload();
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(error: error, onRetry: _reload);
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: context.colors.outline),
          const SizedBox(height: 16),
          Text(
            'No subscriptions found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_statusFilter != null ||
              _planFilter != SubscriptionPlanFilter.all) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _planFilter = SubscriptionPlanFilter.all;
                });
                _reload();
              },
              child: const Text('Search all plans'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionList(List<AdminSubscription> subscriptions) {
    final subscriptionsState = ref.watch(subscriptionsProvider);
    final hasMore = subscriptionsState.hasNext;

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subscriptions.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == subscriptions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            );
          }

          final subscription = subscriptions[index];
          return _buildSubscriptionCard(subscription);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(AdminSubscription subscription) {
    final daysLeft =
        subscription.expiresAt?.difference(DateTime.now()).inDays ?? 0;
    final isExpiringSoon = daysLeft <= 7 && daysLeft > 0;
    final isExpired = daysLeft < 0;
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(subscription),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.planName ?? 'No Plan',
                          style: TextStyle(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(subscription.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Price',
                      currencyFormat.format(subscription.pricePaid),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.people,
                      'Employees',
                      '${subscription.currentEmployees}/${subscription.maxEmployees == 0 ? '∞' : subscription.maxEmployees}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.inventory_2,
                      'Products',
                      '${subscription.currentProducts}/${subscription.maxProducts == 0 ? '∞' : subscription.maxProducts}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Expiry Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? context.colors.errorContainer
                      : isExpiringSoon
                      ? context.status.warningContainer
                      : context.colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpired
                          ? Icons.error
                          : isExpiringSoon
                          ? Icons.warning_amber
                          : Icons.calendar_today,
                      size: 16,
                      color: isExpired
                          ? context.colors.error
                          : isExpiringSoon
                          ? context.status.warning
                          : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isExpired
                            ? 'Expired ${-daysLeft} days ago'
                            : isExpiringSoon
                            ? 'Expires in $daysLeft days'
                            : 'Expires: ${DateFormat('MMM d, yyyy').format(subscription.expiresAt ?? DateTime.now())}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isExpired
                              ? context.colors.error
                              : isExpiringSoon
                              ? context.status.warning
                              : context.colors.onSurfaceVariant,
                          fontWeight: isExpiringSoon || isExpired
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.colors.outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return StatusBadge.fromStatus(status);
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: context.colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  void _navigateToDetail(AdminSubscription subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubscriptionDetailPage(subscription: subscription),
      ),
    );
  }

  void _navigateToAllHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionHistoryPage()),
    );
  }
}
