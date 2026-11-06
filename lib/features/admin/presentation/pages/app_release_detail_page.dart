import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_actions.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';

/// One release: its full notes to read and copy, and every action on it.
class AppReleaseDetailPage extends ConsumerStatefulWidget {
  final AppRelease release;

  const AppReleaseDetailPage({super.key, required this.release});

  @override
  ConsumerState<AppReleaseDetailPage> createState() =>
      _AppReleaseDetailPageState();
}

class _AppReleaseDetailPageState extends ConsumerState<AppReleaseDetailPage> {
  static final _date = DateFormat('d MMM y, HH:mm');

  late AppRelease _release = widget.release;
  bool _busy = false;

  /// Runs an action that returns the release as it is now, and shows that.
  Future<void> _apply(
    Future<AppRelease?> Function(BuildContext, WidgetRef, AppRelease) action,
  ) async {
    setState(() => _busy = true);
    final updated = await action(context, ref, _release);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (updated != null) _release = updated;
    });
  }

  /// Starts a new release from this one and opens it when saved.
  Future<void> _copy(ReleaseCopy copy) async {
    final created = await AppReleaseActions.create(
      context,
      ref,
      template: _release,
      copy: copy,
    );
    if (created == null || !mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AppReleaseDetailPage(release: created)),
    );
  }

  Future<void> _delete() async {
    if (await AppReleaseActions.delete(context, ref, _release) && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _release;
    final platform = releasePlatforms[r.platform];
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final version = 'v${r.versionName} (${r.versionCode})';

    return Scaffold(
      appBar: AppBar(
        title: Text('${platformLabel(r.platform)} v${r.versionName}'),
        actions: [
          IconButton(
            tooltip: 'Edit notes',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _busy ? null : () => _apply(AppReleaseActions.edit),
          ),
          PopupMenuButton<VoidCallback>(
            tooltip: 'More',
            enabled: !_busy,
            onSelected: (run) => run(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: () => _copy(ReleaseCopy.nextVersion),
                child: const ListTile(
                  leading: Icon(Icons.content_copy_rounded),
                  title: Text('New version from this'),
                ),
              ),
              PopupMenuItem(
                value: () => _copy(ReleaseCopy.otherPlatform),
                child: const ListTile(
                  leading: Icon(Icons.devices_rounded),
                  title: Text('Copy to another platform'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _delete,
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: context.colors.error,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: what and where, and the one action that matters most.
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconBadge(
                          icon: platform?.$2 ?? Icons.devices_rounded,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title, style: context.text.titleLarge),
                              const SizedBox(height: 2),
                              Text(
                                '${platformLabel(r.platform)} · $version',
                                style: muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        StatusBadge.fromStatus(
                          r.isPublished ? 'published' : 'draft',
                        ),
                        if (r.isMandatory)
                          const StatusBadge(
                            label: 'Mandatory',
                            tone: StatusTone.danger,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      r.isPublished
                          ? (r.isMandatory
                                ? 'Live: shops on an older version must update.'
                                : 'Live: shops on an older version are offered '
                                      'this update.')
                          : 'Draft: no shop sees it until it is published.',
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (r.isPublished)
                          OutlinedButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _apply(AppReleaseActions.unpublish),
                            icon: const Icon(Icons.unpublished_outlined),
                            label: const Text('Unpublish'),
                          )
                        else
                          FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _apply(AppReleaseActions.publish),
                            icon: const Icon(Icons.publish_rounded),
                            label: const Text('Publish'),
                          ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _apply(AppReleaseActions.edit),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit notes'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _copy(ReleaseCopy.nextVersion),
                          icon: const Icon(Icons.content_copy_rounded),
                          label: const Text('New version from this'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              SectionCard(
                title: "What's new",
                icon: Icons.notes_rounded,
                subtitle: 'Shops see this exactly as written',
                trailing: TextButton.icon(
                  onPressed: () => AppReleaseActions.copy(
                    context,
                    AppReleaseActions.notesText(r),
                    what: 'Release notes',
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SelectableText(
                      r.changelog,
                      style: context.text.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              SectionCard(
                title: 'Details',
                icon: Icons.info_outline_rounded,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    _CopyRow(
                      label: 'Version',
                      value: r.versionName,
                      what: 'Version',
                    ),
                    _CopyRow(
                      label: 'Build',
                      value: '${r.versionCode}',
                      what: 'Build number',
                    ),
                    _CopyRow(
                      label: 'Download link',
                      value: r.downloadUrl,
                      what: 'Download link',
                    ),
                    _CopyRow(
                      label: 'Released',
                      value: _date.format(r.releasedAt.toLocal()),
                    ),
                    _CopyRow(
                      label: 'Last edited',
                      value: _date.format(r.updatedAt.toLocal()),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Platform, version and build cannot be changed after a '
                  'release is made. To fix them, use "New version from this" '
                  'or "Copy to another platform", then delete this one.',
                  style: muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label and value; with [what], a button copies the value.
class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final String? what;

  const _CopyRow({required this.label, required this.value, this.what});

  @override
  Widget build(BuildContext context) {
    final what = this.what;
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(color: context.colors.onSurfaceVariant),
      ),
      subtitle: SelectableText(
        value,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface,
        ),
      ),
      trailing: what == null
          ? null
          : IconButton(
              tooltip: 'Copy ${what.toLowerCase()}',
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () =>
                  AppReleaseActions.copy(context, value, what: what),
            ),
    );
  }
}
