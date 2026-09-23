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

/// Opens the create (when [existing] is null) or edit form. [save] should
/// throw on failure; the form then stays open with the error shown.
Future<bool> showAppReleaseForm(
  BuildContext context, {
  AppRelease? existing,
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
      initialPlatform: initialPlatform,
      save: save,
    ),
  );
  return saved ?? false;
}

class _AppReleaseForm extends StatefulWidget {
  final AppRelease? existing;
  final String? initialPlatform;
  final Future<void> Function(
    CreateAppReleaseRequest?,
    UpdateAppReleaseRequest?,
  )
  save;

  const _AppReleaseForm({
    this.existing,
    this.initialPlatform,
    required this.save,
  });

  @override
  State<_AppReleaseForm> createState() => _AppReleaseFormState();
}

class _AppReleaseFormState extends State<_AppReleaseForm> {
  final _formKey = GlobalKey<FormState>();
  late final _versionName = TextEditingController(
    text: widget.existing?.versionName,
  );
  late final _versionCode = TextEditingController(
    text: widget.existing?.versionCode.toString(),
  );
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _changelog = TextEditingController(
    text: widget.existing?.changelog,
  );
  late final _downloadUrl = TextEditingController(
    text: widget.existing?.downloadUrl,
  );
  late String _platform =
      widget.existing?.platform ??
      (releasePlatforms.containsKey(widget.initialPlatform)
          ? widget.initialPlatform!
          : 'android');
  late bool _mandatory = widget.existing?.isMandatory ?? false;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

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

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final platformLabel =
        releasePlatforms[_platform]?.$1 ?? humanize(_platform);
    return AppFormModal(
      formKey: _formKey,
      icon: _isEdit ? Icons.edit_outlined : Icons.system_update_rounded,
      title: _isEdit ? 'Edit release' : 'New release',
      subtitle: _isEdit
          ? '$platformLabel · v${existing!.versionName} (${existing.versionCode})'
          : 'Saved as a draft. Publish it from the list when ready.',
      submitLabel: _isEdit ? 'Save changes' : 'Create release',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        if (!_isEdit)
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
                      onSelected: (_) => setState(() => _platform = e.key),
                    ),
                ],
              ),
              FormRow(
                children: [
                  TextFormField(
                    controller: _versionName,
                    decoration: const InputDecoration(
                      labelText: 'Version name',
                      hintText: '1.2.6',
                    ),
                    validator: FormValidators.required('Version name'),
                  ),
                  TextFormField(
                    controller: _versionCode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Version code',
                      hintText: '13',
                      helperText: 'Build number',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      return n == null || n < 1
                          ? 'Enter a positive build number'
                          : null;
                    },
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
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: "What's new",
                hintText: '• New receipt layout\n• Fixed printer disconnects',
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
              decoration: const InputDecoration(
                labelText: 'Download URL',
                hintText: 'https://…',
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
              validator: _validateUrl,
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
