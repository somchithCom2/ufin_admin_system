import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class SubscriptionHistoryPage extends ConsumerStatefulWidget {
  final int? shopId;
  final String? shopName;

  const SubscriptionHistoryPage({super.key, this.shopId, this.shopName});

  @override
  ConsumerState<SubscriptionHistoryPage> createState() =>
      _SubscriptionHistoryPageState();
}

class _SubscriptionHistoryPageState
    extends ConsumerState<SubscriptionHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    if (widget.shopId != null) {
      ref
          .read(subscriptionHistoryProvider.notifier)
          .loadShopHistory(widget.shopId!);
    } else {
      ref.read(subscriptionHistoryProvider.notifier).loadHistory();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(subscriptionHistoryProvider);
      if (state.hasMore && !state.isLoading && widget.shopId == null) {
        ref.read(subscriptionHistoryProvider.notifier).loadMoreHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(subscriptionHistoryProvider);
    final isShopSpecific = widget.shopId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription History'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          if (!isShopSpecific && historyState.totalCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${historyState.totalCount} total records',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (historyState.totalPages > 1)
                    Text(
                      'Page ${historyState.currentPage + 1} of ${historyState.totalPages}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: historyState.isLoading && historyState.history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : historyState.error != null && historyState.history.isEmpty
                ? _buildErrorView(historyState.error!)
                : historyState.history.isEmpty
                ? _buildEmptyView()
                : _buildHistoryList(historyState),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No history found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.shopId != null
                ? 'No changes have been made to this subscription yet'
                : 'No subscription changes recorded',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(SubscriptionHistoryState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.history.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.history.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildHistoryCard(state.history[index], index);
      },
    );
  }

  Widget _buildHistoryCard(SubscriptionHistory entry, int index) {
    final color = _getActionColor(entry.actionType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Top row: 2 boxes side by side
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left box - Action & Shop
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    color: color.withValues(alpha: 0.05),
                    child: Row(
                      children: [
                        Container(width: 3, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                _getActionIcon(entry.actionType),
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatActionType(entry.actionType),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.store_outlined,
                                          size: 10,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            entry.shopName.isNotEmpty
                                                ? entry.shopName
                                                : '#${entry.shopId}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right box - Price & Time
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  color: Colors.grey[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.pricePaid != null && entry.pricePaid! > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            Text(
                              entry.pricePaid!.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            DateFormat('MMM d, HH:mm').format(entry.createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom row: Full width details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey[50],
            child: Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                // Performed by
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 10,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      entry.performedBy ?? 'System',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),

                // Plan change
                if (entry.fromPlanName != null || entry.toPlanName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 12, color: Colors.grey[400]),
                      Text(
                        '${entry.fromPlanName ?? entry.fromPlanCode ?? '-'}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Icon(Icons.arrow_right_alt, size: 12, color: color),
                      Text(
                        '${entry.toPlanName ?? entry.toPlanCode ?? '-'}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),

                // Status change
                if (entry.previousStatus != null && entry.newStatus != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync_alt, size: 10, color: Colors.grey[400]),
                      Text(
                        '${entry.previousStatus}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 10,
                        color: Colors.grey[400],
                      ),
                      Text(
                        '${entry.newStatus}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                // Days extended
                if (entry.daysExtended != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: entry.daysExtended! > 0
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        entry.daysExtended! > 0
                            ? '+${entry.daysExtended}d'
                            : '${entry.daysExtended}d',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: entry.daysExtended! > 0
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),

                // Reason
                if (entry.reason != null && entry.reason!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 10,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          entry.reason!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                  ),

                // Notes
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notes, size: 10, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          entry.notes!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'upgrade':
      case 'upgraded':
        return Icons.arrow_upward;
      case 'downgrade':
      case 'downgraded':
        return Icons.arrow_downward;
      case 'extend':
      case 'extended':
      case 'extension':
        return Icons.add_circle_outline;
      case 'reduce':
      case 'reduced':
        return Icons.remove_circle_outline;
      case 'cancel':
      case 'cancelled':
      case 'cancellation':
        return Icons.cancel_outlined;
      case 'reactivate':
      case 'reactivated':
      case 'reactivation':
        return Icons.refresh;
      case 'create':
      case 'created':
      case 'creation':
        return Icons.add_box_outlined;
      case 'expire':
      case 'expired':
      case 'expiration':
        return Icons.timer_off_outlined;
      case 'renew':
      case 'renewed':
        return Icons.autorenew;
      default:
        return Icons.edit_outlined;
    }
  }

  Color _getActionColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'upgrade':
      case 'upgraded':
        return Colors.green;
      case 'downgrade':
      case 'downgraded':
        return Colors.orange;
      case 'extend':
      case 'extended':
      case 'extension':
        return Colors.blue;
      case 'reduce':
      case 'reduced':
        return Colors.orange;
      case 'cancel':
      case 'cancelled':
      case 'cancellation':
        return Colors.red;
      case 'reactivate':
      case 'reactivated':
      case 'reactivation':
        return Colors.teal;
      case 'create':
      case 'created':
      case 'creation':
        return Colors.purple;
      case 'expire':
      case 'expired':
      case 'expiration':
        return Colors.grey;
      case 'renew':
      case 'renewed':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatActionType(String actionType) {
    return actionType
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
