import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// The backend stores no icon for a shop type, so it follows from the code.
const _shopTypeIcons = <String, IconData>{
  'retail': Icons.store_rounded,
  'restaurant': Icons.restaurant_rounded,
  'cafe': Icons.local_cafe_rounded,
  'bar': Icons.local_bar_rounded,
  'service': Icons.room_service_rounded,
  'wholesale': Icons.warehouse_rounded,
  'online': Icons.shopping_cart_rounded,
  'grocery': Icons.local_grocery_store_rounded,
  'pharmacy': Icons.local_pharmacy_rounded,
  'salon': Icons.spa_rounded,
  'spa': Icons.spa_rounded,
  'hotel': Icons.hotel_rounded,
};

IconData shopTypeIcon(String code) {
  final key = code.toLowerCase();
  for (final MapEntry(key: word, value: icon) in _shopTypeIcons.entries) {
    if (key.contains(word)) return icon;
  }
  return Icons.storefront_rounded;
}

/// Opens the create (when [existing] is null) or edit form. [save] receives
/// the request and should throw on failure; the form shows the error inline
/// and stays open. Resolves to `true` when saved.
Future<bool> showShopTypeForm(
  BuildContext context, {
  ShopType? existing,
  required Future<void> Function(
    CreateShopTypeRequest? create,
    UpdateShopTypeRequest? update,
  )
  save,
}) async {
  final saved = await showAppFormModal<bool>(
    context,
    builder: (_) => _ShopTypeForm(existing: existing, save: save),
  );
  return saved ?? false;
}

class _ShopTypeForm extends StatefulWidget {
  final ShopType? existing;
  final Future<void> Function(CreateShopTypeRequest?, UpdateShopTypeRequest?)
  save;

  const _ShopTypeForm({this.existing, required this.save});

  @override
  State<_ShopTypeForm> createState() => _ShopTypeFormState();
}

class _ShopTypeFormState extends State<_ShopTypeForm> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.existing?.code);
  late final _nameEn = TextEditingController(text: _name('en'));
  late final _nameLo = TextEditingController(text: _name('lo'));
  late final _descEn = TextEditingController(text: _desc('en'));
  late final _descLo = TextEditingController(text: _desc('lo'));
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  String _name(String lang) {
    final e = widget.existing;
    if (e == null) return '';
    return e.nameI18n[lang] ?? (lang == 'en' ? e.name : '');
  }

  String _desc(String lang) {
    final e = widget.existing;
    if (e == null) return '';
    return e.descriptionI18n[lang] ?? (lang == 'en' ? e.description ?? '' : '');
  }

  @override
  void dispose() {
    for (final c in [_code, _nameEn, _nameLo, _descEn, _descLo]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Merges edited EN/LO into the existing translations so languages this
  /// form doesn't show (e.g. TH) survive the save.
  Map<String, dynamic> _merge(
    Map<String, String> original,
    String en,
    String lo,
  ) {
    final map = <String, dynamic>{...original};
    for (final (lang, value) in [('en', en.trim()), ('lo', lo.trim())]) {
      if (value.isEmpty) {
        map.remove(lang);
      } else {
        map[lang] = value;
      }
    }
    return map;
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final name = _merge(
      widget.existing?.nameI18n ?? const {},
      _nameEn.text,
      _nameLo.text,
    );
    final description = _merge(
      widget.existing?.descriptionI18n ?? const {},
      _descEn.text,
      _descLo.text,
    );
    final code = _code.text.trim().toUpperCase();
    try {
      await widget.save(
        _isEdit
            ? null
            : CreateShopTypeRequest(
                code: code,
                name: name,
                description: description.isEmpty ? null : description,
              ),
        _isEdit
            ? UpdateShopTypeRequest(
                code: code,
                name: name,
                description: description,
                // Not editable here, but the update replaces them
                features: widget.existing!.features,
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
    return AppFormModal(
      formKey: _formKey,
      icon: _isEdit ? Icons.edit_outlined : Icons.category_outlined,
      title: _isEdit ? 'Edit shop type' : 'New shop type',
      subtitle: _isEdit
          ? widget.existing!.name
          : 'Group shops by the kind of business they run',
      submitLabel: _isEdit ? 'Save changes' : 'Create shop type',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: 'Basics',
          children: [
            TextFormField(
              controller: _code,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Code',
                hintText: 'RESTAURANT',
                helperText: 'Letters, numbers and _',
              ),
              validator: FormValidators.required('Code'),
            ),
          ],
        ),
        FormSection(
          title: 'Name',
          children: [
            FormRow(
              children: [
                TextFormField(
                  controller: _nameEn,
                  decoration: const InputDecoration(
                    labelText: 'English',
                    hintText: 'Restaurant',
                  ),
                  validator: FormValidators.required('English name'),
                ),
                TextFormField(
                  controller: _nameLo,
                  decoration: const InputDecoration(
                    labelText: 'Lao (optional)',
                    hintText: 'ຮ້ານອາຫານ',
                  ),
                ),
              ],
            ),
          ],
        ),
        FormSection(
          title: 'Description',
          hint: 'Optional. Shown to owners when they pick a shop type.',
          children: [
            TextFormField(
              controller: _descEn,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'English',
                alignLabelWithHint: true,
              ),
            ),
            TextFormField(
              controller: _descLo,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Lao',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
