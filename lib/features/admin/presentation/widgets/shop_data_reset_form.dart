import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_ownership_forms.dart';

// Empties a shop that was keyed in wrong - usually a test shop - so it can be
// set up again from scratch. Unlike Delete shop, nothing can be restored, so
// the form shows what will go before it can be sent.

final _count = NumberFormat('#,##0');

/// Resets [shop]'s data. Resolves to what was removed, `null` when cancelled.
Future<ShopDataReset?> showResetShopDataForm(
  BuildContext context,
  AdminShop shop,
) => showAppFormModal<ShopDataReset>(
  context,
  builder: (_) => _ResetShopDataForm(shop: shop),
);

/// Confirms a finished reset with what was removed.
Future<void> showShopDataResetResultDialog(
  BuildContext context,
  ShopDataReset result,
) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    icon: Icon(Icons.check_circle_rounded, color: ctx.status.success),
    title: const Text('Shop data reset'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.isEmpty
                ? '"${result.shopName}" had nothing to remove.'
                : '"${result.shopName}" is empty and ready to be keyed in again.',
          ),
          if (!result.isEmpty) ...[
            const SizedBox(height: 12),
            _CountList(result),
          ],
        ],
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.of(ctx).pop(),
        child: const Text('Done'),
      ),
    ],
  ),
);

/// One line per kind of record, the total, then the pictures in storage.
class _CountList extends StatelessWidget {
  final ShopDataReset reset;
  const _CountList(this.reset);

  @override
  Widget build(BuildContext context) {
    Widget line(String label, int count, {bool bold = false}) {
      final style = bold
          ? context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
          : context.text.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(_count.format(count), style: style),
          ],
        ),
      );
    }

    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(text, style: context.text.bodySmall),
    );

    final files = reset.files;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, count) in reset.summary) line(label, count),
        const Divider(height: 16),
        line('Total records', reset.totalRows, bold: true),
        if (files != null && files > 0) line('Pictures in storage', files),
        if (files == null)
          note(
            reset.done
                ? 'Storage could not be reached, so its pictures were left '
                      'there. Nothing shows them any more.'
                : 'Pictures in storage could not be counted now. The reset '
                      'still deletes them.',
          ),
        if (reset.filesFailed > 0)
          note(
            '${_count.format(reset.filesFailed)} pictures could not be '
            'deleted from storage. Nothing shows them any more.',
          ),
      ],
    );
  }
}

class _ResetShopDataForm extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _ResetShopDataForm({required this.shop});

  @override
  ConsumerState<_ResetShopDataForm> createState() => _ResetShopDataFormState();
}

class _ResetShopDataFormState extends ConsumerState<_ResetShopDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmName = TextEditingController();
  final _reason = TextEditingController();
  late Future<ShopDataReset> _preview = _loadPreview();
  bool _saving = false;
  String? _error;

  Future<ShopDataReset> _loadPreview() =>
      ref.read(shopsProvider.notifier).previewShopDataReset(widget.shop.id);

  @override
  void dispose() {
    _confirmName.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(shopsProvider.notifier)
          .resetShopData(
            widget.shop.id,
            ResetShopDataRequest(
              confirmShopName: _confirmName.text.trim(),
              reason: _reason.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(result);
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
    final shop = widget.shop;
    return AppFormModal(
      formKey: _formKey,
      icon: Icons.restart_alt_rounded,
      title: 'Reset shop data',
      subtitle: '${shop.name} · #${shop.id}',
      submitLabel: 'Reset data',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        const FormNotice(
          'Deletes the records below for good, so the shop can be keyed in '
          'again from scratch. This cannot be undone and is not the same as '
          'Delete shop. Use it for a test shop, or one whose products went '
          'in wrong.',
          warning: true,
        ),
        const SizedBox(height: 20),
        FormSection(
          title: 'Will be removed',
          children: [
            FutureBuilder<ShopDataReset>(
              future: _preview,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Could not count the records: '
                          '${friendlyError(snapshot.error!)}',
                          style: context.text.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _preview = _loadPreview()),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                final preview = snapshot.data!;
                if (preview.isEmpty) {
                  return Text(
                    'Nothing to remove: the shop has no products, sales or '
                    'customers.',
                    style: context.text.bodyMedium,
                  );
                }
                return _CountList(preview);
              },
            ),
          ],
        ),
        FormSection(
          title: 'Stays as it is',
          children: [
            Text(
              'The shop and its settings, receipt settings, staff and roles, '
              'payment methods, bank accounts, exchange rates, restaurant '
              'areas and tables, expense categories, the subscription and '
              'its payments, the shop logo and bank QR codes. Branches are not '
              "touched, and pictures a branch still shows are kept.",
              style: context.text.bodyMedium,
            ),
          ],
        ),
        const FormNotice(
          "Have the shop's tills send their offline sales first. A sale still "
          'waiting on a till is refused once its products are gone.',
        ),
        const SizedBox(height: 20),
        FormSection(
          title: 'Confirm',
          children: [
            confirmShopNameField(_confirmName, shop.name),
            TextFormField(
              controller: _reason,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. test shop, products keyed in wrong',
                helperText: "Kept in the shop's audit log",
              ),
              validator: FormValidators.required('Reason'),
            ),
          ],
        ),
      ],
    );
  }
}
