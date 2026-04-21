import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _load(page: _currentPage),
          ),
        ],
      ),
      body: Column(
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
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildError(state.error!)
                : state.requests.isEmpty
                ? _buildEmpty()
                : _buildList(state.requests, colorScheme),
          ),

          // Pagination
          if (state.totalPages > 1) _buildPagination(state),
        ],
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
      initialNote: note,
    );
    if (confirmed == null) return;

    final notifier = ref.read(upgradeRequestsProvider.notifier);
    final success = approve
        ? await notifier.approveRequest(request.id, reviewNote: confirmed)
        : await notifier.rejectRequest(request.id, reviewNote: confirmed);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Request #${request.id} approved'
                : 'Request #${request.id} rejected',
          ),
          backgroundColor: approve ? Colors.green : Colors.orange,
        ),
      );
    } else {
      final error = ref.read(upgradeRequestsProvider).error ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _load(page: _currentPage),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No upgrade requests',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(UpgradeRequestsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => _load(page: _currentPage - 1)
                : null,
          ),
          Text('Page ${_currentPage + 1} of ${state.totalPages}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < state.totalPages - 1
                ? () => _load(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Dialog that collects an optional reviewNote and returns it on confirm.
/// Returns null if cancelled.
Future<String?> _showReviewDialog(
  BuildContext context, {
  required UpgradeRequestDto request,
  required bool approve,
  String? initialNote,
}) {
  final controller = TextEditingController(text: initialNote);
  final title = approve ? 'Approve Request' : 'Reject Request';
  final actionLabel = approve ? 'Approve' : 'Reject';
  final actionColor = approve ? Colors.green : Colors.red;

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(ctx).style,
              children: [
                const TextSpan(text: 'Shop: '),
                TextSpan(
                  text: request.shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.fromPlanName['en'] ?? request.fromPlanCode} → '
            '${request.toPlanName['en'] ?? request.toPlanCode}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Review note (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: actionColor),
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
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
    final statusColor = _statusColor(request.status);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      elevation: 1,
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
                _StatusChip(status: request.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),

            // Plan change
            Row(
              children: [
                _PlanBadge(
                  label: request.fromPlanName['en'] ?? request.fromPlanCode,
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                _PlanBadge(
                  label: request.toPlanName['en'] ?? request.toPlanCode,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
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
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => onApprove(null),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
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
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
