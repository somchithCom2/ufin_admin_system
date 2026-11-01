import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Opens the reset form. [save] performs the change with the days left, null
/// for the whole trial or period; the form stays open with the error shown if
/// it throws. Returns true when saved, null when cancelled.
Future<bool?> showSubscriptionResetForm(
  BuildContext context, {
  required AdminSubscription subscription,
  required Future<void> Function(int? days, String? reason) save,
}) {
  return showAppFormModal<bool>(
    context,
    builder: (_) =>
        _SubscriptionResetForm(subscription: subscription, save: save),
  );
}

class _SubscriptionResetForm extends StatefulWidget {
  final AdminSubscription subscription;
  final Future<void> Function(int? days, String? reason) save;

  const _SubscriptionResetForm({
    required this.subscription,
    required this.save,
  });

  @override
  State<_SubscriptionResetForm> createState() => _SubscriptionResetFormState();
}

class _SubscriptionResetFormState extends State<_SubscriptionResetForm> {
  static const _maxDays = 3650;

  final _formKey = GlobalKey<FormState>();
  final _days = TextEditingController();
  final _reason = TextEditingController();
  bool _saving = false;
  String? _error;

  /// Free restarts as a trial, as the server does it.
  bool get _isTrial =>
      widget.subscription.isTrial ||
      widget.subscription.planCode?.toLowerCase() == 'free';

  int? get _daysLeft => int.tryParse(_days.text.trim());

  bool get _endsNow => _daysLeft == 0;

  String get _hint {
    if (_isTrial) {
      return _endsNow
          ? 'Ends the trial now. The shop cannot open new bills until it picks '
                'a plan.'
          : 'Leave empty for a full new trial, or enter the days left. 0 ends '
                'it now. No payment is recorded.';
    }
    return _endsNow
        ? 'Ends this paid plan now and moves the shop to Free, where it cannot '
              'open new bills. A reset will not bring the plan back.'
        : 'Leave empty for a new billing period, or enter the days left. 0 '
              'ends it now. No payment is recorded.';
  }

  @override
  void dispose() {
    _days.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? _validateDays(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final days = int.tryParse(text);
    if (days == null) return 'Enter a whole number of days';
    if (days > _maxDays) return 'Enter 0 to $_maxDays days';
    return null;
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final reason = _reason.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(_daysLeft, reason.isEmpty ? null : reason);
      if (mounted) Navigator.of(context).pop(true);
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
    return AppFormModal(
      formKey: _formKey,
      icon: Icons.restart_alt_rounded,
      title: 'Reset subscription',
      subtitle: widget.subscription.shopName,
      submitLabel: _endsNow ? 'End now' : 'Reset',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: 'Period',
          hint: _hint,
          children: [
            TextFormField(
              controller: _days,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Days left (optional)',
                suffixText: 'days',
              ),
              validator: _validateDays,
              onChanged: (_) => setState(() {}),
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
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                alignLabelWithHint: true,
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ],
    );
  }
}
