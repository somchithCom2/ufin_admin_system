import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/app_release_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_actions.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';

class AppReleasesPage extends ConsumerStatefulWidget {
  const AppReleasesPage({super.key});

  @override
  ConsumerState<AppReleasesPage> createState() => _AppReleasesPageState();
}

class _AppReleasesPageState extends ConsumerState<AppReleasesPage> {
  /// `null` shows every platform.
  String? _platform;

  void _open(AppRelease release) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AppReleaseDetailPage(release: release)),
  );

  /// Starts a release (blank, or from [template]) and opens it once saved.
  Future<void> _create({AppRelease? template, ReleaseCopy? copy}) async {
    final created = await AppReleaseActions.create(
      context,
      ref,
      template: template,
      copy: copy ?? ReleaseCopy.nextVersion,
      platform: _platform,
    );
    if (created != null && mounted) _open(created);
  }

  Widget _platformFilter(List<AppRelease> releases) {
    int count(String p) => releases.where((r) => r.platform == p).length;
    return FilterSelect<String>(
      icon: AppIcons.devices,
      label: context.tr(CommonText.platform),
      value: _platform,
      allLabel: context.tr(ReleaseText.all(releases.length)),
      options: [
        for (final e in releasePlatforms.entries)
          FilterOption(
            e.key,
            '${e.value.$1} · ${count(e.key)}',
            icon: e.value.$2,
          ),
      ],
      onChanged: (p) => setState(() => _platform = p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final releasesAsync = ref.watch(appReleasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(NavText.appReleases)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const AppIcon(AppIcons.refresh),
            onPressed: () => ref.invalidate(appReleasesProvider),
          ),
        ],
      ),
      // Same place as every other page's create action; the AppBar keeps
      // its width for the title on phones.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(),
        icon: const AppIcon(AppIcons.add),
        label: Text(context.tr(ReleaseText.newRelease)),
      ),
      body: ContentWidth(
        child: releasesAsync.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(appReleasesProvider),
          ),
          data: (all) {
            final shown = _platform == null
                ? all
                : all.where((r) => r.platform == _platform).toList();
            return Column(
              children: [
                FilterBar(filters: [_platformFilter(all)]),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.refresh(appReleasesProvider.future),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // Bottom space keeps the last card clear of the FAB.
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        88,
                      ),
                      children: [
                        if (shown.isEmpty)
                          AppEmptyView(
                            icon: AppIcons.appUpdate,
                            title: _platform == null
                                ? context.tr(ReleaseText.noReleasesYet)
                                : context.tr(
                                    ReleaseText.noReleasesYet2(
                                      platformLabel(_platform!),
                                    ),
                                  ),
                            message: context.tr(
                              ReleaseText.createAReleaseThenPublish,
                            ),
                          )
                        else
                          for (final r in shown)
                            _ReleaseCard(
                              release: r,
                              onOpen: () => _open(r),
                              onCopy: (copy) =>
                                  _create(template: r, copy: copy),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReleaseCard extends ConsumerWidget {
  static DateFormat get _date => AppDateFormat.of('d MMM y');

  final AppRelease release;
  final VoidCallback onOpen;
  final ValueChanged<ReleaseCopy> onCopy;

  const _ReleaseCard({
    required this.release,
    required this.onOpen,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = release;
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconBadge(
                  icon: releasePlatforms[r.platform]?.$2 ?? AppIcons.devices,
                  color: context.colors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'v${r.versionName}',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.tr(
                        ReleaseText.build(
                          platformLabel(r.platform),
                          r.versionCode,
                          _date.format(r.releasedAt.toLocal()),
                        ),
                      ),
                      style: muted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        StatusBadge.fromStatus(
                          r.isPublished ? 'published' : 'draft',
                        ),
                        if (r.isMandatory)
                          StatusBadge(
                            label: context.tr(ReleaseText.mandatory),
                            tone: StatusTone.danger,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      r.changelog,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<VoidCallback>(
                icon: const AppIcon(AppIcons.moreVertical),
                tooltip: context.tr(NavText.actions),
                onSelected: (run) => run(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: () => r.isPublished
                        ? AppReleaseActions.unpublish(context, ref, r)
                        : AppReleaseActions.publish(context, ref, r),
                    child: ListTile(
                      leading: AppIcon(
                        r.isPublished ? AppIcons.eyeOff : AppIcons.upload,
                      ),
                      title: Text(
                        r.isPublished
                            ? context.tr(ReleaseText.unpublish)
                            : context.tr(ReleaseText.publish),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: () => AppReleaseActions.edit(context, ref, r),
                    child: ListTile(
                      leading: AppIcon(AppIcons.edit),
                      title: Text(context.tr(ReleaseText.editNotes)),
                    ),
                  ),
                  PopupMenuItem(
                    value: () => onCopy(ReleaseCopy.nextVersion),
                    child: ListTile(
                      leading: AppIcon(AppIcons.copy),
                      title: Text(context.tr(ReleaseText.newVersionFromThis)),
                    ),
                  ),
                  PopupMenuItem(
                    value: () => onCopy(ReleaseCopy.otherPlatform),
                    child: ListTile(
                      leading: AppIcon(AppIcons.devices),
                      title: Text(
                        context.tr(ReleaseText.copyToAnotherPlatform),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: () => AppReleaseActions.copy(
                      context,
                      AppReleaseActions.notesText(r),
                      what: context.tr(ReleaseText.releaseNotes),
                    ),
                    child: ListTile(
                      leading: AppIcon(AppIcons.copy),
                      title: Text(context.tr(ReleaseText.copyNotes)),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: () => AppReleaseActions.delete(context, ref, r),
                    child: ListTile(
                      leading: AppIcon(
                        AppIcons.delete,
                        color: context.colors.error,
                      ),
                      title: Text(
                        context.tr(CommonText.delete),
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
