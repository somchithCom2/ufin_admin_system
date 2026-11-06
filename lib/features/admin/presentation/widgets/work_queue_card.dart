import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
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
      title: context.tr(DashText.needsAttention),
      icon: AppIcons.inbox,
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
              tooltip: context.tr(CommonText.refresh),
              icon: const AppIcon(AppIcons.refresh, size: 20),
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
        icon: AppIcons.checkCircle,
        color: context.status.success,
        size: 36,
      ),
      title: Text(context.tr(DashText.allClear)),
      subtitle: Text(context.tr(DashText.allClearHint)),
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
          icon: AppIcons.upgrade,
          color: scheme.primary,
          title: context.tr(DashText.requestsWaiting(pending)),
          subtitle: _requestsSummary(context, queue.pendingPreview, pending),
          actionLabel: context.tr(DashText.review),
          onAction: () => openPendingUpgradeRequests(ref),
        ),
      if (trials.isNotEmpty)
        _ExpiringGroup(
          icon: AppIcons.hourglass,
          color: status.info,
          title: context.tr(DashText.trialsEnding(trials.length)),
          subtitle: context.tr(
            locks ? DashText.trialEndsLocks : DashText.trialEnds,
          ),
          rows: trials,
          onSeeAll: () => openSubscriptionsWith(ref, status: 'trial'),
        ),
      if (paid.isNotEmpty)
        _ExpiringGroup(
          icon: AppIcons.calendarX,
          color: status.warning,
          title: context.tr(DashText.plansEnding(paid.length)),
          subtitle: context.tr(DashText.paidRenewal),
          rows: paid,
          onSeeAll: () => openSubscriptionsWith(
            ref,
            status: 'active',
            plan: SubscriptionPlanFilter.paid,
          ),
        ),
      if (lapsed > 0)
        _GroupHeader(
          icon: AppIcons.timer,
          color: status.neutral,
          title: context.tr(DashText.shopsLapsed(lapsed)),
          subtitle: context.tr(locks ? DashText.lapsedLocks : DashText.lapsed),
          actionLabel: context.tr(CommonText.view),
          onAction: () => openSubscriptionsWith(ref, status: 'expired'),
        ),
      if (queue.isPartial)
        ListTile(
          leading: AppIcon(AppIcons.errorCircle, color: scheme.error),
          title: Text(
            context.tr(DashText.couldNotLoad(_failedParts(context, queue))),
            style: TextStyle(color: scheme.error),
          ),
          trailing: TextButton(
            onPressed: () =>
                ref.read(workQueueProvider.notifier).refresh(force: true),
            child: Text(context.tr(DashText.retry)),
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

  /// "Mekong Mart → Gold, Noy Cafe → Silver and 2 more".
  static String? _requestsSummary(
    BuildContext context,
    List<UpgradeRequestDto> preview,
    int total,
  ) {
    if (preview.isEmpty) return null;
    final names = preview
        .map(
          (r) =>
              '${r.shopName} → ${r.localizedToPlanName(context.language.name)}',
        )
        .join(', ');
    final more = total - preview.length;
    return more > 0 ? context.tr(DashText.andMore(names, more)) : names;
  }

  static String _failedParts(BuildContext context, WorkQueue q) => [
    if (q.pendingRequests == null) context.tr(DashText.partRequests),
    if (q.expiring == null) context.tr(DashText.partExpiring),
    if (q.lapsed == null) context.tr(DashText.partLapsed),
  ].join(', ');
}

class _GroupHeader extends StatelessWidget {
  final AppIconData icon;
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
  final AppIconData icon;
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
              child: Text(
                context.tr(
                  more > 0 ? DashText.seeAllMore(more) : DashText.seeAll,
                ),
              ),
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
        ? context.tr(DashText.endsToday)
        : days == 1
        ? context.tr(DashText.endsTomorrow)
        : context.tr(DashText.daysLeft(days));
    final plan = [
      if (s.planName != null && s.planName!.isNotEmpty) s.planName!,
      if (!s.isTrial && s.autoRenew) context.tr(DashText.autoRenewOn),
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
