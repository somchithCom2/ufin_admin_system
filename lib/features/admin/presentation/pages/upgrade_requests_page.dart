import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

/// Set by another page (the dashboard's work queue) to open the list on
/// Pending, whatever filter was left selected. The page clears it.
final upgradeRequestsShowPendingProvider = StateProvider<bool>((ref) => false);

class UpgradeRequestsPage extends ConsumerStatefulWidget {
  const UpgradeRequestsPage({super.key});

  @override
  ConsumerState<UpgradeRequestsPage> createState() =>
      _UpgradeRequestsPageState();
}

class _UpgradeRequestsPageState extends ConsumerState<UpgradeRequestsPage> {
  String? _statusFilter = 'PENDING';
  int _currentPage = 0;

  static const _statusFilters = [
    (label: Tr('Pending', 'ລໍຖ້າ'), value: 'PENDING'),
    (label: Tr('Approved', 'ອະນຸມັດແລ້ວ'), value: 'APPROVED'),
    (label: Tr('Rejected', 'ຖືກປະຕິເສດ'), value: 'REJECTED'),
    (label: CommonText.all, value: null),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // A first visit opens on Pending anyway; drop a request made before it.
      ref.read(upgradeRequestsShowPendingProvider.notifier).state = false;
      _load();
    });
  }

  void _load({int page = 0}) {
    setState(() => _currentPage = page);
    ref
        .read(upgradeRequestsProvider.notifier)
        .loadRequests(page: page, status: _statusFilter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upgradeRequestsProvider);
    // The page stays alive between visits, so a later request arrives here.
    ref.listen(upgradeRequestsShowPendingProvider, (_, show) {
      if (!show) return;
      ref.read(upgradeRequestsShowPendingProvider.notifier).state = false;
      setState(() => _statusFilter = 'PENDING');
      _load();
    });
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(NavText.upgradeRequests)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _load(page: _currentPage),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Status filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: _statusFilters.map((f) {
                  final isSelected = _statusFilter == f.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(context.tr(f.label)),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _statusFilter = f.value);
                        _load();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Content
            Expanded(
              child: state.isLoading && state.requests.isEmpty
                  ? const AppLoadingView()
                  : state.error != null && state.requests.isEmpty
                  ? _buildError(state.error!)
                  : state.requests.isEmpty
                  ? _buildEmpty()
                  : _buildList(state.requests, colorScheme),
            ),

            // Pagination
            if (state.totalPages > 1) _buildPagination(state),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<UpgradeRequestDto> items, ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _RequestCard(
        request: items[index],
        onApprove: (note) => _review(items[index], approve: true, note: note),
        onReject: (note) => _review(items[index], approve: false, note: note),
      ),
    );
  }

  Future<void> _review(
    UpgradeRequestDto request, {
    required bool approve,
    String? note,
  }) async {
    final confirmed = await _showReviewDialog(
      context,
      request: request,
      approve: approve,
    );
    if (confirmed == null) return;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(upgradeRequestsProvider.notifier);
    try {
      if (approve) {
        await notifier.approveRequest(
          request.id,
          reviewNote: confirmed.isEmpty ? null : confirmed,
        );
      } else {
        await notifier.rejectRequest(
          request.id,
          reviewNote: confirmed.isEmpty ? null : confirmed,
        );
      }
      messenger.showSuccess(
        approve
            ? FinText.requestApproved(request.id).current
            : FinText.requestRejected(request.id).current,
      );
    } catch (e) {
      messenger.showError(
        approve
            ? FinText.couldNotApproveRequest(
                request.id,
                friendlyError(e),
              ).current
            : FinText.couldNotRejectRequest(
                request.id,
                friendlyError(e),
              ).current,
      );
    }
  }

  Widget _buildError(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => _load(page: _currentPage),
    );
  }

  Widget _buildEmpty() {
    return AppEmptyView(
      icon: Icons.upgrade_rounded,
      title: context.tr(FinText.noUpgradeRequests),
      message: context.tr(FinText.requestsFromShopsWantingTo),
    );
  }

  Widget _buildPagination(UpgradeRequestsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: context.tr(FinText.previousPage2),
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _currentPage > 0
                ? () => _load(page: _currentPage - 1)
                : null,
          ),
          Text(context.tr(FinText.pageOf2(_currentPage + 1, state.totalPages))),
          IconButton(
            tooltip: context.tr(FinText.nextPage2),
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _currentPage < state.totalPages - 1
                ? () => _load(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Asks for confirmation and an optional review note. Returns the note
/// (possibly empty) on confirm, or null if cancelled.
Future<String?> _showReviewDialog(
  BuildContext context, {
  required UpgradeRequestDto request,
  required bool approve,
}) {
  final from =
      request.fromPlanName[context.language.name] ??
      request.fromPlanName['en'] ??
      request.fromPlanCode;
  final to =
      request.toPlanName[context.language.name] ??
      request.toPlanName['en'] ??
      request.toPlanCode;
  return AppDialogs.confirmWithReason(
    context,
    title: approve
        ? context.tr(FinText.approveRequest)
        : context.tr(FinText.rejectRequest),
    message: approve
        ? context.tr(
            FinText.movesFromTo(
              request.shopName,
              from,
              to,
              request.billingCycle,
            ),
          )
        : context.tr(FinText.staysOnTheShopSees(request.shopName, from)),
    confirmLabel: approve
        ? context.tr(CommonText.approve)
        : context.tr(CommonText.reject),
    reasonLabel: context.tr(FinText.reviewNote),
    destructive: !approve,
    icon: approve ? Icons.check_rounded : Icons.close_rounded,
  );
}

class _RequestCard extends StatelessWidget {
  final UpgradeRequestDto request;
  final void Function(String? note) onApprove;
  final void Function(String? note) onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = request.status == 'PENDING';
    final dateFormat = AppDateFormat.of('dd MMM yyyy, HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.shopName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge.fromStatus(request.status),
              ],
            ),
            const SizedBox(height: 8),

            // Plan change
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _PlanBadge(
                  label:
                      request.fromPlanName[context.language.name] ??
                      request.fromPlanName['en'] ??
                      request.fromPlanCode,
                  color: context.status.neutral,
                ),
                const Icon(Icons.arrow_forward_rounded, size: 16),
                _PlanBadge(
                  label:
                      request.toPlanName[context.language.name] ??
                      request.toPlanName['en'] ??
                      request.toPlanCode,
                  color: context.colors.primary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.billingCycle,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Meta
            _MetaRow(
              icon: Icons.person_outline,
              text: context.tr(
                FinText.requestedBy(request.requestedByUsername),
              ),
            ),
            _MetaRow(
              icon: Icons.access_time,
              text: dateFormat.format(request.createdAt.toLocal()),
            ),
            if (request.notes != null && request.notes!.isNotEmpty)
              _MetaRow(icon: Icons.notes, text: request.notes!),
            if (request.reviewedByUsername != null) ...[
              const Divider(height: 16),
              _MetaRow(
                icon: Icons.rate_review_outlined,
                text: request.reviewedAt == null
                    ? context.tr(FinText.reviewedBy(request.reviewedByUsername))
                    : context.tr(
                        FinText.reviewedByOn(
                          request.reviewedByUsername,
                          dateFormat.format(request.reviewedAt!.toLocal()),
                        ),
                      ),
              ),
              if (request.reviewNote != null && request.reviewNote!.isNotEmpty)
                _MetaRow(
                  icon: Icons.comment_outlined,
                  text: request.reviewNote!,
                ),
            ],

            // Actions (only for PENDING)
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onReject(null),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(context.tr(CommonText.reject)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => onApprove(null),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(context.tr(CommonText.approve)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PlanBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
