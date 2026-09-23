import 'package:flutter/material.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Unit categories the backend accepts, with a label and example for each.
const unitCategories = <String, (String, String)>{
  'piece': ('Piece', 'pc, box, pack'),
  'weight': ('Weight', 'kg, g, lb'),
  'volume': ('Volume', 'L, ml'),
  'length': ('Length', 'm, cm'),
  'area': ('Area', 'm², ft²'),
  'custom': ('Custom', 'anything else'),
};

const _extraLanguages = [
  ('th', 'Thai'),
  ('vi', 'Vietnamese'),
  ('zh', 'Chinese'),
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
      icon: _isEdit ? Icons.edit_outlined : Icons.straighten_rounded,
      title: _isEdit ? 'Edit unit' : 'New unit',
      subtitle: _isEdit
          ? '${widget.existing!.name['en'] ?? widget.existing!.code} · ${widget.existing!.abbreviation}'
          : 'A unit of measure shops can sell products in',
      submitLabel: _isEdit ? 'Save changes' : 'Create unit',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: 'Basics',
          children: [
            FormRow(
              children: [
                TextFormField(
                  controller: _code,
                  autofocus: !_isEdit,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'piece',
                  ),
                  validator: FormValidators.required('Code'),
                ),
                TextFormField(
                  controller: _abbr,
                  decoration: const InputDecoration(
                    labelText: 'Abbreviation',
                    hintText: 'pc',
                  ),
                  validator: FormValidators.required('Abbreviation'),
                ),
              ],
            ),
            FormRow(
              flex: const [3, 2],
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final e in unitCategories.entries)
                      DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          '${e.value.$1}  ·  ${e.value.$2}',
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
                  validator: (v) => v == null ? 'Choose a category' : null,
                ),
                TextFormField(
                  controller: _sortOrder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sort order'),
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
                  controller: _names['en'],
                  decoration: const InputDecoration(
                    labelText: 'English',
                    hintText: 'Piece',
                  ),
                  validator: FormValidators.required('English name'),
                ),
                TextFormField(
                  controller: _names['lo'],
                  decoration: const InputDecoration(labelText: 'Lao'),
                ),
              ],
            ),
            Theme(
              // Drop the ExpansionTile's default dividers inside the card.
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: _hasExtraNames,
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 4),
                title: Text(
                  'More languages',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Thai, Vietnamese, Chinese'),
                children: [
                  for (final (i, (lang, label)) in _extraLanguages.indexed) ...[
                    if (i > 0) const SizedBox(height: 14),
                    TextFormField(
                      controller: _names[lang],
                      decoration: InputDecoration(labelText: label),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        FormSection(
          title: 'Details',
          children: [
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
              ),
            ),
            FormSwitch(
              title: 'Active',
              subtitle: 'Shops can pick this unit for products',
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            FormSwitch(
              title: 'Default unit',
              subtitle: 'Pre-selected when creating new products',
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
          ],
        ),
      ],
    );
  }
}
