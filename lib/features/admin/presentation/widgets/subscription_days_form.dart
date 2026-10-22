import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

/// Opens the extend or reduce form. [save] performs the change; the form stays
/// open with the error shown if it throws. Returns the number of days applied,
/// or null when cancelled.
Future<int?> showSubscriptionDaysForm(
  BuildContext context, {
  required bool reduce,
  required String shopName,
  required Future<void> Function(int days, String? reason) save,
}) {
  return showAppFormModal<int>(
    context,
    builder: (_) =>
        _SubscriptionDaysForm(reduce: reduce, shopName: shopName, save: save),
  );
}

class _SubscriptionDaysForm extends StatefulWidget {
  final bool reduce;
  final String shopName;
  final Future<void> Function(int days, String? reason) save;

  const _SubscriptionDaysForm({
    required this.reduce,
    required this.shopName,
    required this.save,
  });

  @override
  State<_SubscriptionDaysForm> createState() => _SubscriptionDaysFormState();
}

class _SubscriptionDaysFormState extends State<_SubscriptionDaysForm> {
  static const _maxDays = 3650;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _days = TextEditingController(
    text: widget.reduce ? '7' : '30',
  );
  final _reason = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _days.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? _validateDays(String? value) {
    final days = int.tryParse(value?.trim() ?? '');
    if (days == null) return 'Enter a whole number of days';
    if (days < 1 || days > _maxDays) return 'Enter 1 to $_maxDays days';
    return null;
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final days = int.parse(_days.text.trim());
    final reason = _reason.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(days, reason.isEmpty ? null : reason);
      if (mounted) Navigator.of(context).pop(days);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduce = widget.reduce;
    return AppFormModal(
      formKey: _formKey,
      icon: reduce
          ? Icons.remove_circle_outline_rounded
          : Icons.add_circle_outline_rounded,
      title: reduce ? 'Reduce subscription' : 'Extend subscription',
      subtitle: widget.shopName,
      submitLabel: reduce ? 'Reduce' : 'Extend',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: 'Period',
          hint: reduce
              ? 'Moves the expiry date earlier. It cannot move before today.'
              : 'Moves the expiry date later. No payment is recorded.',
          children: [
            TextFormField(
              controller: _days,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: reduce ? 'Days to remove' : 'Days to add',
                suffixText: 'days',
              ),
              validator: _validateDays,
            ),
          ],
        ),
        FormSection(
          title: 'Reason',
          children: [
            TextFormField(
              controller: _reason,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: reduce ? 'Reason' : 'Reason (optional)',
                alignLabelWithHint: true,
              ),
              validator: reduce ? FormValidators.required('Reason') : null,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ],
    );
  }
}
