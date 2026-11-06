import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
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
          ? context.tr(SubsText.endsTheTrialNowThe)
          : context.tr(SubsText.leaveEmptyForAFull);
    }
    return _endsNow
        ? context.tr(SubsText.endsThisPaidPlanNow)
        : context.tr(SubsText.leaveEmptyForANew);
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
    if (days == null) return context.tr(SubsText.enterAWholeNumberOf2);
    if (days > _maxDays) return context.tr(SubsText.enter0ToDays(_maxDays));
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
      icon: AppIcons.reset,
      title: context.tr(SubsText.resetSubscription),
      subtitle: widget.subscription.shopName,
      submitLabel: _endsNow
          ? context.tr(SubsText.endNow)
          : context.tr(CommonText.reset),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: context.tr(SubsText.period2),
          hint: _hint,
          children: [
            TextFormField(
              controller: _days,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: context.tr(SubsText.daysLeftOptional),
                suffixText: context.tr(SubsText.days2),
              ),
              validator: _validateDays,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.reason),
          children: [
            TextFormField(
              controller: _reason,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr(SubsText.reasonOptional2),
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
