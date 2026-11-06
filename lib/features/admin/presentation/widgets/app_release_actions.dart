import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';

/// Every release, newest build first within each platform.
final appReleasesProvider = FutureProvider<List<AppRelease>>((ref) async {
  final releases = await ref.watch(adminRepositoryProvider).getAppReleases();
  return sortReleases(releases);
});

/// Newest first: by release date, then by build number.
List<AppRelease> sortReleases(List<AppRelease> releases) =>
    [...releases]..sort((a, b) {
      final byDate = b.releasedAt.compareTo(a.releasedAt);
      return byDate != 0 ? byDate : b.versionCode.compareTo(a.versionCode);
    });

/// The release actions the list and the detail page share. Each returns the
/// release as the server has it afterwards, or `null` when nothing changed.
abstract final class AppReleaseActions {
  static void _changed(WidgetRef ref) => ref.invalidate(appReleasesProvider);

  /// Releases already made, for the form's next-build and duplicate checks.
  /// An unreadable list only loses those hints.
  static Future<List<AppRelease>> _known(WidgetRef ref) async {
    try {
      return await ref.read(appReleasesProvider.future);
    } catch (_) {
      return const [];
    }
  }

  static Future<AppRelease?> publish(
    BuildContext context,
    WidgetRef ref,
    AppRelease release,
  ) async {
    final platform = platformLabel(release.platform);
    final ok = await AppDialogs.confirm(
      context,
      title: 'Publish v${release.versionName}?',
      message: release.isMandatory
          ? 'Every $platform shop on an older version will be required to '
                'update before using the app.'
          : 'Every $platform shop on an older version will be offered this '
                'update.',
      confirmLabel: 'Publish',
      icon: Icons.publish_rounded,
    );
    if (!ok || !context.mounted) return null;
    return _run(
      context,
      ref,
      () => ref.read(adminRepositoryProvider).publishAppRelease(release.id),
      'v${release.versionName} published',
    );
  }

  static Future<AppRelease?> unpublish(
    BuildContext context,
    WidgetRef ref,
    AppRelease release,
  ) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Unpublish v${release.versionName}?',
      message:
          'Shops will stop being offered this update. Shops that already '
          'installed it are not affected.',
      confirmLabel: 'Unpublish',
      icon: Icons.unpublished_outlined,
    );
    if (!ok || !context.mounted) return null;
    return _run(
      context,
      ref,
      () => ref.read(adminRepositoryProvider).unpublishAppRelease(release.id),
      'v${release.versionName} unpublished',
    );
  }

  /// True when the release was deleted.
  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
    AppRelease release,
  ) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'Delete v${release.versionName}?',
      message: release.isPublished
          ? 'This release is live. Deleting it stops shops being offered it, '
                'and it is removed permanently.'
          : 'This draft is removed permanently.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(adminRepositoryProvider).deleteAppRelease(release.id);
      _changed(ref);
      messenger.showSuccess('v${release.versionName} deleted');
      return true;
    } catch (e) {
      if (context.mounted) AppFeedback.error(context, e);
      return false;
    }
  }

  /// Edits the notes, link and mandatory flag.
  static Future<AppRelease?> edit(
    BuildContext context,
    WidgetRef ref,
    AppRelease release,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    AppRelease? updated;
    final saved = await showAppReleaseForm(
      context,
      existing: release,
      save: (_, update) async {
        updated = await ref
            .read(adminRepositoryProvider)
            .updateAppRelease(release.id, update!);
        _changed(ref);
      },
    );
    if (saved) messenger.showSuccess('Release updated');
    return updated;
  }

  /// Makes a new draft: blank, or started from [template] as [copy] says.
  static Future<AppRelease?> create(
    BuildContext context,
    WidgetRef ref, {
    AppRelease? template,
    ReleaseCopy copy = ReleaseCopy.nextVersion,
    String? platform,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final releases = await _known(ref);
    if (!context.mounted) return null;
    AppRelease? created;
    final saved = await showAppReleaseForm(
      context,
      template: template,
      copy: copy,
      releases: releases,
      initialPlatform: platform,
      save: (create, _) async {
        created = await ref
            .read(adminRepositoryProvider)
            .createAppRelease(create!);
        _changed(ref);
      },
    );
    if (saved) {
      final r = created;
      messenger.showSuccess(
        r == null
            ? 'Release saved as draft'
            : '${platformLabel(r.platform)} v${r.versionName} saved as draft',
      );
    }
    return created;
  }

  /// Puts [text] on the clipboard and says what was copied.
  static Future<void> copy(
    BuildContext context,
    String text, {
    required String what,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) AppFeedback.success(context, '$what copied');
  }

  /// The notes as a shop sees them, ready to paste into a store listing.
  static String notesText(AppRelease r) => '${r.title}\n\n${r.changelog}';

  static Future<AppRelease?> _run(
    BuildContext context,
    WidgetRef ref,
    Future<AppRelease> Function() action,
    String done,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await action();
      _changed(ref);
      messenger.showSuccess(done);
      return result;
    } catch (e) {
      if (context.mounted) AppFeedback.error(context, e);
      return null;
    }
  }
}
