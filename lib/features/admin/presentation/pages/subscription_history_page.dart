import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

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
        title: Text(context.tr(SubsText.subscriptionHistory)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const AppIcon(AppIcons.refresh),
            onPressed: _loadHistory,
          ),
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
                  const AppIcon(AppIcons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(SubsText.totalRecords(historyState.totalCount)),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (historyState.totalPages > 1)
                    Text(
                      context.tr(
                        SubsText.pageOf(
                          historyState.currentPage + 1,
                          historyState.totalPages,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: historyState.isLoading && historyState.history.isEmpty
                ? const AppLoadingView()
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
    return AppErrorView(error: error, onRetry: _loadHistory);
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(AppIcons.history, size: 64, color: context.colors.outline),
          const SizedBox(height: 16),
          Text(
            context.tr(SubsText.noHistoryFound),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.shopId != null
                ? context.tr(SubsText.noChangesHaveBeenMade)
                : context.tr(SubsText.noSubscriptionChangesRecorded),
            style: TextStyle(color: context.colors.onSurfaceVariant),
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
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant, width: 0.5),
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
                              AppIcon(
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
                                        AppIcon(
                                          AppIcons.shop,
                                          size: 10,
                                          color: context.colors.outline,
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            entry.shopName.isNotEmpty
                                                ? entry.shopName
                                                : '#${entry.shopId}',
                                            style: TextStyle(
                                              color: context
                                                  .colors
                                                  .onSurfaceVariant,
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
                  color: context.colors.surfaceContainer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.pricePaid != null && entry.pricePaid! > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppIcon(
                              AppIcons.dollar,
                              size: 14,
                              color: context.status.success,
                            ),
                            Text(
                              entry.pricePaid!.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: context.status.success,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppIcon(
                            AppIcons.clock,
                            size: 10,
                            color: context.colors.outline,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            AppDateFormat.of(
                              'MMM d, HH:mm',
                            ).format(entry.createdAt),
                            style: TextStyle(
                              color: context.colors.onSurfaceVariant,
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
            color: context.colors.surfaceContainer,
            child: Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                // Performed by
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      AppIcons.person,
                      size: 10,
                      color: context.colors.outline,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      entry.performedBy ?? context.tr(NavText.groupSystem),
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                // Plan change
                if (entry.fromPlanName != null || entry.toPlanName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.swap,
                        size: 12,
                        color: context.colors.outline,
                      ),
                      Text(
                        '${entry.fromPlanName ?? entry.fromPlanCode ?? '-'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      AppIcon(AppIcons.arrowRight, size: 12, color: color),
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
                      AppIcon(
                        AppIcons.swap,
                        size: 10,
                        color: context.colors.outline,
                      ),
                      Text(
                        '${entry.previousStatus}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      AppIcon(
                        AppIcons.chevronRight,
                        size: 10,
                        color: context.colors.outline,
                      ),
                      Text(
                        '${entry.newStatus}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                // Days extended
                if (entry.daysExtended != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.calendar,
                        size: 10,
                        color: entry.daysExtended! > 0
                            ? context.status.success
                            : context.status.warning,
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
                              ? context.status.success
                              : context.status.warning,
                        ),
                      ),
                    ],
                  ),

                // Reason
                if (entry.reason != null && entry.reason!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.info,
                        size: 10,
                        color: context.status.info,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          entry.reason!,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.status.info,
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
                      AppIcon(
                        AppIcons.notes,
                        size: 10,
                        color: context.colors.outline,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          entry.notes!,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.onSurfaceVariant,
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

  AppIconData _getActionIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'upgrade':
      case 'upgraded':
        return AppIcons.arrowUp;
      case 'downgrade':
      case 'downgraded':
        return AppIcons.arrowDown;
      case 'extend':
      case 'extended':
      case 'extension':
        return AppIcons.addCircle;
      case 'reduce':
      case 'reduced':
        return AppIcons.minusCircle;
      case 'cancel':
      case 'cancelled':
      case 'cancellation':
        return AppIcons.closeCircle;
      case 'reactivate':
      case 'reactivated':
      case 'reactivation':
        return AppIcons.refresh;
      case 'create':
      case 'created':
      case 'creation':
        return AppIcons.addSquare;
      case 'expire':
      case 'expired':
      case 'expiration':
        return AppIcons.timerOff;
      case 'renew':
      case 'renewed':
        return AppIcons.refresh;
      case 'auto_renew_enabled':
        return AppIcons.refresh;
      case 'auto_renew_disabled':
        return AppIcons.cloudOff;
      case 'trial_started':
      case 'trial_ended':
        return AppIcons.hourglass;
      case 'payment_received':
        return AppIcons.money;
      case 'payment_failed':
        return AppIcons.moneyOff;
      default:
        return AppIcons.edit;
    }
  }

  Color _getActionColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'upgrade':
      case 'upgraded':
        return context.status.success;
      case 'downgrade':
      case 'downgraded':
        return context.status.warning;
      case 'extend':
      case 'extended':
      case 'extension':
        return context.status.info;
      case 'reduce':
      case 'reduced':
        return context.status.warning;
      case 'cancel':
      case 'cancelled':
      case 'cancellation':
        return context.colors.error;
      case 'reactivate':
      case 'reactivated':
      case 'reactivation':
        return context.status.success;
      case 'create':
      case 'created':
      case 'creation':
        return context.colors.primary;
      case 'expire':
      case 'expired':
      case 'expiration':
        return context.status.neutral;
      case 'renew':
      case 'renewed':
        return context.status.success;
      case 'auto_renew_enabled':
        return context.status.success;
      case 'auto_renew_disabled':
        return context.status.warning;
      case 'trial_started':
      case 'trial_ended':
        return context.status.info;
      case 'payment_received':
        return context.status.success;
      case 'payment_failed':
        return context.colors.error;
      default:
        return context.status.neutral;
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
