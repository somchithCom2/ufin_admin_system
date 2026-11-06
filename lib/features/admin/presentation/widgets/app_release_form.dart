import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

const releasePlatforms = <String, (String, IconData)>{
  'android': ('Android', Icons.android_rounded),
  'ios': ('iOS', Icons.phone_iphone_rounded),
  'macos': ('macOS', Icons.laptop_mac_rounded),
  'windows': ('Windows', Icons.desktop_windows_rounded),
};

String platformLabel(String platform) =>
    releasePlatforms[platform]?.$1 ?? humanize(platform);

/// How a new release starts from an existing one.
enum ReleaseCopy {
  /// Same platform, next version: the notes and link carry over, the version
  /// name and build number move on.
  nextVersion,

  /// The same version for another platform, e.g. the iOS build of an Android
  /// release.
  otherPlatform,
}

/// "2.2.0" → "2.2.1", "1.9" → "1.10". Anything after `+` or `-` (a build or
/// pre-release tag) is dropped; a name whose last part is not a number is
/// returned unchanged.
String nextVersionName(String name) {
  final core = name.trim().split(RegExp(r'[+-]')).first;
  final parts = core.split('.');
  final last = int.tryParse(parts.last);
  if (last == null) return name.trim();
  parts[parts.length - 1] = '${last + 1}';
  return parts.join('.');
}

/// One more than the highest build number on [platform], or `null` when the
/// platform has no release yet.
int? nextVersionCode(Iterable<AppRelease> releases, String platform) {
  int? highest;
  for (final r in releases) {
    if (r.platform == platform &&
        (highest == null || r.versionCode > highest)) {
      highest = r.versionCode;
    }
  }
  return highest == null ? null : highest + 1;
}

/// The download link of the newest release on [platform], or `null`.
String? latestDownloadUrl(Iterable<AppRelease> releases, String platform) {
  AppRelease? newest;
  for (final r in releases) {
    if (r.platform == platform &&
        (newest == null || r.versionCode > newest.versionCode)) {
      newest = r;
    }
  }
  return newest?.downloadUrl;
}

/// Opens the create (when [existing] is null) or edit form. [save] should
/// throw on failure; the form then stays open with the error shown.
///
/// [template] with [copy] starts a new release from an existing one.
/// [releases] are the releases already made: they suggest the next build
/// number and stop a platform getting the same version twice.
Future<bool> showAppReleaseForm(
  BuildContext context, {
  AppRelease? existing,
  AppRelease? template,
  ReleaseCopy copy = ReleaseCopy.nextVersion,
  List<AppRelease> releases = const [],
  String? initialPlatform,
  required Future<void> Function(
    CreateAppReleaseRequest? create,
    UpdateAppReleaseRequest? update,
  )
  save,
}) async {
  final saved = await showAppFormModal<bool>(
    context,
    builder: (_) => _AppReleaseForm(
      existing: existing,
      template: template,
      copy: copy,
      releases: releases,
      initialPlatform: initialPlatform,
      save: save,
    ),
  );
  return saved ?? false;
}

class _AppReleaseForm extends StatefulWidget {
  final AppRelease? existing;
  final AppRelease? template;
  final ReleaseCopy copy;
  final List<AppRelease> releases;
  final String? initialPlatform;
  final Future<void> Function(
    CreateAppReleaseRequest?,
    UpdateAppReleaseRequest?,
  )
  save;

  const _AppReleaseForm({
    this.existing,
    this.template,
    required this.copy,
    required this.releases,
    this.initialPlatform,
    required this.save,
  });

  @override
  State<_AppReleaseForm> createState() => _AppReleaseFormState();
}

class _AppReleaseFormState extends State<_AppReleaseForm> {
  final _formKey = GlobalKey<FormState>();

  /// Where the notes, link and mandatory flag come from.
  AppRelease? get _source => widget.existing ?? widget.template;

  late String _platform = _startPlatform();
  late final _versionName = TextEditingController(text: _startVersionName());
  late final _versionCode = TextEditingController(
    text: _startVersionCode()?.toString(),
  );
  late final _title = TextEditingController(text: _source?.title);
  late final _changelog = TextEditingController(text: _source?.changelog);
  late final _downloadUrl = TextEditingController(text: _startDownloadUrl());
  late bool _mandatory = _source?.isMandatory ?? false;
  bool _saving = false;
  String? _error;

  /// The link the form filled in from the platform's newest release. While
  /// the field still holds it, picking another platform swaps it too.
  String? _suggestedUrl;

  /// The build number the form filled in itself. While the field still holds
  /// it, picking another platform moves it to that platform's next number.
  int? _suggestedCode;

  bool get _isEdit => widget.existing != null;
  bool get _isCopyToPlatform =>
      widget.template != null && widget.copy == ReleaseCopy.otherPlatform;

  String _startPlatform() {
    if (widget.existing case final e?) return e.platform;
    if (widget.template case final t?) {
      if (widget.copy == ReleaseCopy.nextVersion) return t.platform;
      // The first other platform that does not have this version yet.
      return releasePlatforms.keys.firstWhere(
        (p) => p != t.platform && !_hasVersionName(p, t.versionName),
        orElse: () => releasePlatforms.keys.firstWhere((p) => p != t.platform),
      );
    }
    return releasePlatforms.containsKey(widget.initialPlatform)
        ? widget.initialPlatform!
        : 'android';
  }

  String? _startVersionName() {
    if (widget.existing case final e?) return e.versionName;
    if (widget.template case final t?) {
      return widget.copy == ReleaseCopy.nextVersion
          ? nextVersionName(t.versionName)
          : t.versionName;
    }
    return null;
  }

  int? _startVersionCode() {
    if (widget.existing case final e?) return e.versionCode;
    // Builds are usually numbered alike across platforms; keep it.
    if (_isCopyToPlatform) return widget.template!.versionCode;
    final next =
        nextVersionCode(widget.releases, _platform) ??
        (widget.template == null ? null : widget.template!.versionCode + 1);
    _suggestedCode = next;
    return next;
  }

  String? _startDownloadUrl() {
    if (widget.existing case final e?) return e.downloadUrl;
    if (widget.template case final t?
        when widget.copy == ReleaseCopy.nextVersion) {
      return t.downloadUrl;
    }
    // A new release, or a copy to another store: that platform's own link.
    final latest = latestDownloadUrl(widget.releases, _platform);
    _suggestedUrl = latest;
    return latest ?? widget.template?.downloadUrl;
  }

  /// True when the link is still the other platform's, copied as it was.
  bool get _urlFromOtherPlatform =>
      _isCopyToPlatform &&
      _downloadUrl.text.trim() == widget.template!.downloadUrl &&
      _platform != widget.template!.platform;

  bool _hasVersionName(String platform, String name) => widget.releases.any(
    (r) => r.platform == platform && r.versionName == name.trim(),
  );

  void _selectPlatform(String platform) {
    setState(() {
      final suggested = _suggestedCode;
      _platform = platform;
      if (suggested != null && _versionCode.text == '$suggested') {
        final next = nextVersionCode(widget.releases, platform);
        if (next != null) {
          _suggestedCode = next;
          _versionCode.text = '$next';
        }
      }
      final url = _downloadUrl.text.trim();
      if (url.isEmpty ||
          url == _suggestedUrl ||
          url == widget.template?.downloadUrl) {
        final latest = latestDownloadUrl(widget.releases, platform);
        if (latest != null) {
          _suggestedUrl = latest;
          _downloadUrl.text = latest;
        }
      }
    });
    // Re-check the version fields against the newly picked platform.
    _formKey.currentState?.validate();
  }

  @override
  void dispose() {
    for (final c in [
      _versionName,
      _versionCode,
      _title,
      _changelog,
      _downloadUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? _validateUrl(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Download URL is required';
    final uri = Uri.tryParse(t);
    if (uri == null ||
        !uri.hasAuthority ||
        !uri.isScheme('http') && !uri.isScheme('https')) {
      return 'Enter a full http(s) link';
    }
    return null;
  }

  String? _validateVersionName(String? v) {
    final name = v?.trim() ?? '';
    if (name.isEmpty) return 'Version name is required';
    if (_hasVersionName(_platform, name)) {
      return '${platformLabel(_platform)} already has v$name';
    }
    return null;
  }

  String? _validateVersionCode(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 1) return 'Enter a positive build number';
    for (final r in widget.releases) {
      if (r.platform == _platform && r.versionCode == n) {
        return '${platformLabel(_platform)} build $n is v${r.versionName}';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(
        _isEdit
            ? null
            : CreateAppReleaseRequest(
                versionName: _versionName.text.trim(),
                versionCode: int.parse(_versionCode.text.trim()),
                platform: _platform,
                title: _title.text.trim(),
                changelog: _changelog.text.trim(),
                downloadUrl: _downloadUrl.text.trim(),
                isMandatory: _mandatory,
              ),
        _isEdit
            ? UpdateAppReleaseRequest(
                title: _title.text.trim(),
                changelog: _changelog.text.trim(),
                downloadUrl: _downloadUrl.text.trim(),
                isMandatory: _mandatory,
              )
            : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyError(e);
      });
    }
  }

  (String, String, IconData) _header() {
    final t = widget.template;
    if (widget.existing case final e?) {
      return (
        'Edit release',
        '${platformLabel(e.platform)} · v${e.versionName} (${e.versionCode})',
        Icons.edit_outlined,
      );
    }
    if (t != null && widget.copy == ReleaseCopy.otherPlatform) {
      return (
        'Copy v${t.versionName} to another platform',
        'Notes and settings copied from ${platformLabel(t.platform)}. '
            'Saved as a draft.',
        Icons.devices_rounded,
      );
    }
    if (t != null) {
      return (
        'New version from v${t.versionName}',
        'Notes and settings copied from ${platformLabel(t.platform)} '
            'v${t.versionName}. Saved as a draft.',
        Icons.content_copy_rounded,
      );
    }
    return (
      'New release',
      'Saved as a draft. Publish it when ready.',
      Icons.system_update_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final (title, subtitle, icon) = _header();
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return AppFormModal(
      formKey: _formKey,
      icon: icon,
      title: title,
      subtitle: subtitle,
      submitLabel: _isEdit ? 'Save changes' : 'Create release',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        if (existing != null)
          FormSection(
            title: 'Version',
            children: [
              Text(
                '${platformLabel(existing.platform)} · '
                'v${existing.versionName} · build ${existing.versionCode}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Platform, version and build cannot change once a release is '
                'made. To fix them, use "New version from this" or "Copy to '
                'another platform" on the release, then delete this one.',
                style: muted,
              ),
            ],
          )
        else
          FormSection(
            title: 'Version',
            children: [
              // Chips wrap on narrow screens instead of breaking words.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in releasePlatforms.entries)
                    ChoiceChip(
                      avatar: Icon(e.value.$2, size: 18),
                      label: Text(e.value.$1),
                      selected: _platform == e.key,
                      showCheckmark: false,
                      onSelected: (_) => _selectPlatform(e.key),
                    ),
                ],
              ),
              FormRow(
                children: [
                  TextFormField(
                    controller: _versionName,
                    autofocus: widget.template != null,
                    decoration: const InputDecoration(
                      labelText: 'Version name',
                      hintText: '1.2.6',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateVersionName,
                  ),
                  TextFormField(
                    controller: _versionCode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Version code',
                      hintText: '13',
                      helperText:
                          _suggestedCode != null &&
                              _versionCode.text == '$_suggestedCode'
                          ? 'Build number · next for '
                                '${platformLabel(_platform)}'
                          : 'Build number',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateVersionCode,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ],
          ),
        FormSection(
          title: 'Release notes',
          children: [
            TextFormField(
              controller: _title,
              autofocus: _isEdit,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Faster checkout and bug fixes',
              ),
              validator: FormValidators.required('Title'),
            ),
            TextFormField(
              controller: _changelog,
              minLines: 10,
              maxLines: 24,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "What's new",
                hintText: '• New receipt layout\n• Fixed printer disconnects',
                helperText:
                    'Shops see this exactly as typed. One change per line.',
                alignLabelWithHint: true,
              ),
              validator: FormValidators.required('Changelog'),
            ),
          ],
        ),
        FormSection(
          title: 'Distribution',
          children: [
            TextFormField(
              controller: _downloadUrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Download URL',
                hintText: 'https://…',
                prefixIcon: const Icon(Icons.link_rounded, size: 20),
                helperText: _urlFromOtherPlatform
                    ? 'Copied from ${platformLabel(widget.template!.platform)}: '
                          'check it points to the ${platformLabel(_platform)} '
                          'store'
                    : _suggestedUrl != null &&
                          _downloadUrl.text.trim() == _suggestedUrl
                    ? 'From the newest ${platformLabel(_platform)} release'
                    : null,
                helperMaxLines: 2,
              ),
              validator: _validateUrl,
              onChanged: (_) => setState(() {}),
            ),
            FormSwitch(
              title: 'Mandatory update',
              subtitle: 'Users must update before they can keep using the app',
              value: _mandatory,
              onChanged: (v) => setState(() => _mandatory = v),
            ),
          ],
        ),
      ],
    );
  }
}
