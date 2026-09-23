import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Release'),
        content: Text(
          'Are you sure you want to delete ${release.versionName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
    final statusColor = release.isPublished
        ? context.status.success
        : context.status.warning;
    final statusText = release.isPublished ? 'Published' : 'Draft';

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
                      Row(
                        children: [
                          Chip(
                            label: Text(release.platform),
                            backgroundColor: context.status.info.withAlpha(100),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(statusText),
                            backgroundColor: statusColor.withAlpha(100),
                          ),
                          if (release.isMandatory)
                            Chip(
                              label: Text('Mandatory'),
                              backgroundColor: context.colors.error,
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
                  'Released: ${release.releasedAt.toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateReleaseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final versionNameCtrl = TextEditingController();
    final versionCodeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final changelogCtrl = TextEditingController();
    final downloadUrlCtrl = TextEditingController();
    String platform = 'android';
    bool isMandatory = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(8),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create New Release'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField(
                        initialValue: platform,
                        items: const [
                          DropdownMenuItem(
                            value: 'android',
                            child: Text('🤖 Android'),
                          ),
                          DropdownMenuItem(value: 'ios', child: Text('🍎 iOS')),
                          DropdownMenuItem(
                            value: 'macos',
                            child: Text('🖥️ macOS'),
                          ),
                          DropdownMenuItem(
                            value: 'windows',
                            child: Text('🪟 Windows'),
                          ),
                        ],
                        onChanged: (value) => platform = value ?? 'android',
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: versionNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Version Name (e.g. 1.0.0)',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: versionCodeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Version Code',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: changelogCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Changelog',
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: downloadUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Download URL',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: isMandatory,
                        onChanged: (v) =>
                            setDialogState(() => isMandatory = v ?? false),
                        title: const Text('Mandatory Update'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // Save scaffold messenger reference before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        try {
                          final request = CreateAppReleaseRequest(
                            versionName: versionNameCtrl.text,
                            versionCode: int.parse(versionCodeCtrl.text),
                            platform: platform,
                            title: titleCtrl.text,
                            changelog: changelogCtrl.text,
                            downloadUrl: downloadUrlCtrl.text,
                            isMandatory: isMandatory,
                          );

                          await _repository.createAppRelease(request);
                          ref.invalidate(appReleasesProvider);
                          ref.invalidate(appReleasesByPlatformProvider);

                          navigator.pop();
                          scaffoldMessenger.showSuccess(
                            'Release created successfully',
                          );
                        } catch (e) {
                          scaffoldMessenger.showError(e);
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditReleaseDialog(BuildContext context, AppRelease release) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: release.title);
    final changelogCtrl = TextEditingController(text: release.changelog);
    final downloadUrlCtrl = TextEditingController(text: release.downloadUrl);
    bool isMandatory = release.isMandatory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(8),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Release'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: changelogCtrl,
                      decoration: const InputDecoration(labelText: 'Changelog'),
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: downloadUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Download URL',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: isMandatory,
                      onChanged: (v) =>
                          setDialogState(() => isMandatory = v ?? false),
                      title: const Text('Mandatory Update'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // Save scaffold messenger reference before async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        try {
                          final request = UpdateAppReleaseRequest(
                            title: titleCtrl.text,
                            changelog: changelogCtrl.text,
                            downloadUrl: downloadUrlCtrl.text,
                            isMandatory: isMandatory,
                          );

                          await _repository.updateAppRelease(
                            release.id,
                            request,
                          );
                          ref.invalidate(appReleasesProvider);
                          ref.invalidate(appReleasesByPlatformProvider);

                          navigator.pop();
                          scaffoldMessenger.showSuccess(
                            'Release updated successfully',
                          );
                        } catch (e) {
                          scaffoldMessenger.showError(e);
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
