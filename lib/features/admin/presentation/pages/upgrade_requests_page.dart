import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

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
    (label: 'Pending', value: 'PENDING'),
    (label: 'Approved', value: 'APPROVED'),
    (label: 'Rejected', value: 'REJECTED'),
    (label: 'All', value: null),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Upgrade Requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
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
                      label: Text(f.label),
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
            ? 'Request #${request.id} approved'
            : 'Request #${request.id} rejected',
      );
    } catch (e) {
      messenger.showError(
        'Could not ${approve ? 'approve' : 'reject'} request #${request.id}: '
        '${friendlyError(e)}',
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
    return const AppEmptyView(
      icon: Icons.upgrade_rounded,
      title: 'No upgrade requests',
      message: 'Requests from shops wanting to change plans will appear here.',
    );
  }

  Widget _buildPagination(UpgradeRequestsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _currentPage > 0
                ? () => _load(page: _currentPage - 1)
                : null,
          ),
          Text('Page ${_currentPage + 1} of ${state.totalPages}'),
          IconButton(
            tooltip: 'Next page',
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
  final from = request.fromPlanName['en'] ?? request.fromPlanCode;
  final to = request.toPlanName['en'] ?? request.toPlanCode;
  return AppDialogs.confirmWithReason(
    context,
    title: approve ? 'Approve request?' : 'Reject request?',
    message: approve
        ? '${request.shopName} moves from $from to $to '
              '(${request.billingCycle}).'
        : '${request.shopName} stays on $from. The shop sees your note.',
    confirmLabel: approve ? 'Approve' : 'Reject',
    reasonLabel: 'Review note',
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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
                  label: request.fromPlanName['en'] ?? request.fromPlanCode,
                  color: context.status.neutral,
                ),
                const Icon(Icons.arrow_forward_rounded, size: 16),
                _PlanBadge(
                  label: request.toPlanName['en'] ?? request.toPlanCode,
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
              text: 'Requested by ${request.requestedByUsername}',
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
                text:
                    'Reviewed by ${request.reviewedByUsername}'
                    '${request.reviewedAt != null ? ' on ${dateFormat.format(request.reviewedAt!.toLocal())}' : ''}',
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
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => onApprove(null),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
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
