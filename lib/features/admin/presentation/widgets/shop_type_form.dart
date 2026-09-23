import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Icon names the backend accepts for shop types, in display order.
const shopTypeIconNames = <String, IconData>{
  'store': Icons.store_rounded,
  'restaurant': Icons.restaurant_rounded,
  'local_cafe': Icons.local_cafe_rounded,
  'local_bar': Icons.local_bar_rounded,
  'shopping_cart': Icons.shopping_cart_rounded,
  'local_grocery_store': Icons.local_grocery_store_rounded,
  'local_mall': Icons.local_mall_rounded,
  'local_pharmacy': Icons.local_pharmacy_rounded,
  'local_hospital': Icons.local_hospital_rounded,
  'local_laundry_service': Icons.local_laundry_service_rounded,
  'spa': Icons.spa_rounded,
  'fitness_center': Icons.fitness_center_rounded,
  'hotel': Icons.hotel_rounded,
  'car_repair': Icons.car_repair_rounded,
};

IconData shopTypeIcon(String? name) =>
    shopTypeIconNames[name?.toLowerCase()] ?? Icons.storefront_rounded;

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
  late final _order = TextEditingController(
    text: (widget.existing?.displayOrder ?? 0).toString(),
  );
  late String? _icon = widget.existing?.iconName;
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
    for (final c in [_code, _nameEn, _nameLo, _descEn, _descLo, _order]) {
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
    final order = int.tryParse(_order.text.trim());
    try {
      await widget.save(
        _isEdit
            ? null
            : CreateShopTypeRequest(
                code: code,
                name: name,
                description: description.isEmpty ? null : description,
                iconName: _icon,
                displayOrder: order,
              ),
        _isEdit
            ? UpdateShopTypeRequest(
                code: code,
                name: name,
                description: description,
                iconName: _icon,
                displayOrder: order,
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
            FormRow(
              flex: const [3, 2],
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
                TextFormField(
                  controller: _order,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Display order',
                    helperText: 'Lower shows first',
                  ),
                  validator: FormValidators.optionalInt,
                ),
              ],
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
        FormSection(
          title: 'Icon',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in shopTypeIconNames.entries)
                  _IconChoice(
                    name: entry.key,
                    icon: entry.value,
                    selected: _icon == entry.key,
                    onTap: () => setState(
                      () => _icon = _icon == entry.key ? null : entry.key,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _IconChoice({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Tooltip(
      message: humanize(name),
      child: Semantics(
        selected: selected,
        button: true,
        label: humanize(name),
        child: Material(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: BorderSide(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                icon,
                size: 22,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
