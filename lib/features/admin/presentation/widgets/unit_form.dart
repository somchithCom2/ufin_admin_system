import 'package:flutter/material.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Unit categories the backend accepts, with a label and example for each.
const unitCategories = <String, (Tr, String)>{
  'piece': (Tr('Piece', 'ຊິ້ນ'), 'pc, box, pack'),
  'weight': (Tr('Weight', 'ນ້ຳໜັກ'), 'kg, g, lb'),
  'volume': (Tr('Volume', 'ປະລິມາດ'), 'L, ml'),
  'length': (Tr('Length', 'ຄວາມຍາວ'), 'm, cm'),
  'area': (Tr('Area', 'ພື້ນທີ່'), 'm², ft²'),
  'custom': (Tr('Custom', 'ກຳນົດເອງ'), '…'),
};

/// Display name for a unit category code, falling back to the raw code.
String unitCategoryLabel(BuildContext context, String code) {
  final entry = unitCategories[code.toLowerCase()];
  return entry == null ? humanize(code) : context.tr(entry.$1);
}

const _extraLanguages = [
  ('th', ShopTypeText.thai),
  ('vi', ShopTypeText.vietnamese),
  ('zh', ShopTypeText.chinese),
];

/// Opens the create (when [existing] is null) or edit form. [save] should
/// throw on failure; the form then stays open with the error shown.
Future<bool> showUnitForm(
  BuildContext context, {
  Unit? existing,
  required Future<void> Function(
    CreateUnitRequest? create,
    UpdateUnitRequest? update,
  )
  save,
}) async {
  final saved = await showAppFormModal<bool>(
    context,
    builder: (_) => _UnitForm(existing: existing, save: save),
  );
  return saved ?? false;
}

class _UnitForm extends StatefulWidget {
  final Unit? existing;
  final Future<void> Function(CreateUnitRequest?, UpdateUnitRequest?) save;

  const _UnitForm({this.existing, required this.save});

  @override
  State<_UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends State<_UnitForm> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.existing?.code);
  late final _abbr = TextEditingController(text: widget.existing?.abbreviation);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late final _sortOrder = TextEditingController(
    text: (widget.existing?.sortOrder ?? 0).toString(),
  );
  late final Map<String, TextEditingController> _names = {
    for (final lang in ['en', 'lo', for (final (l, _) in _extraLanguages) l])
      lang: TextEditingController(
        text: widget.existing?.name[lang]?.toString() ?? '',
      ),
  };
  late String? _category = (widget.existing?.category.isNotEmpty ?? false)
      ? widget.existing!.category
      : null;
  late bool _isActive = widget.existing?.isActive ?? true;
  late bool _isDefault = widget.existing?.isDefault ?? false;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  bool get _hasExtraNames =>
      _extraLanguages.any((l) => _names[l.$1]!.text.trim().isNotEmpty);

  /// Drives the SVG chevron, which ExpansionTile only rotates for its own
  /// default icon.
  late bool _moreLanguagesOpen = _hasExtraNames;

  @override
  void dispose() {
    for (final c in [
      _code,
      _abbr,
      _description,
      _sortOrder,
      ..._names.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    // Keep translations this form doesn't edit (unknown languages) intact.
    final name = <String, dynamic>{...?widget.existing?.name};
    _names.forEach((lang, c) {
      final v = c.text.trim();
      if (v.isEmpty) {
        name.remove(lang);
      } else {
        name[lang] = v;
      }
    });
    final description = _description.text.trim();
    final sortOrder = int.tryParse(_sortOrder.text.trim());
    try {
      await widget.save(
        _isEdit
            ? null
            : CreateUnitRequest(
                code: _code.text.trim(),
                name: name,
                abbreviation: _abbr.text.trim(),
                category: _category!,
                description: description.isEmpty ? null : description,
                isActive: _isActive,
                isDefault: _isDefault,
                sortOrder: sortOrder,
              ),
        _isEdit
            ? UpdateUnitRequest(
                code: _code.text.trim(),
                name: name,
                abbreviation: _abbr.text.trim(),
                category: _category,
                description: description.isEmpty ? null : description,
                isActive: _isActive,
                isDefault: _isDefault,
                sortOrder: sortOrder,
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
      icon: _isEdit ? AppIcons.edit : AppIcons.ruler,
      title: _isEdit
          ? context.tr(ShopTypeText.editUnit)
          : context.tr(ShopTypeText.newUnit),
      subtitle: _isEdit
          ? '${widget.existing!.name['en'] ?? widget.existing!.code} · ${widget.existing!.abbreviation}'
          : context.tr(ShopTypeText.aUnitOfMeasureShops),
      submitLabel: _isEdit
          ? context.tr(CommonText.saveChanges)
          : context.tr(ShopTypeText.createUnit),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: context.tr(ShopTypeText.basics2),
          children: [
            FormRow(
              children: [
                TextFormField(
                  controller: _code,
                  autofocus: !_isEdit,
                  decoration: InputDecoration(
                    labelText: context.tr(CommonText.code),
                    hintText: 'piece',
                  ),
                  validator: FormValidators.required(
                    context.tr(CommonText.code),
                  ),
                ),
                TextFormField(
                  controller: _abbr,
                  decoration: InputDecoration(
                    labelText: context.tr(ShopTypeText.abbreviation2),
                    hintText: 'pc',
                  ),
                  validator: FormValidators.required(
                    context.tr(ShopTypeText.abbreviation2),
                  ),
                ),
              ],
            ),
            FormRow(
              flex: const [3, 2],
              children: [
                DropdownButtonFormField<String>(
                  icon: const AppIcon(AppIcons.chevronDown, size: 20),
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.tr(ShopTypeText.category2),
                  ),
                  items: [
                    for (final e in unitCategories.entries)
                      DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          '${context.tr(e.value.$1)}  ·  ${e.value.$2}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // Keep a legacy category selectable so editing doesn't
                    // force it to change.
                    if (_category != null &&
                        !unitCategories.containsKey(_category))
                      DropdownMenuItem(
                        value: _category,
                        child: Text(humanize(_category!)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null
                      ? context.tr(ShopTypeText.chooseACategory)
                      : null,
                ),
                TextFormField(
                  controller: _sortOrder,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr(ShopTypeText.sortOrder),
                  ),
                  validator: FormValidators.optionalInt,
                ),
              ],
            ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.name),
          children: [
            FormRow(
              children: [
                TextFormField(
                  controller: _names['en'],
                  decoration: InputDecoration(
                    labelText: context.tr(ShopTypeText.english2),
                    hintText: 'Piece',
                  ),
                  validator: FormValidators.required(
                    context.tr(ShopTypeText.englishName2),
                  ),
                ),
                TextFormField(
                  controller: _names['lo'],
                  decoration: InputDecoration(
                    labelText: context.tr(ShopTypeText.lao2),
                  ),
                ),
              ],
            ),
            Theme(
              // Drop the ExpansionTile's default dividers inside the card.
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: _moreLanguagesOpen,
                onExpansionChanged: (open) =>
                    setState(() => _moreLanguagesOpen = open),
                trailing: AnimatedRotation(
                  turns: _moreLanguagesOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const AppIcon(AppIcons.chevronDown, size: 20),
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 4),
                title: Text(
                  context.tr(ShopTypeText.moreLanguages),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(context.tr(ShopTypeText.thaiVietnameseChinese)),
                children: [
                  for (final (i, (lang, label)) in _extraLanguages.indexed) ...[
                    if (i > 0) const SizedBox(height: 14),
                    TextFormField(
                      controller: _names[lang],
                      decoration: InputDecoration(labelText: context.tr(label)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.details),
          children: [
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr(ShopTypeText.descriptionOptional),
                alignLabelWithHint: true,
              ),
            ),
            FormSwitch(
              title: context.tr(ShopTypeText.active3),
              subtitle: context.tr(ShopTypeText.shopsCanPickThisUnit),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            FormSwitch(
              title: context.tr(ShopTypeText.defaultUnit),
              subtitle: context.tr(ShopTypeText.preSelectedWhenCreatingNew),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
          ],
        ),
      ],
    );
  }
}
