import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscriptions_list_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/work_queue_provider.dart';

/// The dashboard's "Needs attention" list: what an admin should act on today,
/// each row opening the place to act on it.
class WorkQueueCard extends ConsumerWidget {
  /// Shops listed under each expiring group before "See all".
  static const previewCount = 4;

  const WorkQueueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workQueueProvider);
    final queue = state.queue;
    final notifier = ref.read(workQueueProvider.notifier);

    return SectionCard(
      title: 'Needs attention',
      icon: Icons.inbox_outlined,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      trailing: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () => notifier.refresh(force: true),
            ),
      child: switch (queue) {
        null => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
        final q when q.isClear => const _AllClear(),
        final q => _QueueList(queue: q),
      },
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(
        icon: Icons.task_alt_rounded,
        color: context.status.success,
        size: 36,
      ),
      title: const Text('Nothing needs you right now'),
      subtitle: const Text(
        'No upgrade requests waiting, no plans ending this week and no '
        'lapsed shops.',
      ),
    );
  }
}

class _QueueList extends ConsumerWidget {
  final WorkQueue queue;
  const _QueueList({required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = context.status;
    final scheme = context.colors;
    final pending = queue.pendingRequests ?? 0;
    final trials = queue.trialsEnding;
    final paid = queue.paidExpiring;
    final lapsed = queue.lapsed ?? 0;
    final locks = queue.freeWithholdsSales == true;

    final groups = <Widget>[
      if (pending > 0)
        _GroupHeader(
          icon: Icons.upgrade_rounded,
          color: scheme.primary,
          title: _count(pending, 'upgrade request', 'waiting for review'),
          subtitle: _requestsSummary(queue.pendingPreview, pending),
          actionLabel: 'Review',
          onAction: () => openPendingUpgradeRequests(ref),
        ),
      if (trials.isNotEmpty)
        _ExpiringGroup(
          icon: Icons.hourglass_bottom_rounded,
          color: status.info,
          title: _count(trials.length, 'trial', 'ending within 7 days'),
          subtitle: locks
              ? 'When a trial ends the shop moves to Free and cannot open '
                    'new bills until a plan is paid.'
              : 'When a trial ends the shop moves to Free.',
          rows: trials,
          onSeeAll: () => openSubscriptionsWith(ref, status: 'trial'),
        ),
      if (paid.isNotEmpty)
        _ExpiringGroup(
          icon: Icons.event_busy_rounded,
          color: status.warning,
          title: _count(paid.length, 'plan', 'ending within 7 days'),
          subtitle:
              'Renews only once a payment for the next period is recorded '
              'or the plan is extended; otherwise the shop drops to Free.',
          rows: paid,
          onSeeAll: () => openSubscriptionsWith(
            ref,
            status: 'active',
            plan: SubscriptionPlanFilter.paid,
          ),
        ),
      if (lapsed > 0)
        _GroupHeader(
          icon: Icons.lock_clock_outlined,
          color: status.neutral,
          title: _count(lapsed, 'shop', 'lapsed to Free'),
          subtitle: locks
              ? 'Trial or plan ended. They cannot open new bills until a '
                    'plan is paid.'
              : 'Trial or plan ended.',
          actionLabel: 'View',
          onAction: () => openSubscriptionsWith(ref, status: 'expired'),
        ),
      if (queue.isPartial)
        ListTile(
          leading: Icon(Icons.error_outline_rounded, color: scheme.error),
          title: Text(
            "Couldn't load ${_failedParts(queue)}.",
            style: TextStyle(color: scheme.error),
          ),
          trailing: TextButton(
            onPressed: () =>
                ref.read(workQueueProvider.notifier).refresh(force: true),
            child: const Text('Retry'),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, g) in groups.indexed) ...[if (i > 0) const Divider(), g],
      ],
    );
  }

  /// "1 trial ending…", "3 trials ending…".
  static String _count(int n, String noun, String rest) =>
      '$n $noun${n == 1 ? '' : 's'} $rest';

  /// "Mekong Mart → Gold, Noy Cafe → Silver and 2 more".
  static String? _requestsSummary(List<UpgradeRequestDto> preview, int total) {
    if (preview.isEmpty) return null;
    final names = preview
        .map((r) => '${r.shopName} → ${r.localizedToPlanName('en')}')
        .join(', ');
    final more = total - preview.length;
    return more > 0 ? '$names and $more more' : names;
  }

  static String _failedParts(WorkQueue q) => [
    if (q.pendingRequests == null) 'upgrade requests',
    if (q.expiring == null) 'expiring plans',
    if (q.lapsed == null) 'lapsed shops',
  ].join(', ');
}

class _GroupHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GroupHeader({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBadge(icon: icon, color: color, size: 36),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: actionLabel == null
          ? null
          : FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
      onTap: onAction,
    );
  }
}

/// A group header followed by the soonest shops in it, each opening its
/// subscription.
class _ExpiringGroup extends ConsumerWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<AdminSubscription> rows;
  final VoidCallback onSeeAll;

  const _ExpiringGroup({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final more = rows.length - WorkQueueCard.previewCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupHeader(
          icon: icon,
          color: color,
          title: title,
          subtitle: subtitle,
        ),
        for (final s in rows.take(WorkQueueCard.previewCount))
          _ShopRow(subscription: s),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 60, bottom: 4),
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(more > 0 ? 'See all · $more more' : 'See all'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopRow extends ConsumerWidget {
  final AdminSubscription subscription;
  const _ShopRow({required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = subscription;
    final days = s.daysUntilExpiry;
    final when = days <= 0
        ? 'Ends today'
        : days == 1
        ? 'Ends tomorrow'
        : '$days days left';
    final plan = [
      if (s.planName != null && s.planName!.isNotEmpty) s.planName!,
      if (!s.isTrial && s.autoRenew) 'auto-renew on',
    ].join(' · ');

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 76, end: 16),
      title: Text(s.shopName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: plan.isEmpty ? null : Text(plan),
      trailing: StatusBadge(
        label: when,
        tone: days <= 1 ? StatusTone.danger : StatusTone.warning,
      ),
      onTap: () async {
        // Read before the await: this row may be gone when the page pops.
        final workQueue = ref.read(workQueueProvider.notifier);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubscriptionDetailPage(subscription: s),
          ),
        );
        // Whatever was done on the detail page may have moved the queue.
        workQueue.refresh(force: true);
      },
    );
  }
}
