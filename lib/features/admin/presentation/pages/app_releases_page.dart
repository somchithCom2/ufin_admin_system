import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';

final appReleasesProvider = FutureProvider<List<AppRelease>>((ref) async {
  final repository = AdminRepository();
  return repository.getAppReleases();
});

final appReleasesByPlatformProvider =
    FutureProvider.family<List<AppRelease>, String>((ref, platform) async {
      final repository = AdminRepository();
      return repository.getAppReleasesByPlatform(platform);
    });

class AppReleasesPage extends ConsumerStatefulWidget {
  const AppReleasesPage({super.key});

  @override
  ConsumerState<AppReleasesPage> createState() => _AppReleasesPageState();
}

class _AppReleasesPageState extends ConsumerState<AppReleasesPage> {
  String? _selectedPlatform;
  late AdminRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = AdminRepository();
  }

  Future<void> _publishRelease(AppRelease release) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Publish ${release.versionName}?',
      message: release.isMandatory
          ? 'Every ${release.platform} shop on an older version will be '
                'required to update before using the app.'
          : 'Every ${release.platform} shop on an older version will be '
                'offered this update.',
      confirmLabel: 'Publish',
      icon: Icons.publish_rounded,
    );
    if (!ok || !mounted) return;
    try {
      await _repository.publishAppRelease(release.id);
      ref.invalidate(appReleasesProvider);
      ref.invalidate(appReleasesByPlatformProvider);
      if (!mounted) return;
      AppFeedback.success(context, 'Release published successfully');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, e);
    }
  }

  Future<void> _unpublishRelease(AppRelease release) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Unpublish ${release.versionName}?',
      message:
          'Shops will stop being offered this update. Shops that already '
          'installed it are not affected.',
      confirmLabel: 'Unpublish',
      icon: Icons.unpublished_outlined,
    );
    if (!ok || !mounted) return;
    try {
      await _repository.unpublishAppRelease(release.id);
      ref.invalidate(appReleasesProvider);
      ref.invalidate(appReleasesByPlatformProvider);
      if (!mounted) return;
      AppFeedback.success(context, 'Release unpublished successfully');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, e);
    }
  }

  Future<void> _deleteRelease(AppRelease release) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Delete ${release.versionName}?',
      message: 'This release is removed permanently.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    try {
      await _repository.deleteAppRelease(release.id);
      ref.invalidate(appReleasesProvider);
      ref.invalidate(appReleasesByPlatformProvider);
      if (!mounted) return;
      AppFeedback.success(context, 'Release deleted successfully');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final releasesAsync = _selectedPlatform != null
        ? ref.watch(appReleasesByPlatformProvider(_selectedPlatform!))
        : ref.watch(appReleasesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('App Releases'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateReleaseDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Release'),
            ),
          ),
        ],
      ),
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Platform filter
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    const Text('Filter by Platform:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedPlatform,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Platforms'),
                          ),
                          const DropdownMenuItem(
                            value: 'android',
                            child: Text('🤖 Android'),
                          ),
                          const DropdownMenuItem(
                            value: 'ios',
                            child: Text('🍎 iOS'),
                          ),
                          const DropdownMenuItem(
                            value: 'macos',
                            child: Text('🖥️ macOS'),
                          ),
                          const DropdownMenuItem(
                            value: 'windows',
                            child: Text('🪟 Windows'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPlatform = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Releases list
              Expanded(
                child: releasesAsync.when(
                  loading: () => const AppLoadingView(),
                  error: (error, stack) => AppErrorView(
                    error: error,
                    onRetry: () => _selectedPlatform != null
                        ? ref.invalidate(
                            appReleasesByPlatformProvider(_selectedPlatform!),
                          )
                        : ref.invalidate(appReleasesProvider),
                  ),
                  data: (releases) {
                    if (releases.isEmpty) {
                      return const AppEmptyView(
                        icon: Icons.system_update_outlined,
                        title: 'No releases yet',
                        message:
                            'Publish a release to notify users of new app versions.',
                      );
                    }

                    return ListView.builder(
                      itemCount: releases.length,
                      itemBuilder: (context, index) {
                        final release = releases[index];
                        return _buildReleaseCard(release);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseCard(AppRelease release) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.versionName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          StatusBadge(
                            label: humanize(release.platform),
                            tone: StatusTone.neutral,
                          ),
                          StatusBadge.fromStatus(
                            release.isPublished ? 'published' : 'draft',
                          ),
                          if (release.isMandatory)
                            const StatusBadge(
                              label: 'Mandatory',
                              tone: StatusTone.danger,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (!release.isPublished)
                      PopupMenuItem(
                        onTap: () => _publishRelease(release),
                        child: const Row(
                          children: [
                            Icon(Icons.publish),
                            SizedBox(width: 8),
                            Text('Publish'),
                          ],
                        ),
                      ),
                    if (release.isPublished)
                      PopupMenuItem(
                        onTap: () => _unpublishRelease(release),
                        child: const Row(
                          children: [
                            Icon(Icons.unpublished),
                            SizedBox(width: 8),
                            Text('Unpublish'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      onTap: () => _showEditReleaseDialog(context, release),
                      child: const Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _deleteRelease(release),
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: context.colors.error),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: context.colors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Title: ${release.title}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Changelog:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              release.changelog,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Version Code: ${release.versionCode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Released ${DateFormat('d MMM y, HH:mm').format(release.releasedAt.toLocal())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateReleaseDialog(BuildContext context) => _openForm();

  void _showEditReleaseDialog(BuildContext context, AppRelease release) =>
      _openForm(release);

  Future<void> _openForm([AppRelease? existing]) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showAppReleaseForm(
      context,
      existing: existing,
      initialPlatform: _selectedPlatform,
      save: (create, update) async {
        if (create != null) {
          await _repository.createAppRelease(create);
        } else {
          await _repository.updateAppRelease(existing!.id, update!);
        }
        ref.invalidate(appReleasesProvider);
        ref.invalidate(appReleasesByPlatformProvider);
      },
    );
    if (saved) {
      messenger.showSuccess(
        existing == null ? 'Release saved as draft' : 'Release updated',
      );
    }
  }
}
